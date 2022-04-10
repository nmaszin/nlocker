import 'package:flutter/material.dart';

class DropDownList extends StatefulWidget {
  final List<String> options;

  const DropDownList({ Key? key, required this.options }): super(key: key);

  @override
  State<StatefulWidget> createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  late String? value = null;

  List<DropdownMenuItem<String>> getDropdownItems() => widget.options.map(
    (e) => DropdownMenuItem<String>(value: e, child: Text(e))
  ).toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          fillColor: Colors.white,
      ),
      hint: const Text('Choose Wi-Fi network'),
      value: value,
      items: getDropdownItems(),
      isExpanded: true,
      onChanged: (String? newValue) {
        setState(() {
          value = newValue!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Select a value';
        } else {
          return null;
        }
      },
    );
  }
}
