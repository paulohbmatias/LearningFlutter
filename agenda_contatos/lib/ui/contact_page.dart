import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget{
  final Contact contact;

  ContactPage({this.contact});

  ContactPageState createState()=>  ContactPageState();
}


class ContactPageState extends State<ContactPage> {
  bool _userEdit = false;
  Contact _editContact;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if(widget.contact == null)
      _editContact = Contact();
    else{
      _editContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editContact.name;
      _emailController.text = _editContact.email;
      _phoneController.text = _editContact.phone;
    }
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
      appBar: AppBar(
        title: Text(_editContact.name ?? "Novo contato"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          if(_editContact.name != null && _editContact.name.isNotEmpty){
            Navigator.pop(context, _editContact);
          }else{
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _editContact.img != null ? 
                    FileImage(File(_editContact.img)) :
                    AssetImage("images/person.png")
                  )
                ),
              ),
              onTap: (){
                ImagePicker.pickImage(source: ImageSource.camera).then((file){
                  if(file == null) return;
                  setState((){
                    _editContact.img = file.path;
                  });
                });
              },
            ),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(
                labelText: "Nome"
              ),
              onChanged: (text){
                _userEdit = true;
                setState((){
                  _editContact.name = text;
                });
              },
            ),
             TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email"
              ),
              onChanged: (text){
                _userEdit = true;
                _editContact.email = text;
              },
              keyboardType: TextInputType.emailAddress
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone"
              ),
              onChanged: (text){
                _userEdit = true;
                _editContact.phone = text;
              },
              keyboardType: TextInputType.number
            )
          ],
        ),
      ),
    )
    );
  }

  Future<bool> _requestPop(){
    if(_userEdit){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false);

    }else{
      return Future.value(true);
    }
  }
}