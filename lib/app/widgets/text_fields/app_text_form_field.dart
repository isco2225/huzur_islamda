import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  const AppTextField(
    this.hintText, {
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.errorText,
    this.keyboardType,
    this.textEditingController,
    required this.showText,
    required this.hideText,
    this.autofillHints,
  });
  final FocusNode? focusNode;
  final String hintText;
  final bool isPassword;
  final bool isReadOnly;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final int? maxLines;
  final TextEditingController? textEditingController;
  final String showText;
  final String hideText;
  final List<String>? autofillHints;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        autofillHints: widget.autofillHints,
        controller: widget.textEditingController,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(
          labelText: widget.hintText,
          border: const OutlineInputBorder(),
          suffix: widget.isPassword
              ? GestureDetector(
                  onTap: () {
                    obscureText = !obscureText;
                    setState(() {});
                  },
                  child: Text(
                    obscureText ? widget.showText : widget.hideText,
                  ),
                )
              : null,
          errorText: widget.errorText,
        ),
        maxLines: widget.maxLines,
        readOnly: widget.isReadOnly,
        obscureText: widget.isPassword ? obscureText : false,
        onChanged: widget.onChanged,
      ),
    );
  }
}
