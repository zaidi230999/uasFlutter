import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mysql/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
 @override
 _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  TextEditingController nama= new TextEditingController();
  TextEditingController posisi= new TextEditingController();
 LoginStatus _loginStatus = LoginStatus.notSignIn;
 final _key = new GlobalKey<FormState>();

 bool _secureText = true;

 showHide() {
   setState(() {
     _secureText = !_secureText;
   });
 }

 check() {
   final form = _key.currentState;
   if (form.validate()) {
     form.save();
     login();
   }
 }

 login() async {
   final response = await http.post("https://zaidi123.000webhostapp.com//login.php",
       body: {"namaPegawai": nama.text, "posisiPegawai": posisi.text});
   final data = jsonDecode(response.body);
   int value = data['value'];
   String pesan = data['message'];
   String namaAPI = data['nama'];
   String posisiAPI = data['posisi'];
   String id = data['id'];
   if (value == 1) {
     setState(() {
       _loginStatus = LoginStatus.signIn;
       savePref(value, namaAPI, posisiAPI, id);
     });
     print(pesan);
   } else {
     print(pesan);
   }
 }

 savePref(int value, String nama, String posisi, String id) async {
   SharedPreferences preferences = await SharedPreferences.getInstance();
   setState(() {
     preferences.setInt("value", value);
     preferences.setString("npm", nama);
     preferences.setString("password", posisi);
     preferences.setString("id", id);
     preferences.commit();
   });
 }

 var value;
 getPref() async {
   SharedPreferences preferences = await SharedPreferences.getInstance();
   setState(() {
     value = preferences.getInt("value");

     _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
   });
 }

 signOut() async {
   SharedPreferences preferences = await SharedPreferences.getInstance();
   setState(() {
     preferences.setInt("value", null);
     preferences.commit();
     _loginStatus = LoginStatus.notSignIn;
   });
 }

 @override
 void initState() {
   // TODO: implement initState
   super.initState();
   getPref();
 }

 @override
 Widget build(BuildContext context) {
   switch (_loginStatus) {
     case LoginStatus.notSignIn:
     return Scaffold(
         appBar: AppBar(
           backgroundColor: Colors.green,
           title: Text("Login"),
         ),
         body: Form(
           key: _key,
           child: ListView(
             padding: EdgeInsets.all(16.0),
             children: <Widget>[
               TextFormField(
                 controller: nama,
                 validator: (e) {
                   if (e.isEmpty) {
                     return "Masukan Nama";
                   }
                 },
                 decoration: InputDecoration(
                   
                   labelText: "Nama",
                   hintText: "Masukan Nama"
                 ),
               ),
               TextFormField(
                 controller: posisi,
                 obscureText: _secureText,
                 decoration: InputDecoration(
                   labelText: "Posisi",
                   hintText: "Masukan Posisi",
                   suffixIcon: IconButton(
                     onPressed: showHide,
                     icon: Icon(_secureText
                         ? Icons.visibility_off
                         : Icons.visibility),
                   ),
                 ),
               ),
                new RaisedButton(
                child: new Text("Login"),
                  color: Colors.green,
                 onPressed: () {
                   check();
                 },
                 ),
               
             ],
           ),
         ),
       );
       
     case LoginStatus.signIn:
       return MyApp();
       
   }
 }
}