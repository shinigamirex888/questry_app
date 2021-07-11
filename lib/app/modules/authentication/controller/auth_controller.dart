import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:questry/app/modules/home/homepage.dart';
import '../../../data/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User user = User('', '');
  TextEditingController comment = TextEditingController();
  bool validate_signup = false;
  bool circular_signin = false;
  bool circular_signup = false;
  final storage = new FlutterSecureStorage();
  String errorText;
  bool vis_signin = true;
  bool vis_signup = true;

  String emailvalidation(String value) {
    if (value.isEmpty) {
      return 'Enter something';
    } else if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return null;
    } else {
      return "Enter valid Email";
    }
  }

  String passValidation(String value) {
    if (value.isEmpty) {
      return 'Enter something';
    } else {
      return null;
    }
  }

  String usernameValidation(String value) {
    print("inside validation");
    if (value.isEmpty) {
      return 'Enter something';
    } else {
      return null;
    }
  }

  void submitSignIn() {
    circular_signin = true;
    update();
    if (formKey.currentState.validate()) {
      signInSave();
    } else {
      print("not ok");
      circular_signin = false;
      update();
    }
  }

  void submitSignUp() async {
    circular_signup = true;
    update();
    await checkUser();
    print("in submitSignUp function");
    if (formKey.currentState.validate() & validate_signup) {
      signUpSave();
    } else {
      print("not ok");
      circular_signup = false;
      update();
    }
  }

  Future signInSave() async {
    circular_signin = true;
    var url = Uri.parse("http://10.0.2.2:8800/api/auth/login");
    final res = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'email': user.email, 'password': user.password}));
    if (res.statusCode == 200 || res.statusCode == 201) {
      Map<String, dynamic> output = json.decode(res.body);
      print(output["token"]);
      await storage.write(key: "token", value: output["token"]);
      circular_signin = false;
      update();
      Get.offAll(() => HomePage());
    } else {
      String output = json.decode(res.body);
      errorText = output;
      circular_signin = false;
      update();
    }
  }

  Future signUpSave() async {
    print("signupsave function");
    var url = Uri.parse("http://10.0.2.2:8800/api/auth/register");
    final res = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': user.username,
          'email': user.email,
          'password': user.password
        }));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var url = Uri.parse("http://10.0.2.2:8800/api/auth/login");
      final res = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': user.email,
            'password': user.password
          }));

      if (res.statusCode == 200 || res.statusCode == 201) {
        Map<String, dynamic> output = json.decode(res.body);
        print(output["token"]);
        await storage.write(key: "token", value: output["token"]);

        validate_signup = true;
        circular_signup = false;

        update();

        Get.offAll(() => HomePage());
      } else {
        Scaffold.of(Get.context)
            .showSnackBar(SnackBar(content: Text("Netwok Error")));
      }
    }
  }

  checkUser() async {
    print("in checkuser function");
    var url = Uri.parse(
        "http://10.0.2.2:8800/api/auth/checkusername/${user.username}");
    print(user.username);
    if (user.username.length == 0) {
      validate_signup = false;
      errorText = "Username Can't be empty";
      update();
    } else {
      var response = await http.get(url);
      if (response.body.split(":")[1].startsWith("t")) {
        validate_signup = false;
        errorText = "Username already taken";
        update();
      } else {
        validate_signup = true;
        update();
      }
    }
  }

  void changeVis() {
    vis_signup = !vis_signup;
    update();
  }

  void changeVisSign() {
    vis_signin = !vis_signin;
    update();
  }

  //adding a comment to the post

  void addComment(postId) async {
    String token = await storage.read(key: "token");
    var url =
        Uri.parse("http://10.0.2.2:8800/api/posts/comment/${user.username}");
    final response = await http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(<String, String>{
          "content": comment.text,
          "_id": postId,
        }));
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.showSnackbar(
        GetBar(
          message: "your answer added",
          isDismissible: true,
        ),
      );
    }
    Get.offAll(() => HomePage());
  }
}
