import 'package:flutter/material.dart';

class TabControllerProvider extends ChangeNotifier {


  int _index = 0;


  int get currentIndex => _index;

  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

}
