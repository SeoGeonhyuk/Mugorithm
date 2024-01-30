import 'package:flutter/material.dart';
import 'package:mugorithm/page/all_music_page.dart';
import 'package:mugorithm/page/route_page.dart';
import 'package:mugorithm/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  // form 상태관리
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // inpus 값 받아오기
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // provider생성
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Mugorithm',
          style: TextStyle(
            color: Colors.indigoAccent,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              height: 350,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                      offset: Offset(2.0, 2.0)),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                  ),
                  Center(
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.indigoAccent,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                  ),
                  Form(
                    key: _formkey,
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.grey,
                        inputDecorationTheme: InputDecorationTheme(
                          labelStyle: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.indigoAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userEmailController,
                            decoration:
                                InputDecoration(labelText: 'User Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          TextFormField(
                            controller: _userPasswordController,
                            decoration:
                                InputDecoration(labelText: 'User Password'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  ButtonTheme(
                    minWidth: 60,
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () async {
                        print(_userEmailController.text);
                        print('\n');
                        print(_userPasswordController.text);

                        userProvider.registerUser(_userEmailController.text,
                            _userPasswordController.text);

                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.indigoAccent,
                        ),
                      ),
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
