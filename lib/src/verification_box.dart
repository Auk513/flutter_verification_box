library flutter_verification_box;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_verification_box/src/verification_box_item.dart';

///
/// 验证码输入框
///
class VerificationBox extends StatefulWidget {
  VerificationBox(
      {this.count = 6,
      this.itemWidget = 45,
      this.onSubmitted,
      this.type = VerificationBoxItemType.box,
      this.decoration,
      this.focusDecoration,
      this.borderWidth = 2.0,
      this.borderRadius = 5.0,
      this.textStyle,
      this.focusBorderColor,
      this.borderColor,
      this.unfocus = true,
      this.autoFocus = true,
      this.showCursor = false,
      this.cursorWidth = 2,
      this.cursorColor,
      this.cursorIndent = 10,
      this.cursorEndIndent = 10});

  ///
  /// 几位验证码，一般6位，还有4位的
  ///
  final int count;

  ///
  /// 没一个item的宽
  ///
  final double itemWidget;

  ///
  /// 输入完成回调
  ///
  final ValueChanged? onSubmitted;

  ///
  /// 每个item的装饰类型，[VerificationBoxItemType]
  ///
  final VerificationBoxItemType type;

  ///
  /// 每个item的样式
  ///
  final Decoration? decoration;

  ///
  /// 每个item的获取焦点样式
  ///
  final Decoration? focusDecoration;

  ///
  /// 边框宽度
  ///
  final double borderWidth;

  ///
  /// 边框颜色
  ///
  final Color? borderColor;

  ///
  /// 获取焦点边框的颜色
  ///
  final Color? focusBorderColor;

  ///
  /// [VerificationBoxItemType.box] 边框圆角
  ///
  final double borderRadius;

  ///
  /// 文本样式
  ///
  final TextStyle? textStyle;

  ///
  /// 输入完成后是否失去焦点，默认true，失去焦点后，软键盘消失
  ///
  final bool unfocus;

  ///
  /// 是否自动获取焦点
  ///
  final bool autoFocus;

  ///
  /// 是否显示光标
  ///
  final bool showCursor;

  ///
  /// 光标颜色
  ///
  final Color? cursorColor;

  ///
  /// 光标宽度
  ///
  final double cursorWidth;

  ///
  /// 光标距离顶部距离
  ///
  final double cursorIndent;

  ///
  /// 光标距离底部距离
  ///
  final double cursorEndIndent;

  @override
  State<StatefulWidget> createState() => _VerificationBox();
}

class _VerificationBox extends State<VerificationBox> {
  late TextEditingController _controller;

  late FocusNode _focusNode;

  List _contentList = [];

  @override
  void initState() {
    List.generate(widget.count, (index) {
      _contentList.add('');
    });
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
    debugPrint('Focus changed: ${_focusNode.hasFocus}');
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('Before focus request: ${_focusNode.hasFocus}');
        FocusScope.of(context).requestFocus(_focusNode);
        debugPrint('After focus request: ${_focusNode.hasFocus}');
        setState(() {});
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.count, (index) {
              return Container(
                width: widget.itemWidget,
                child: VerificationBoxItem(
                  data: _contentList[index],
                  focused:
                      _focusNode.hasFocus && _controller.text.length == index,
                  textStyle: widget.textStyle,
                  type: widget.type,
                  decoration: widget.decoration,
                  focusDecoration: widget.focusDecoration,
                  borderRadius: widget.borderRadius,
                  borderWidth: widget.borderWidth,
                  borderColor: (_controller.text.length == index
                          ? widget.focusBorderColor
                          : widget.borderColor) ??
                      widget.borderColor,
                  showCursor: widget.showCursor &&
                      _focusNode.hasFocus &&
                      _controller.text.length == index,
                  cursorColor: widget.cursorColor,
                  cursorWidth: widget.cursorWidth,
                  cursorIndent: widget.cursorIndent,
                  cursorEndIndent: widget.cursorEndIndent,
                ),
              );
            }),
          )),
          _buildTextField(),
        ],
      ),
    );
  }

  ///
  /// 构建TextField
  ///
  _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
      ),
      cursorWidth: 0,
      autofocus: widget.autoFocus,
      inputFormatters: [
        FilteringTextInputFormatter(RegExp("[0-9]"), allow: true),
      ],
//      高版本flutter出现报错，没有此类型，用Filtering替换即可
//      WhitelistingTextInputFormatter(RegExp("[0-9]")),

      maxLength: widget.count,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required bool isFocused,
        required int? maxLength,
      }) {
        return Text('');
      },
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.transparent),
      onChanged: _onValueChange,
    );
  }

  _onValueChange(value) {
    for (int i = 0; i < widget.count; i++) {
      if (i < value.length) {
        _contentList[i] = value.substring(i, i + 1);
      } else {
        _contentList[i] = '';
      }
    }
    setState(() {});

    if (value.length == widget.count) {
      if (widget.unfocus) {
        _focusNode.unfocus();
      }
      widget.onSubmitted?.call(value);
    }
  }
}
