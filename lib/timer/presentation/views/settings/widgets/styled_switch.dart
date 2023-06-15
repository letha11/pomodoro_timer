import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class StyledSwitch extends StatefulWidget {
  const StyledSwitch({super.key, required this.onToggle});

  final void Function(bool) onToggle;

  @override
  State<StyledSwitch> createState() => _StyledSwitchState();
}

class _StyledSwitchState extends State<StyledSwitch> {
  bool _switchState = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black, // active
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: FlutterSwitch(
        value: _switchState,
        width: 45,
        height: 25,
        switchBorder: Border.all(color: Colors.black),
        activeColor: Colors.black,
        inactiveColor: Colors.white,
        toggleSize: 20.0,
        toggleBorder: Border.all(color: Colors.black),
        borderRadius: 30.0,
        // padding: 8.0,
        onToggle: (val) {
          setState(() {
            _switchState = val;
          });

          widget.onToggle(val);
        },
      ),
    );
  }
}
