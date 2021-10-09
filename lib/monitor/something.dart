import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'database.dart';

class just_Try extends StatefulWidget {
  const just_Try({Key? key}) : super(key: key);

  @override
  _just_TryState createState() => _just_TryState();
}

class _just_TryState extends State<just_Try>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration duration = const Duration(seconds: 1);
  Duration durMin = const Duration(minutes:1);
  String dateTime = DateTime.now().toString();
  String dealerName = "None";
  var down = FontAwesomeIcons.sortDown;
  final formKey = GlobalKey<FormState>();
  TextEditingController dealerController = TextEditingController();
  TextEditingController nos20 = TextEditingController();
  TextEditingController nos1 = TextEditingController();
  TextEditingController nos500 = TextEditingController();
  TextEditingController nos300 = TextEditingController();
  TextEditingController litr20 = TextEditingController();
  TextEditingController litr1 = TextEditingController();
  TextEditingController mL500 = TextEditingController();
  TextEditingController mL300 = TextEditingController();
  TextEditingController paidController = TextEditingController();
  var MainDealers = [];

  var amount20;
  var amount1;
  var amount500;
  var amount300;
  num todaySale = 0;
  num totalAmount = 0;
  var textFieldHeight = 30.0;
  List<PopupMenuItem> popupItems = [
    PopupMenuItem(
      child: Text("Dealer Name"),
      value: 0,
    ),
  ];

  adder(String name) {
    popupItems.add(PopupMenuItem(
      onTap: () {
        dealerName = name;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          IconButton(
            icon: const Icon(Icons.remove_outlined,color: Colors.red,),
            onPressed: (){
              print(rep);
              FirebaseFirestore.instance.collection("Dealers").get().then((value){
                for(int i =0; i<value.docs.length;i++){
                  if(name == value.docs[i]["Dealer Name"]){
                    value.docs[i].reference.delete();
                  }
                }
              }).whenComplete(() {
                print("This is dealer List: $rep");
                if(rep.contains(name)){
                  var pos = rep.indexOf(name);
                  print(pos);
                  rep.removeAt(pos);
                  popupItems.removeAt(pos+1);
                  print(popupItems);
                }
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
      value: popupItems.length,
    ));
  }

  timeUpdater() {
    Timer.periodic(duration, (Timer t) {
      setState(() {
        dateTime = DateTime.now().toString();
      });
    });
    Timer.periodic(const Duration(days:1),(Timer t){
      setState((){
       if(todaySale != 0){
         FirebaseFirestore.instance.collection("Daily Sales").doc(dateTime).set({
           "Total Sale":todaySale,
         });
       }
        todaySale=0;
      });
    });
  }



  priceCalc() {
    setState(() {
      if (nos20.text != "" && litr20.text != "") {
        amount20 = (int.parse(nos20.text)) * (int.parse(litr20.text));
      } else {
        amount20 = 0;
      }
      if (nos1.text != "" && litr1.text != "") {
        amount1 = (int.parse(nos1.text)) * (int.parse(litr1.text));
      } else {
        amount1 = 0;
      }
      if (nos500.text != "" && mL500.text != "") {
        amount500 = (int.parse(nos500.text)) * (int.parse(mL500.text));
      } else {
        amount500 = 0;
      }
      if (nos300.text != "" && mL300.text != "") {
        amount300 = (int.parse(nos300.text)) * (int.parse(mL300.text));
      } else {
        amount300 = 0;
      }
      totalAmount = amount20 + amount1 + amount300 + amount500;
    });
    print(totalAmount);
  }
  List rep = [];
  var c =0;
  totalUpdater() {
    setState(() {
      FirebaseFirestore.instance.collection("Amman Aqua").get().then((value) {
        print(value.docs[0]["Total Amount"].runtimeType);
        print(value.docs.length);
        for (int i = 0; i < value.docs.length; i++) {
          if(value.docs[i]["Time"].toString().substring(8,10) == DateTime.now().toString().substring(8,10)){
            todaySale = todaySale + value.docs[i]["Total Amount"];
          }else{
            todaySale = todaySale + 0;
          }
        }
        FirebaseFirestore.instance.collection("Dealers").get().then((value) {
          for(int i = 0; i< value.docs.length; i++){
            if(rep.contains(value.docs[i]["Dealer Name"])){}else{
              rep.add(value.docs[i]["Dealer Name"]);
              adder(value.docs[i]["Dealer Name"]);
            }
          }
        });
      });
    });
  }

  @override
  void initState() {
    timeUpdater();
    totalUpdater();
    print(totalAmount);
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Amman Aqua"),
          elevation: 10,
          leading: IconButton(
            icon: const Icon(Icons.system_update_alt),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => databaseCenter()));
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                dealerController.text = "";
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Add new Dealer"),
                        scrollable: true,
                        content: TextFormField(
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          controller: dealerController,
                          decoration: const InputDecoration(
                            hintText: "Enter Dealer's Name",
                            labelText: "Name",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Save"),
                            onPressed: () {
                              print(
                                  "Adding new Dealer: ${dealerController.text}");
                              if (dealerController.text == "") {
                                Navigator.of(context).pop();
                              } else {
                                FirebaseFirestore.instance.collection("Dealers").doc().set({
                                  "Dealer Name":dealerController.text,
                                });
                                if(rep.contains(dealerController.text)){}else{
                                  rep.add(dealerController.text);
                                  print("The list on adding dealer: $rep");
                                  adder(dealerController.text);
                                }
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.add),
              tooltip: "Add Dealer",
            )
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                //top:105,left: 125
                Positioned(child: Icon(down,size: 30,),top:MediaQuery.of(context).size.width/3.75,left: MediaQuery.of(context).size.width/3.1,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Date
                    Material(
                      elevation: 5,
                      child: Container(
                        // margin: const EdgeInsets.all(20),
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        color: CupertinoColors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Today's Sale",
                              style: TextStyle(color: Colors.amberAccent),
                            ),
                            Text(
                              " ₹ $todaySale",
                              style: TextStyle(color: Colors.amberAccent),
                            ),
                            Text(
                              dateTime.substring(0, 19),
                              style: const TextStyle(color: Colors.amberAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //Dealer Name
                    Row(
                      children: [
                        PopupMenuButton(
                          elevation: 10.0,
                          initialValue: dealerName,
                          child: Text("Dealer Names"),
                          itemBuilder: (context) => popupItems,
                        ),
                        Text(": $dealerName "),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height / 1.6,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.limeAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //Heading
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Litres"),
                              Text("Nos."),
                              Text("Amount"),
                            ],
                          ),
                          //20ltr
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: textFieldHeight,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  child: TextField(
                                    controller: litr20,
                                    onChanged: (value) {
                                      priceCalc();
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "20 Litre Can",
                                      labelStyle: labelStyler(),
                                      border: const OutlineInputBorder(),
                                    ),
                                  )),
                              Container(
                                height: textFieldHeight,
                                width: MediaQuery.of(context).size.width / 5.5,
                                child: TextField(
                                  onChanged: (value) {
                                    priceCalc();
                                  },
                                  controller: nos20,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: labelStyler(),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              amount20 == null ? Text("₹0") : Text("₹$amount20"),
                            ],
                          ),
                          //1ltr
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: textFieldHeight,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  child: TextField(
                                    onChanged: (val) {
                                      priceCalc();
                                    },
                                    controller: litr1,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "1 Litre Case",
                                      labelStyle: labelStyler(),
                                      border: const OutlineInputBorder(),
                                    ),
                                  )),
                              Container(
                                height: textFieldHeight,
                                width: MediaQuery.of(context).size.width / 5.5,
                                child: TextField(
                                  controller: nos1,
                                  onChanged: (val) {
                                    priceCalc();
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: labelStyler(),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              amount1 == null ? Text("₹0") : Text("₹$amount1"),
                            ],
                          ),
                          //500ml
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: textFieldHeight,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  child: TextField(
                                    onChanged: (val) {
                                      priceCalc();
                                    },
                                    controller: mL500,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "500 mL Case",
                                      labelStyle: labelStyler(),
                                      border: const OutlineInputBorder(),
                                    ),
                                  )),
                              Container(
                                height: textFieldHeight,
                                width: MediaQuery.of(context).size.width / 5.5,
                                child: TextField(
                                  onChanged: (val) {
                                    priceCalc();
                                  },
                                  controller: nos500,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: labelStyler(),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              amount500 == null ? Text("₹0") : Text("₹$amount500"),
                            ],
                          ),
                          //300ml
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: textFieldHeight,
                                  width: MediaQuery.of(context).size.width / 5.0,
                                  child: TextField(
                                    onChanged: (val) {
                                      priceCalc();
                                    },
                                    controller: mL300,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "300 mL Case",
                                      labelStyle: labelStyler(),
                                      border: const OutlineInputBorder(),
                                    ),
                                  )),
                              Container(
                                height: textFieldHeight,
                                width: MediaQuery.of(context).size.width / 5.5,
                                child: TextField(
                                  onChanged: (val) {
                                    priceCalc();
                                  },
                                  controller: nos300,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: labelStyler(),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              amount300 == null ? Text("₹0") : Text("₹$amount300"),
                            ],
                          ),
                          //Total Amt
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5.0,
                              ),
                              const Text("Total:"),
                              Text("₹$totalAmount"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Cancel and Submit Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              totalAmount =
                                  amount500 = amount300 = amount1 = amount20 = 0;
                              nos1.text =
                                  nos20.text = nos300.text = nos500.text = "";
                              litr1.text =
                                  litr20.text = mL500.text = mL300.text = "";
                              dealerName = "None";
                            });
                          },
                          child: const Text("Cancel"),
                        ),
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return dealerName == "None"
                                      ? AlertDialog(
                                          title: const Text("Choose a Dealer Name"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Choose"),
                                            ),
                                          ],
                                        )
                                      : AlertDialog(
                                          scrollable: true,
                                          title: const Text("Wat title?"),
                                          content: Column(
                                            children: [
                                              Text("Dealer Name: $dealerName"),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  "Total amount to be paid: $totalAmount"),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                height: textFieldHeight,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                                child: TextFormField(
                                                  validator: (value){
                                                    return value.toString().length <= 0 ? "Enter the amount to be paid":null;
                                                  },
                                                  key: formKey,
                                                  autovalidateMode:AutovalidateMode.onUserInteraction,
                                                  controller: paidController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    hintText: "Amount paid",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if(paidController.text!=""){
                                                      print("Entered");
                                                      setState(() {
                                                        print(
                                                            "This is todays sale: $todaySale");
                                                        todaySale = todaySale +
                                                            int.parse(
                                                                paidController.text);
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection("Amman Aqua")
                                                          .doc("${DateTime.now().toString().substring(0, 19)} $dealerName")
                                                          .set({
                                                        "Dealer Name": dealerName,
                                                        "id":DateTime.now().toString().substring(0, 19) +" "+dealerName,
                                                        "Time": DateTime.now().toString(),
                                                        "Total Amount": totalAmount,
                                                        "20 Litre Price": litr20.text,
                                                        "1 Litre Price": litr1.text,
                                                        "500 ml Price": mL500.text,
                                                        "300 ml Price": mL300.text,
                                                        "20 Litre cans": nos20.text,
                                                        "1 Litre can": nos1.text,
                                                        "500 ml can": nos500.text,
                                                        "300 ml can": nos300.text,
                                                        "Paid Amount":
                                                        paidController.text,
                                                        "Balance Amount":
                                                        totalAmount -
                                                            int.parse(
                                                                paidController
                                                                    .text),
                                                      }).whenComplete(() {
                                                        setState(() {
                                                          print(
                                                            totalAmount -
                                                                int.parse(
                                                                    paidController
                                                                        .text),
                                                          );

                                                          totalAmount = amount500 =
                                                              amount300 = amount1 =
                                                              amount20 = 0;
                                                          nos1.text = nos20.text =
                                                              nos300.text =
                                                              nos500.text = "";
                                                          litr1.text = litr20.text =
                                                              mL500.text =
                                                              mL300.text =
                                                              paidController
                                                                  .text = "";
                                                          dealerName = "None";
                                                        });
                                                        Navigator.of(context).pop();
                                                      });
                                                    }
                                                  },
                                                  child: const Text("Save"),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                });
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle labelStyler() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
  }
}
