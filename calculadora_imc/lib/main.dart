import 'package:flutter/material.dart';

void main(){
  runApp(
    MaterialApp(
      title: "Calculadora IMC",
      home: Home(),
    )
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  String _infoText = "Informe seus dados!";

  GlobalKey<FormState> _formKey = GlobalKey();

  void _resetFields(){
    _heightController.text = "";
    _weightController.text = "";
    _infoText = "Informe seus dados!";
  }

  void _calculate(){
    setState(() {
      double weight = double.parse(_weightController.text);
      double height = double.parse(_heightController.text) / 100;
      double imc = weight / (height * height);

      if(imc < 18.6)
        _infoText = "Abaixo do Peso (${imc.toStringAsPrecision(4)})";
      else if(imc >= 18.6 && imc < 24.9)
        _infoText = "Peso Ideal (${imc.toStringAsPrecision(4)})";
      else if(imc >= 24.9 && imc < 29.9)
        _infoText = "Levemente Acima do Peso (${imc.toStringAsPrecision(4)})";
      else if(imc >= 29.9 && imc < 34.9)
        _infoText = "Obesidade Grau I (${imc.toStringAsPrecision(4)})";
      else if(imc >= 34.9 && imc < 39.9)
        _infoText = "Obesidade Grau II (${imc.toStringAsPrecision(4)})";
      else if(imc >= 40)
        _infoText = "Obesidade Grau III (${imc.toStringAsPrecision(4)})";
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.person_outline,
                size: 120.0,
                color: Colors.green,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _weightController,
                decoration: InputDecoration(
                    labelText: "Peso (kg)",
                    labelStyle: TextStyle(
                        color: Colors.green
                    )
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 25.0),
                validator: (value) {
                  if(value.isEmpty)
                    return "Por favor insira seu peso";
                }
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: "Altura (cm)",
                  labelStyle: TextStyle(
                    color: Colors.green,
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 25.0),
                validator: (value) {
                  if(value.isEmpty)
                    return "Por favor insira sua altura";
                }
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Container(
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: (){
                      if(_formKey.currentState.validate())
                        _calculate();
                    },
                    child: Text(
                      "Calcular",
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white
                      ),
                    ),
                    color: Colors.green,
                  ),
                ),
              ),
              Text(
                "$_infoText",
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      )
    );
  }
}
