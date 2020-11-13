import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_english/ui/component/customtextselect/custom_handle_painter.dart';
import 'package:learn_english/util/constant.dart';

const double _kHandleSize = 22.0;
// Minimal padding from all edges of the selection toolbar to all edges of the
// viewport.
const double _kToolbarScreenPadding = 8.0;
const double _kToolbarHeight = 44.0;
// Padding when positioning toolbar below selection.
const double _kToolbarContentDistanceBelow = _kHandleSize - 2.0;
const double _kToolbarContentDistance = 8.0;

class MyTextSelectController extends TextSelectionControls {

  void Function() clearSelection;

  MyTextSelectController(this.clearSelection);

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight) {
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: CustomPaint(
        painter: MyTextSelectionHandlePainter(
          color: Theme.of(context).textSelectionHandleColor,
        ),
      ),
    );

    // [handle] is a circle, with a rectangle in the top left quadrant of that
    // circle (an onion pointing to 10:30). We rotate [handle] to point
    // straight up or up-right depending on the handle type.
    switch (type) {
      case TextSelectionHandleType.left: // points up-right
        return Transform.rotate(
          angle: math.pi / 2.0,
          child: handle,
        );
      case TextSelectionHandleType.right: // points up-left
        return handle;
      case TextSelectionHandleType.collapsed: // points up
        return Transform.rotate(
          angle: math.pi / 4.0,
          child: handle,
        );
    }
    assert(type != null);
    return null;
  }

  @override
  Widget buildToolbar(BuildContext context, Rect globalEditableRegion, double textLineHeight, Offset selectionMidpoint, List<TextSelectionPoint> endpoints, TextSelectionDelegate delegate, ClipboardStatusNotifier clipboardStatus) {
    final TextEditingValue value = delegate.textEditingValue;
    final textValue = value.selection.textInside(value.text);
    // return AlertDialog(
    //   title: Text('Title: Ahihi', style: kTextStyleDefault,),
    //   content: Text(textValue, style: kTextStyleDefault,),
    //   actions: [FlatButton(onPressed: () {
    //     delegate.hideToolbar();
    //   }, child: Text('Close'),)],
    // );

    return GestureDetector(
      onTap: () {
        clearSelection();
        delegate.hideToolbar();
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: Center(
              child: Card(
                elevation: 10.0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    textValue,
                    style: kTextStyleDefault,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    switch (type) {
      case TextSelectionHandleType.left:
        return const Offset(_kHandleSize, 0);
      case TextSelectionHandleType.right:
        return Offset.zero;
      default:
        return const Offset(_kHandleSize / 2, -4);
    }
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return const Size(_kHandleSize, _kHandleSize);
  }

}