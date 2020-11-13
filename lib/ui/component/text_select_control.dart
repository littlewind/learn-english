import 'dart:math';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_english/util/constant.dart';

const double _kHandleSize = 22.0;

// Minimal padding from all edges of the selection toolbar to all edges of the
// viewport.
const double _kToolbarScreenPadding = 8.0;
const double _kToolbarHeight = 44.0;
// Padding when positioning toolbar below selection.
const double _kToolbarContentDistanceBelow = _kHandleSize - 2.0;
const double _kToolbarContentDistance = 8.0;

class MyTextSelectionControls extends ExtendedMaterialTextSelectionControls {
  MyTextSelectionControls(this.handleSelection, {this.clearSelection});

  void Function(String) handleSelection;

  void Function() clearSelection;

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return super.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return super.getHandleSize(textLineHeight);
  }

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset position,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ClipboardStatusNotifier clipboardStatus) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));

    // The toolbar should appear below the TextField
    // when there is not enough space above the TextField to show it.
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        (endpoints.length > 1) ? endpoints[1] : null;
    final double x = (endTextSelectionPoint == null)
        ? startTextSelectionPoint.point.dx
        : (startTextSelectionPoint.point.dx + endTextSelectionPoint.point.dx) /
            2.0;
    final double availableHeight = globalEditableRegion.top -
        MediaQuery.of(context).padding.top -
        _kToolbarScreenPadding;
    final double y = (availableHeight < _kToolbarHeight)
        ? startTextSelectionPoint.point.dy +
            globalEditableRegion.height +
            _kToolbarHeight +
            _kToolbarScreenPadding
        : startTextSelectionPoint.point.dy - textLineHeight * 2.0;
    final Offset preciseMidpoint = Offset(x, y);
/*
    return ConstrainedBox(
      constraints: BoxConstraints.tight(globalEditableRegion.size),
      child: CustomSingleChildLayout(
        // delegate: ExtendedMaterialTextSelectionToolbarLayout(
        //   MediaQuery
        //       .of(context)
        //       .size,
        //   globalEditableRegion,
        //   preciseMidpoint,
        // ),
        delegate: ExtendedMaterialTextSelectionToolbarLayout(
          preciseMidpoint,
          availableHeight,
          true,
        ),
        child: _TextSelectionToolbar(
          handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
          handleCopy: canCopy(delegate)
              ? () => handleCopy(delegate, clipboardStatus)
              : null,
          handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
          handleSelectAll:
              canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
          handleSearch: () {
            final TextEditingValue value = delegate.textEditingValue;
            final textValue = value.selection.textInside(value.text);
            handleSelection(textValue);
            delegate.hideToolbar();
            //clear selection
            delegate.textEditingValue = delegate.textEditingValue.copyWith(
                selection: TextSelection.collapsed(
                    offset: delegate.textEditingValue.selection.end));
          },
        ),
      ),
    );*/

    final TextEditingValue value = delegate.textEditingValue;
    final textValue = value.selection.textInside(value.text);
    // return AlertDialog(
    //   title: Text('Title: Ahihi', style: kTextStyleDefault,),
    //   content: Text(textValue, style: kTextStyleDefault,),
    //   actions: [FlatButton(onPressed: () {
    //     delegate.hideToolbar();
    //   }, child: Text('Close'),)],
    // );

    if (textValue.isEmpty || textValue == ' ') {
      print('empty selection');
      return Container();
    }
    print('selection text: \'$textValue\'');

    return GestureDetector(
      onTap: () {
        delegate.textEditingValue = TextEditingValue(
          text: delegate.textEditingValue.text,
          // selection: TextSelection(
          //   baseOffset: 0,
          //   extentOffset: 0,
          // ),
        );
        delegate.bringIntoView(delegate.textEditingValue.selection.extent);
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

/*@override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textHeight) {
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: Image.asset('images/logo.png'),
    );

    // [handle] is a circle, with a rectangle in the top left quadrant of that
    // circle (an onion pointing to 10:30). We rotate [handle] to point
    // straight up or up-right depending on the handle type.
    switch (type) {
      case TextSelectionHandleType.left: // points up-right
        return Transform.rotate(
          angle: pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.right: // points up-left
        return Transform.rotate(
          angle: pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.collapsed: // points up
        return handle;
    }
    assert(type != null);
    return null;
  }*/
}

/// Manages a copy/paste text selection toolbar.
class _TextSelectionToolbar extends StatelessWidget {
  const _TextSelectionToolbar({
    Key key,
    this.handleCopy,
    this.handleSelectAll,
    this.handleCut,
    this.handlePaste,
    this.handleSearch,
  }) : super(key: key);

  final VoidCallback handleCut;
  final VoidCallback handleCopy;
  final VoidCallback handlePaste;
  final VoidCallback handleSelectAll;
  final VoidCallback handleSearch;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    if (handleCut != null)
      items.add(FlatButton(
          child: Text(localizations.cutButtonLabel), onPressed: handleCut));
    if (handleCopy != null)
      items.add(FlatButton(
          child: Text(localizations.copyButtonLabel), onPressed: handleCopy));
    if (handlePaste != null)
      items.add(FlatButton(
        child: Text(localizations.pasteButtonLabel),
        onPressed: handlePaste,
      ));
    if (handleSelectAll != null)
      items.add(FlatButton(
          child: Text(localizations.selectAllButtonLabel),
          onPressed: handleSelectAll));

    if (handleSearch != null)
      items.add(FlatButton(child: Icon(Icons.search), onPressed: handleSearch));

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return Container(width: 0.0, height: 0.0);
    }

    return Material(
      elevation: 1.0,
      child: Wrap(children: items),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );
  }
}
