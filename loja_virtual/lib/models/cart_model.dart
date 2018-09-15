import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model{

  UserModel user;

  List<CartProduct> products = [];

  bool isLoading = false;
  static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

  CartModel(this.user){
    if(user.isLoggedIn())
      _loadItens();
  }

  void addCartItem(CartProduct cartProduct){
    products.add(cartProduct);
    
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").add(cartProduct.toMap())
        .then(
          (doc){
            print("Sucesso");
            cartProduct.cartId = doc.documentID;
          }
    ).catchError((error){print(error);});

    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct){

    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(cartProduct.cartId).delete();

    products.remove(cartProduct);

    notifyListeners();
  }

  void decProduct(CartProduct cartProduct){
    cartProduct.quantity--;
    
    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
      .document(cartProduct.cartId).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct){
    cartProduct.quantity++;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .document(cartProduct.cartId).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void _loadItens() async{
    QuerySnapshot query = await  Firestore.instance.collection("users")
        .document(user.firebaseUser.uid).collection("cart").getDocuments();
    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();
    notifyListeners();
  }
}