import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light
);

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;


final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400]
);

Future<Null> _ensureLoggedIn() async{
  GoogleSignInAccount user = googleSignIn.currentUser;
  if(user == null)
    user = await googleSignIn.signInSilently();
  if(user == null)
    user = await googleSignIn.signIn();
  if(await auth.currentUser() == null){
    GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken
    );
  }

}

_handleSubmited(String text) async {
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgUrl}){
  Firestore.instance.collection("messages").add(
    {
      "text" : text,
      "imgUrl" : imgUrl,
      "senderName" : googleSignIn.currentUser.displayName,
      "senderPhotoUrl" : googleSignIn.currentUser.photoUrl
    }
  );
}
void main() async => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS ? 
        kIOSTheme : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget{
  ChatScreenState createState()=>  ChatScreenState();
}


class ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context){
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection("messages").snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index){
                          List r = snapshot.data.documents.reversed.toList();
                          return ChatMessage(r[index].data);
                        },
                      );
                  }
                }
              )
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor
              ),
              child: ThemeComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class ThemeComposer extends StatefulWidget{
  ThemeComposerState createState()=>  ThemeComposerState();
}


class ThemeComposerState extends State<ThemeComposer> {

  bool _isComposing = false;
  final textController = TextEditingController();

  _reset(){
    textController.clear();
    setState(() {
      _isComposing = false;
    });
    
  }
  @override
  Widget build(BuildContext context){
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).accentColor
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: Theme.of(context).platform == TargetPlatform.iOS ? 
          BoxDecoration(
            border: Border(top: BorderSide(
              color: Colors.grey[200]
            ))
          ) 
          : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async{
                  await _ensureLoggedIn();
                  File imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
                  if(imgFile == null) return;
                  StorageUploadTask task = FirebaseStorage.instance.ref().
                    child(googleSignIn.currentUser.id.toString() + DateTime.now().millisecondsSinceEpoch.toString()).
                    putFile(imgFile);
                  _sendMessage(imgUrl: (await task.future).downloadUrl.toString());
                },
              ),
            ),
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration.collapsed(hintText: "Enviar mensagem"),
                onChanged: (text){
                  setState(() {
                    _isComposing = text.length > 0;                    
                  });
                },
                onSubmitted: (text){
                  _handleSubmited(text);
                  _reset();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS 
                ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _isComposing ? (){
                    _handleSubmited(textController.text);
                    _reset();
                  } : null
                ) 
                : IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing ? (){
                    _handleSubmited(textController.text);
                    _reset();
                  } : null
                )
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data["senderName"],
                  style: Theme.of(context).textTheme.subhead,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: data["imgUrl"] != null ?
                    Image.network(data["imgUrl"], width: 250.0) : 
                    Text(data["text"]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}