import 'package:get/get.dart';
import '../views/home_page.dart';
import '../views/add_receipt_form.dart';

class PageRoutes {
  static final Screens = [
    GetPage(name: '/', page: () => RootHomePage()),
    GetPage(name: '/add_bill', page: () => AddBillInputForm())
  ];
}
