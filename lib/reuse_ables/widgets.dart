import 'package:flutter/material.dart';

import 'package:uchat365/colors.dart';

class InputField extends StatefulWidget {
  InputField(
      {Key? key,
      required this.label,
      required this.hint,
      required this.textInputType,
      this.isFieldDisable = true,
      this.enableSuffixIcon = false,
      this.obscureText = false,
      required this.prefixIcon,
      required this.controller,
      this.validate})
      : super(key: key);

  final String label;
  final String hint;
  final IconData prefixIcon;
  bool isFieldDisable;
  bool enableSuffixIcon;
  bool obscureText;
  TextInputType textInputType;
  final TextEditingController controller;
  String? Function(String?)? validate;
  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: TextFormField(
        keyboardType: widget.textInputType,
        cursorColor: blackColor,
        obscureText: widget.obscureText,
        style: TextStyle(color: blackColor),
        decoration: InputDecoration(
          isDense: true,
          enabled: widget.isFieldDisable ? false : true,
          // fillColor: purpleColor,
          // filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: blueColor, width: 2.0),
          ),

          hintText: widget.hint,
          // hintStyle: TextStyle(color: purpleColor),
          label: Text(
            widget.label,
            style: TextStyle(color: blueColor),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: blueColor,
          ),
          prefixText: '  ',
          suffixIcon: Visibility(
            visible: widget.enableSuffixIcon,
            child: GestureDetector(
              child: widget.obscureText
                  ? Icon(
                      Icons.visibility,
                      size: 18.0,
                      color: blueColor,
                    )
                  : Icon(
                      Icons.visibility_off,
                      size: 18.0,
                      color: blueColor,
                    ),
              onTap: () {
                setState(() {
                  widget.obscureText = !widget.obscureText;
                });
              },
            ),
          ),
        ),
        controller: widget.controller,
        validator: widget.validate,
      ),
    );
  }
}
