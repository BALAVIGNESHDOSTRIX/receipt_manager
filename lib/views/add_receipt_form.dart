import 'dart:io';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import '../service/theme_color_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import './home_page.dart';
import '../tools/file_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/add_bill_button.dart';
import '../dbhandlers/sql.dart';
import './home_page.dart';
import '../tools/file_manager.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AddBillInputForm extends StatefulWidget {
  const AddBillInputForm({Key? key}) : super(key: key);

  @override
  _AddBillInputFormState createState() => _AddBillInputFormState();
}

class _AddBillInputFormState extends State<AddBillInputForm> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController title_controller = TextEditingController();
  final TextEditingController date_controller = TextEditingController();
  String dateString = DateFormat("dd-MM-yyyy").format(DateTime.now());
  String inputfilename = '';
  bool createDetector = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _Appbar(),
      backgroundColor: Appbackgrounds,
      body: Container(
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Add Receipt",
              style: AddBillFormTitle,
            ),
            _AddTextInputWidget("Title", "Enter the Bill Name",
                title_controller, false, context),
            _AddTextInputWidget("Date", DateFormat.yMd().format(_selectedDate),
                date_controller, true, context),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Bill',
                    style: AddBillFormsubTitle,
                  ),
                  inputfilename == ''
                      ? Container(
                          height: 40,
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.only(
                            left: 30,
                            right: 30,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              GestureDetector(
                                onTap: () {
                                  _openFileExplorer();
                                },
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  color: AddBillC,
                                  size: 20,
                                ),
                              ),
                              Expanded(child: Container()),
                              Expanded(child: Container()),
                              GestureDetector(
                                onTap: () {
                                  _openImageCamera();
                                },
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: AddBillC,
                                  size: 20,
                                ),
                              ),
                              Expanded(child: Container()),
                            ],
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 30,
                          ),
                          child: Container(
                            child: Row(
                              children: [
                                Container(
                                  child: Text(inputfilename.substring(0, 35)),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      () async {
                                        int x = await DeleteFile(
                                            this.inputfilename);
                                        print(x);
                                      }();

                                      setState(() {
                                        this.inputfilename = '';
                                      });
                                    },
                                    child: Container(
                                      child: Icon(Icons.clear,
                                          color: Colors.redAccent),
                                    ))
                              ],
                            ),
                          )),
                  Container(
                    height: 40,
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.only(
                      left: 2,
                      right: 2,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        this.inputfilename != '' &&
                                this.title_controller.text != ''
                            ? AddBill(
                                button_n: "Create Receipt",
                                onTap: () async {
                                  await InitDatabase();
                                  if (title_controller.text != '' &&
                                      inputfilename != '') {
                                    var insv = await InsertReceipt(
                                        title_controller.text,
                                        dateString,
                                        this.inputfilename);
                                    if (insv != 0) {
                                      this.createDetector = true;
                                      Get.offAll(RootHomePage());
                                    }
                                  }
                                },
                              )
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _getDate(context) async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1997),
        lastDate: DateTime(2221));

    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
        dateString = DateFormat("dd-MM-yyyy").format(_selectedDate);
      });
    }
  }

  _Appbar() {
    return AppBar(
      title: Text('Receipt Manager'),
      backgroundColor: HexColor("#6737b8"),
      leading: GestureDetector(
        onTap: () async {
          if (!this.createDetector && this.inputfilename != '') {
            var res = await DeleteFile(this.inputfilename);
            if (res == 2) {
              print("deleted..");
            } else {}
          }
          Get.back();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
      // centerTitle: true,
    );
  }

  _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],
    );
    if (result != null) {
      PlatformFile uplfile = result.files.first;
      final newfile = await SaveFilePermenately(uplfile);
      setState(() {
        this.inputfilename = newfile;
      });
    } else {
      // User canceled the picker
    }
  }

  _openImageCamera() async {
    final _ImagePicker = ImagePicker();
    final _image = await _ImagePicker.getImage(source: ImageSource.camera);

    final newfile = await SaveImagePermenately(_image);
    print(newfile.path);
    setState(() {
      this.inputfilename = basename(newfile.path);
    });
  }

  _AddTextInputWidget(String title, String hint,
      TextEditingController controller, bool widget, context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AddBillFormsubTitle,
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.only(
              left: 14,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: widget != false ? true : false,
                    autofocus: false,
                    autocorrect: true,
                    controller: controller,
                    // maxLength: 16,
                    style: AddBillFormsContent,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AddBillFormsubTitle,
                        border: InputBorder.none),
                  ),
                ),
                widget == false
                    ? Container()
                    : Container(
                        child: IconButton(
                          icon: Icon(Icons.calendar_today_rounded),
                          color: AddBillC,
                          onPressed: () {
                            _getDate(context);
                          },
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
