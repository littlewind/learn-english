import 'package:flutter/material.dart';
import 'package:learn_english/ui/component/customtextselect/custom_text_select_controller.dart';

class MyCustomText extends EditableText {
  void Function() clearSelection;

  MyCustomText(TextEditingController ctrl): super(selectionControls: MyTextSelectController().clearSelection , controller: ctrl, focusNode: FocusNode(), style: TextStyle(), cursorColor: Colors.blue, backgroundCursorColor: Colors.black);
}