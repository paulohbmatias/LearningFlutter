import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:loja_virtual/tiles/product_tile.dart';

class CategoryScreen extends StatelessWidget {

  final DocumentSnapshot _snapshot;

  CategoryScreen(this._snapshot);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_snapshot.data["title"]),
            centerTitle: true,
            bottom: TabBar(
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.list))
                ],
            ),
          ),
          body: FutureBuilder<QuerySnapshot>(
              future: Firestore.instance.collection("products").document(_snapshot.documentID).
                collection("itens").getDocuments(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                else{
                  return TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      GridView.builder(
                        padding: EdgeInsets.all(4.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index){
                          ProductData product = ProductData.fromDrocument(snapshot.data.documents[index]);
                          product.category = this._snapshot.documentID;
                          return ProductTile("grid", product);
                        }
                      ),
                      ListView.builder(
                        padding: EdgeInsets.all(4.0),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index){
                          ProductData product = ProductData.fromDrocument(snapshot.data.documents[index]);
                          product.category = this._snapshot.documentID;
                          return ProductTile("list", product);
                        },
                      )
                    ],
                  );
                }
              }
          )
        )
    );
  }
}
