import 'package:flutter/material.dart';

import '../../screen_util/src/r_padding.dart';

class CommonTextWidget extends StatefulWidget {
  final double topPadding;
  final double bottomPadding;
  final double leftPadding;
  final double rightPadding;
  final String textString;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final double? fontSize;
  final double? linespace;
  final double? linesheight;

  final TextAlign? textAlign;
  final TextStyle? textStyle;
  const CommonTextWidget(
      {super.key,
      this.topPadding = 0,
      this.bottomPadding = 0,
      this.leftPadding = 0,
      this.rightPadding = 0,
      this.linesheight,
      required this.textString,
      this.fontWeight,
      this.fontColor,
      this.fontSize,
      this.linespace,
      this.textStyle,
      this.textAlign});

  @override
  State<CommonTextWidget> createState() => _CommonTextWidgetState();
}

class _CommonTextWidgetState extends State<CommonTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(
          top: widget.topPadding,
          bottom: widget.bottomPadding,
          left: widget.leftPadding,
          right: widget.rightPadding),
      child: Text(
        widget.textString,
        softWrap: true,
        textAlign: widget.textAlign,
        style: widget.textStyle ??
            TextStyle(
                letterSpacing: widget.linespace,
                height: widget.linesheight,
                fontWeight: widget.fontWeight,
                color: widget.fontColor,
                fontSize: widget.fontSize),
      ),
    );
  }
}
