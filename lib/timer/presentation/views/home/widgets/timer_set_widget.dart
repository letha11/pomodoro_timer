import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/timer/timer_bloc.dart';

class TimerSetForm extends StatefulWidget {
  const TimerSetForm({super.key});

  @override
  State<TimerSetForm> createState() => _TimerSetFormState();
}

class _TimerSetFormState extends State<TimerSetForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pomodoroTimeController = TextEditingController();
  final TextEditingController _breakTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: NumberTextFormField(
                    label: 'Pomodoro Time',
                    controller: _pomodoroTimeController
                      ..text = (context.read<TimerBloc>().state as TimerLoaded)
                          .timer
                          .pomodoroTime
                          .toString(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: NumberTextFormField(
                    label: 'Break Time',
                    controller: _breakTimeController
                      ..text = (context.read<TimerBloc>().state as TimerLoaded)
                          .timer
                          .breakTime
                          .toString(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );

                  context.read<TimerBloc>().add(
                        TimerSet(
                          pomodoroTime: int.parse(_pomodoroTimeController.text),
                          breakTime: int.parse(_breakTimeController.text),
                        ),
                      );
                }
              },
              child: const Text('Set Timer'),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberTextFormField extends StatelessWidget {
  const NumberTextFormField({super.key, required this.label, this.controller});

  final String label;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(label),
      ),
      validator: (value) {
        if (value.isNull || value!.isEmpty) {
          return 'Field cannot be empty.';
        }

        return null;
      },
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
    );
  }
}

extension XString on String? {
  bool get isNull => this == null;
}

class Validator {
  static String? validateNull(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
