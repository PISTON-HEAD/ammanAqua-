import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class databaseCenter extends StatefulWidget {
  const databaseCenter({Key? key}) : super(key: key);

  @override
  _databaseCenterState createState() => _databaseCenterState();
}

class _databaseCenterState extends State<databaseCenter> {
  int totalCount = 0;
  num changeBalance = 0;
  var accesser;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Total Sales"),
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Amman Aqua").snapshots(),
        builder: (context, snapshot) {
          FirebaseFirestore.instance.collection("Amman Aqua").get().then((value){
           setState(() {
             totalCount = value.docs.length;
             accesser = value.docs;
           });
          });
          return ListView.builder(
              itemCount:totalCount,
              itemBuilder: (context,index){
            return Container(
              margin: const EdgeInsets.all(10),
              color: Colors.yellow,
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                title: Text("${accesser[totalCount - index - 1]["Dealer Name"]}",style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),),
                isThreeLine: true,
                subtitle:  Text("${accesser[totalCount - index - 1]["Time"].toString().substring(0,16)}"),
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount: ${accesser[totalCount - index - 1]["Total Amount"]}",style: anountStyler(),),
                    Text("Paid Amount: ${accesser[totalCount - index - 1]["Paid Amount"]}",style: anountStyler(),),
                    Text("Bal. Amount: ${accesser[totalCount - index - 1]["Balance Amount"]}",style: anountStyler(),),

                  ],
                ),
                onTap: (){
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      scrollable: true,
                      title: Text(accesser[totalCount - index - 1]["Dealer Name"]),
                      content: Column(
                        children: [
                          Text("20 Litre Cans: ${accesser[totalCount - index - 1]["20 Litre cans"]}    Price:${accesser[totalCount - index - 1]["20 Litre Price"]}"),
                          Text("1 Litre Cans: ${accesser[totalCount - index - 1]["1 Litre can"]}    Price:${accesser[totalCount - index - 1]["1 Litre Price"]}"),
                          Text("500 ml Cans: ${accesser[totalCount - index - 1]["500 ml can"]}    Price:${accesser[totalCount - index - 1]["500 ml Price"]}"),
                          Text("300 ml Cans: ${accesser[totalCount - index - 1]["300 ml can"]}    Price:${accesser[totalCount - index - 1]["300 ml Price"]}"),
                          const SizedBox(height:20),
                          Text("Total Amount: ${accesser[totalCount - index - 1]["Total Amount"]}",style: anountStyler(),),
                          Text("Paid Amount: ${accesser[totalCount - index - 1]["Paid Amount"]}",style: anountStyler(),),
                          accesser[totalCount - index - 1]["Balance Amount"].toString() == "0"?Text("Amount Fully Paid"): Text("Bal. Amount: ${accesser[totalCount - index - 1]["Balance Amount"]}",style: anountStyler(),),
                        ],
                      ),
                      actions: [
                        accesser[totalCount - index - 1]["Balance Amount"].toString() != "0"?TextButton(
                          onPressed: (){
                            FirebaseFirestore.instance.collection("Amman Aqua").doc(accesser[totalCount - index - 1]["id"]).update({
                              "Balance Amount":changeBalance,
                              "Paid Amount":accesser[totalCount - index - 1]["Total Amount"],
                            }).whenComplete(() => Navigator.of(context).pop());
                          },
                          child:const Text("Clear Balance"),
                        ):TextButton(onPressed:(){Navigator.of(context).pop();},child:Text("Ok"),),
                      ],
                    );
                  });
                },
              ),
            );
          });
        }
      )
    );
  }

  TextStyle anountStyler() {
    return const TextStyle(
                    fontWeight: FontWeight.w700,
                  );
  }
}
