import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:scoped_model/scoped_model.dart';

class CartProduct extends Model{
  String cartId;
  String category;
  String productId;
  int quantity;
  String size;

  ProductData productData;

  CartProduct();

  CartProduct.fromDocument(DocumentSnapshot snapshot){
    cartId = snapshot.documentID;
    category = snapshot.data["category"];
    productId = snapshot.data["productId"];
    quantity = snapshot.data["quantity"];
    size = snapshot.data["size"];
  }

  Map<String, dynamic> toMap(){
    return {
      "category": category,
      "productId": productId,
      "quantity": quantity,
      "size": size,
      //"product": productData.toResumedMap()
    };
  }
}
