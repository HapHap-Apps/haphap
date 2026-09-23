import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isRequired;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const HapHapTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isRequired = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<HapHapTextField> createState() => _HapHapTextFieldState();
}

class _HapHapTextFieldState extends State<HapHapTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.labelText,
            style: const AppTextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.greyDark,
            ),
            children: [
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: AppTextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),

        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscured : false,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: const AppTextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const AppTextStyle(
              color: AppColors.greyLight,
              fontSize: AppTypography.bodyLarge,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            isDense: true,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greyLight,
                width: AppSizes.hairline,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greyDark,
                width: AppSizes.thinStroke,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppSizes.hairline,
              ),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppSizes.thinStroke,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: AppSizes.iconMd,
              minHeight: AppSizes.iconMd,
            ),
            suffixIcon: widget.isPassword
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.greyDark,
                        size: AppSizes.iconMediumPlus,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
