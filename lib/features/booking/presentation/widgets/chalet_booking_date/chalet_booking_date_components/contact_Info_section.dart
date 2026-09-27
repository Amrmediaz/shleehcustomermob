import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';


/// Contact info card: email (to receive the booking) + optional notes.
class ContactInfoSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController notesController;
  final RegExp emailRegExp;
  final void Function(String)? onEmailChanged;

  const ContactInfoSection({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.notesController,
    required this.emailRegExp,
    this.onEmailChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "بيانات التواصل",
                    style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.55)
                        .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.contact_mail_rounded, color: primaryColor, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "سيتم إرسال تفاصيل الحجز إلى هذا البريد الإلكتروني",
                style: TextStyles.textStyleHelper(context, scaleFactor: 0.6)
                    .copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: emailController,
                hint: "البريد الإلكتروني",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return "الرجاء إدخال البريد الإلكتروني";
                  if (!emailRegExp.hasMatch(trimmed)) return "صيغة البريد الإلكتروني غير صحيحة";
                  return null;
                },
                onChanged: onEmailChanged,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: notesController,
                hint: "ملاحظات إضافية (اختياري)",
                icon: Icons.edit_note_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Styled RTL text field used across the booking contact-info form.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.end,
      textDirection: TextDirection.rtl,
      style: TextStyles.textStyleBody(context),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyles.textStyleBody(context).copyWith(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}