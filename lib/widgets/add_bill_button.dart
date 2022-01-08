import 'package:flutter/material.dart';
import '../service/theme_color_service.dart';
import 'package:hexcolor/hexcolor.dart';

class AddBill extends StatelessWidget {
  final String button_n;
  final Function()? onTap;

  const AddBill({Key? key, required this.button_n, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: HexColor("#03dac5"),
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 20,
              color: Color.fromRGBO(0, 0, 0, 0.16),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              button_n,
              style: AddBillButton,
            )
          ],
        ),
      ),
    );
  }
}
