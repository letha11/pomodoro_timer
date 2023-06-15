import 'package:flutter/material.dart';

class StyledContainer extends StatelessWidget {
  const StyledContainer({
    super.key,
    this.text,
    this.child,
    this.width,
    this.textStyle,
    this.onTap,
    this.borderRadius = 0,
    this.padding = const EdgeInsets.only(bottom: 5),
    this.active = false,
  }) : assert(text != null ? child == null : child != null);

  final bool active;
  final double? width;
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: active ? Colors.white : Colors.black, // active
            offset: const Offset(2, 2),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(
          // color: Colors.black,
          color: active ? Colors.white : Colors.black,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Center(
              child: child ??
                  Text(
                    text!,
                    style: textStyle ??
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: active ? Colors.white : Colors.black,
                            ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
