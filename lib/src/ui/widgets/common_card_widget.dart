import 'package:flutter/material.dart';

import '../../screen_util/app_widget_size.dart';
import '../../screen_util/screen_util.dart';

class CommonCardWidget extends StatefulWidget {
  final double topleftBorderRadias;
  final double topRightBorderRadias;
  final double bottomLeftBorderRadias;
  final double bottomRightBorderRadias;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final double? screenWidth;
  final Gradient? gradient;
  final Color? cardColor;
  final BorderSide? borderSide;
  final Widget widget;
  const CommonCardWidget(
      {super.key,
      this.topleftBorderRadias = AppWidgetSize.dimen_0,
      this.topRightBorderRadias = AppWidgetSize.dimen_0,
      this.bottomLeftBorderRadias = AppWidgetSize.dimen_0,
      this.bottomRightBorderRadias = AppWidgetSize.dimen_0,
      this.leftPadding = AppWidgetSize.dimen_0,
      this.topPadding = AppWidgetSize.dimen_0,
      this.rightPadding = AppWidgetSize.dimen_0,
      this.bottomPadding = AppWidgetSize.dimen_0,
      this.screenWidth,
      this.gradient,
      this.cardColor,
      this.borderSide,
      required this.widget});

  @override
  State<CommonCardWidget> createState() => _CommonCardWidgetState();
}

class _CommonCardWidgetState extends State<CommonCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth ?? AppWidgetSize.screenWidth(context),
      decoration: widget.cardColor != null
          ? ShapeDecoration(
              color: widget.cardColor,
              shape: RoundedRectangleBorder(
                side: widget.borderSide ??
                    BorderSide(width: 1, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.topleftBorderRadias.r),
                  topRight: Radius.circular(widget.topRightBorderRadias.r),
                  bottomLeft: Radius.circular(widget.bottomLeftBorderRadias.r),
                  bottomRight:
                      Radius.circular(widget.bottomRightBorderRadias.r),
                ),
              ),
            )
          : ShapeDecoration(
              gradient: widget.gradient ??
                  LinearGradient(
                    begin: const Alignment(1.00, -0.06),
                    end: const Alignment(-1, 0.06),
                    colors: [
                      Colors.white.withOpacity(0.8999999761581421),
                      Colors.white.withOpacity(0.6000000238418579)
                    ],
                  ),
              shape: RoundedRectangleBorder(
                side: widget.borderSide ??
                    const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.topleftBorderRadias.r),
                  topRight: Radius.circular(widget.topRightBorderRadias.r),
                  bottomLeft: Radius.circular(widget.bottomLeftBorderRadias.r),
                  bottomRight:
                      Radius.circular(widget.bottomRightBorderRadias.r),
                ),
              ),
            ),
      padding: REdgeInsets.only(
        left: widget.leftPadding,
        right: widget.rightPadding,
        top: widget.topPadding,
        bottom: widget.bottomPadding,
      ),
      child: widget.widget,
    );
  }
}
