import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

Color AddBillC = HexColor("#6737b8");
Color Appbackgrounds = Colors.white;
Color DateSeleC = HexColor("#17b978");
Color Listcontains = Colors.white;
Color DeleteIc = Colors.blue;
Color shareIconC = HexColor("#f3558e");

TextStyle get AddBillDateStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ));
}

TextStyle get AddBillDateTitle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  ));
}

TextStyle get Calendartext {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get AddBillButton {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get DateSelect {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black));
}

TextStyle get AddBillFormTitle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get AddBillFormsubTitle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get AddBillFormsContent {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get BillTitle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 20,
    color: HexColor("#424242"),
    fontWeight: FontWeight.w400,
  ));
}
