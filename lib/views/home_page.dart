import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../service/theme_color_service.dart';
import '../widgets/add_bill_button.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import '../dbhandlers/sql.dart';
import 'package:flutter_share/flutter_share.dart';
import '../tools/file_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RootHomePage extends StatefulWidget {
  const RootHomePage({Key? key}) : super(key: key);

  @override
  _RootHomePageState createState() => _RootHomePageState();
}

class _RootHomePageState extends State<RootHomePage> {
  DateTime _selectedDate = DateTime.now();

  List<String> _titlebill = <String>[];
  List<String> _filename = <String>[];
  List<String> _datebill = <String>[];
  List<String> _mimetype = <String>[];
  List<String> _docname = <String>[];
  List<int> _billunqid = <int>[];
  int _currentIndex = 0;
  var customIcon = Icons.search;
  bool search_status = false;
  Widget Customsearchbar = Text('Receipt Manager');
  int total_bill_size = 0;
  int starting_index = 0;
  int ending_index = 10;
  ScrollController _listviewController = ScrollController();

  @override
  void initState() {
    super.initState();
    () async {
      this._selectedDate = DateTime.now();
      await InitDatabase();
      await DeleteCache();

      await _getBillByDate(DateFormat("dd-MM-yyyy").format(this._selectedDate));
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _Appbar(),
        backgroundColor: Appbackgrounds,
        body: _getBodyNavbarItem_1(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.receipt, color: HexColor("#03dac5")),
              title: Text(
                'Receipt',
                style: TextStyle(color: Colors.black),
              ),
            ),
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: HexColor("#03dac5"),
              ),
              title: Text('Search', style: TextStyle(color: Colors.black)),
            ),
          ],
        ));
  }

  _AddBillContainer() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 15),
      height: 150,
      color: HexColor("#6737b8"),
      child: Row(children: [
        Text(
          DateFormat.yMMMEd().format(DateTime.now()),
          style: AddBillDateStyle,
        ),
        Expanded(child: Container()),
        AddBill(
          button_n: "+ Add Receipt",
          onTap: () {
            Get.toNamed('/add_bill');
          },
        )
      ]),
    );
  }

  _Appbar() {
    return AppBar(
      backgroundColor: HexColor("#6737b8"),
      title: Customsearchbar,
      automaticallyImplyLeading: false,
      actions: [
        _currentIndex == 1
            ? IconButton(
                onPressed: () {
                  setState(() {
                    if (customIcon == Icons.search) {
                      customIcon = Icons.cancel;
                      Customsearchbar = ListTile(
                          leading: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 28,
                          ),
                          title: TextField(
                            onChanged: (String value) async {
                              if (value != '') {
                                setState(() {
                                  this.search_status = true;
                                });
                                var result = await getReceiptbyTitle(value);
                                await _getBillProcess(result);
                              } else {
                                await _getAllBillData();
                              }
                            },
                            decoration: InputDecoration(
                                hintText: 'Search Bill By name',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                                border: InputBorder.none),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ));
                    } else {
                      customIcon = Icons.search;
                      Customsearchbar = Text('Receipt Manager');
                    }
                  });
                },
                icon: Icon(customIcon),
              )
            : Container()
      ],
      centerTitle: _currentIndex == 1 ? true : false,
    );
  }

  _AppMonthYearPicker() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(color: HexColor("#03dac5"), boxShadow: [
        BoxShadow(
          offset: Offset(2, 2),
          blurRadius: 20,
          color: Color.fromRGBO(0, 0, 0, 0.16),
        )
      ]),
      child: ExpansionTile(
        title: Text(
          'Calendar',
          style: Calendartext,
        ),
        collapsedIconColor: Colors.black,
        children: [
          CalendarTimeline(
            showYears: true,
            initialDate: _selectedDate,
            firstDate: DateTime(1940, 01, 01),
            lastDate: DateTime(2200, 12, 31),
            onDateSelected: (date) {
              setState(() {
                this._selectedDate = date;
                () async {
                  var count = await getTotalItemLength(
                      DateFormat("dd-MM-yyyy").format(date));
                  setState(() {
                    this.starting_index = count.length > 1 ? count[0]['id'] : 0;
                  });
                  await _getBillByDate(DateFormat("dd-MM-yyyy").format(date));
                }();
              });
            },
            leftMargin: 20,
            monthColor: Colors.black,
            dayColor: Colors.black,
            dayNameColor: Colors.white,
            activeDayColor: Colors.white,
            activeBackgroundDayColor: HexColor("#6737b8"),
            dotsColor: Colors.white,
            locale: 'en',
          )
        ],
      ),
    );
  }

  // List Container
  _ListViewContainer() {
    return Expanded(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            controller: _listviewController,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: _titlebill.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(
                  left: 14,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Listcontains,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(2, 2),
                        blurRadius: 20,
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        // height: 50,
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        child: GestureDetector(
                          child: Icon(
                            IconsPredict(_mimetype[index]),
                            size: 30,
                            color: IconsColor(_mimetype[index]),
                          ),
                          onTap: () async {
                            await OpenFile.open(_filename[index]);
                          },
                        )),
                    Expanded(child: Container()),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(
                        _titlebill[index].length > 15
                            ? _titlebill[index].substring(0, 15)
                            : _titlebill[index],
                        style: BillTitle,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 5),
                      padding: EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () async {
                          await FlutterShare.shareFile(
                            title: _titlebill[index],
                            text: _titlebill[index],
                            filePath: _filename[index],
                          );
                        },
                        child: Icon(
                          FontAwesomeIcons.share,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        child: Icon(
                          Icons.delete_outline_outlined,
                          size: 30,
                          color: shareIconC,
                        ),
                        onTap: () async {
                          Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Delete Receipt",
                              desc:
                                  "This Action going to delete Receipt: ${_titlebill[index]} Permanently",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "DELETE",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    await _deleteById(
                                        _billunqid[index], _docname[index]);
                                    Navigator.pop(context);
                                  },
                                  width: 100,
                                )
                              ]).show();
                        },
                      ),
                    )
                  ],
                ),
              );
            }));
  }

  onTabTapped(int index) {
    if (index == 0) {
      () async {
        setState(() {
          _currentIndex = index;
          this.customIcon = Icons.search;
          this.Customsearchbar = Text("Receipt Manager");
          this._selectedDate = DateTime.now();
        });
        await _getBillByDate(
            DateFormat("dd-MM-yyyy").format(this._selectedDate));
      }();
    } else {
      () async {
        await _getAllBillData();
      }();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  _getBillProcess(var data) async {
    List<String> titlebill = [];
    List<String> datebill = [];
    List<String> mimetype = [];
    List<String> docname = [];
    List<int> billunique = [];
    List<String> filename = [];

    for (var i = 0; i < data.length; i++) {
      var filex = await ReturnFilePath(data[i]['recep_bill_path']);
      File new_file = File(filex);
      titlebill.add(data[i]['receipt_title']);
      datebill.add(data[i]['recep_bill_date']);
      mimetype.add(MimeType(filex));
      docname.add(data[i]['recep_bill_path']);
      billunique.add(data[i]['ID']);
      filename.add(new_file.path);
    }

    setState(() {
      this._titlebill = titlebill;
      this._datebill = datebill;
      this._mimetype = mimetype;
      this._docname = docname;
      this._billunqid = billunique;
      this._filename = filename;
    });
  }

  _getAllBillData() async {
    var data = await getAllReceiptBill();
    await _getBillProcess(data);
  }

  _getBillByDate(String date) async {
    var data = await getReceiptBillbyDate(date);
    await _getBillProcess(data);
  }

  _deleteById(var ids, String docn) {
    () async {
      var delf = await DeleteFile(docn);
      var data = await DeleteReceipt(ids);
      var dats = await getReceiptBillbyDate(
          DateFormat("dd-MM-yyyy").format(_selectedDate));
      await _getBillProcess(dats);
    }();
  }

  _getBodyNavbarItem_1(index) {
    if (index == 0) {
      return Stack(children: [
        Column(children: [
          Container(
            color: HexColor("#6737b8"),
            child: _AddBillContainer(),
          ),
          SizedBox(
            height: 18,
          ),
          _ListViewContainer()
        ]),
        Positioned(child: _AppMonthYearPicker(), top: 120, left: 10, right: 10)
      ]);
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: [_ListViewContainer()],
        ),
      );
    }
  }
}
