import 'package:flutter/material.dart';

class FormCheckbox extends StatefulWidget {
  final Widget title;
  final bool required;

  const FormCheckbox({ Key? key, required this.title, this.required = false }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FormCheckbox();
  }
}

class _FormCheckbox extends State<FormCheckbox> {
  bool checked = false;

  Widget getValidationErrorWidget(state) {
    return Text(
      state.errorText ?? '',
      style: TextStyle(
        color: Theme.of(context).errorColor,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      builder: (state) => Column(
        children: <Widget>[
          CheckboxListTile(
            title: widget.title,
            value: checked,
            onChanged: (value) {
              setState(() {
                checked = !checked;
                state.didChange(checked);
              });
            },
          ),
          if (state.hasError) ...[
            getValidationErrorWidget(state)
          ]
        ],
      ),
      validator: (bool? value) {
        if (widget.required && (value == null || !value)) {
          return 'This checkbox must be checked';
        } else {
          return null;
        }
      },
    );
  }
}
