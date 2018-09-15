import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Count of peoples",
    home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _peoples = 0;
  String _infoText = "Pode entrar!";

  void changePeoples(int delta){
    setState(() {
      _peoples += delta;
      if(_peoples < 0)
        _infoText = "Mundo invertido?";
      else if(_peoples <= 10)
        _infoText = "Pode entrar!";
      else
        _infoText = "Lotado!";

    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "images/restaurant.jpg",
          fit: BoxFit.cover,
          height: 1000.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.start,
          //verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Text(
              "Pessoas: $_peoples",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "+1",
                      style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white
                      ),
                    ),
                    onPressed: () {
                      changePeoples(1);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "-1",
                      style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white
                      ),
                    ),
                    onPressed: (){
                      changePeoples(-1);
                    },
                  ),
                ),

              ],
            ),
            Text(
              "$_infoText",
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 30.0
              ),
            )
          ],
        )

      ],
    );
  }
}

