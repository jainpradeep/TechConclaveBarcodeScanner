import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));


void mainCopy() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}


class HomePageState extends State<HomePage> {
  bool kit = false;
  String result = "";
 final Xml2Json myTransformer = Xml2Json();
 final key = new GlobalKey<ScaffoldState>();
 String httpRes = "";
  TextEditingController phoneNumberController = new TextEditingController();
  
  setData ()
  {
    print("sdasdsa");
    return http.post( ('http://10.20.64.109:1026/Service1.asmx/updateKit'),
                              headers: {
                                "Content-Type": "application/x-www-form-urlencoded",
                                },
                              body: {
                                  "value" : kit == true ? "true" : "false",
                                  "validate" : phoneNumberController.text 
                              },
                              encoding: Encoding.getByName("utf-8"));
 }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
          httpRes = "";
          print(kit);
          result = qrResult;
          print(result);
          http.Response res = await setData();
          myTransformer.parse(res.body);
          var x =  (jsonDecode(jsonDecode(myTransformer.toParker())['string']))=='"success"';
          print(x);   
          if((jsonDecode(jsonDecode(myTransformer.toParker())['string']))=="success"){
                key.currentState.showSnackBar(new SnackBar(
                  content: new Text("Success"),
                ));
          }
          else{
              result = "Attendence not Submitted. Please try Again";
          }
        setState((){
        });

      } on PlatformException catch (ex) {
        if (ex.code == BarcodeScanner.CameraAccessDenied) {
          setState(() {
            result = "Camera permission was denied";
          });
        } else {
          setState(() {
            result = "Unknown Error $ex";
          });
        }
      } on FormatException {
        setState(() {
          result = "You pressed the back button before scanning anything";
        });
      } catch (ex) {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
      

}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.camera_alt)),    
                Tab(icon: Icon(Icons.account_box)),
              ],
            ),
            title: Text('Technical Conclave 2019'),
          ),
          body: TabBarView(
            children: [Scaffold(
               body: ListTile(
                  onTap:null,
                  leading: new CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: new IconButton(
                    icon: new Icon(MdiIcons.gift), 
                    onPressed: () { 
                      kit = true; 
                      
                      }
                    ),
                  ),
                  title:
                  
                  new Column(children:[ new Row(
                    children: <Widget>[
                      new Expanded(child: new Text("Kit")),
                      new Checkbox(value: kit, onChanged: (bool value) {
                        setState(() {
                          kit = value;
                        });
                      })
                   
                    ]),
                   Center(child: Text(httpRes))]) 
              ),
                floatingActionButton: FloatingActionButton.extended(
                  icon: Icon(Icons.camera_alt),
                  label: Text("Scan and submit"),
                  onPressed: _scanQR,
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
            ),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: Column(children: [
                ListTile(
                        leading: const Icon(Icons.person,
                          color: Colors.blue,
                        ),
                        title: new TextField(
                           controller: phoneNumberController,
                          decoration: new InputDecoration(
                            hintText: "Phone Number",
                          ),
                        ),
                ),
                  ListTile(
                    onTap:null,
                    leading: new CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: new IconButton(
                      icon: new Icon(MdiIcons.gift), 
                      onPressed: () { 
                        kit = true; 
                        }
                      ),
                    ),
                    title: new Row(
                      children: <Widget>[
                        new Expanded(child: new Text("Kit")),
                        new Checkbox(value: kit, onChanged: (bool value) {
                          setState(() {
                            kit = value;
                          });
                        })
                      ],
                    )
                  ),
                  MaterialButton(
                            child: new Text('Submit!',
                            style: TextStyle(
                            color: Colors.white,
                            decorationColor: Colors.red,
                            decorationStyle: TextDecorationStyle.wavy,
                          )),
                            color: Colors.blue,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          onPressed: ()async{
                            httpRes = "";
                            result = phoneNumberController.text;
                            http.Response res = await setData();
                            myTransformer.parse(res.body);
                           if((jsonDecode(myTransformer.toParker())['string'])=='"success"'){
                               var timer = new Timer(const Duration(milliseconds: 3000), mainCopy);
                              httpRes = "success";
                            }
                            else{
                                result = "Attendence not Submitted. Please try Again";
                            }
                            setState((){
                            });
                          },
                  ),Center(child: Text(httpRes))
                ]), 
              )
            ],
          ),
        ),
      ),
    );
  }
}
