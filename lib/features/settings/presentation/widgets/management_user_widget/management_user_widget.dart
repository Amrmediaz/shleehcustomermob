import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_profile.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/core/widgets/bottom_sheets.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/styles/text/text_style.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/snackbar_message.dart';
import '../../../../../../core/widgets/app_bar_back.dart';
import '../../../../../../core/widgets/text_form/password_widget.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';
import '../../../../../core/util/bottom_sheet_custom.dart';
import '../../../../authentication/login/presentation/bloc/login/login_event.dart';
import '../../../domain/entities/user.dart';
import '../../bloc/setting/setting_bloc.dart';
import 'delete_dialog_widget.dart';

class ManagementUserFormWidget extends StatefulWidget {
  final User user;

  ManagementUserFormWidget({
    required this.user,
  });
  @override
  State<ManagementUserFormWidget> createState() =>
      _ManagementUserFormWidgetState();
}

class _ManagementUserFormWidgetState extends State<ManagementUserFormWidget> {
  final _formKey = GlobalKey<FormState>();
  // Was a top-level global before — meant this "is the profile save in
  // flight" flag was shared across every instance of this widget, and
  // could get stuck true if the user navigated away mid-request. Now a
  // proper instance field that always starts fresh.
  bool _isSavingProfile = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBarBack(leadingWidgetAction: () {
                    Navigator.pop(context);
                  }),
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTextByKey(
                                    key: TranslationKey.keyAccountManagement),
                                style: TextStyles.textStyleHeadline(context)
                                    .copyWith(color: primaryColor),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormFieldWidget(
                                  name: getTextByKey(
                                      key: TranslationKey.keyFirstName),
                                  textInputType: TextInputType.name,
                                  maxLength: MAX_LENGTH_TEXT_Name,
                                  multiLines: false,
                                  controller: _firstNameController),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormFieldWidget(
                                  name: getTextByKey(
                                      key: TranslationKey.keyLastName),
                                  textInputType: TextInputType.text,
                                  maxLength: MAX_LENGTH_TEXT_Name,
                                  multiLines: false,
                                  controller: _lastNameController),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              BlocConsumer<SettingBloc, SettingState>(
                                  listener: (context, state) async {
                                if (state is UpdatedUserState) {
                                  _isSavingProfile = false;
                                  setState(() {});
                                  // The update only went to the server —
                                  // the locally cached profile (what the
                                  // home page greeting and the WhatsApp
                                  // message read via CasheFile.loadUser())
                                  // still held the old name until this ran,
                                  // which is why editing a name here never
                                  // showed up back on the home tab.
                                  await CasheFile.saveUser(UserProfile(
                                    id: widget.user.id,
                                    firstName: _firstNameController.text,
                                    lastName: _lastNameController.text,
                                    email: widget.user.email,
                                    phoneNumber: widget.user.phoneNumber,
                                    birthDate: widget.user.birthDate,
                                    userImage: widget.user.userImage,
                                    gender: widget.user.gender,
                                    password: widget.user.password,
                                    gouvernate: widget.user.governorate,
                                    state: widget.user.state,
                                    points: widget.user.points,
                                    createdDate: widget.user.createdDate,
                                  ));
                                  BottomSheetsCustom
                                      .showSuccessBottomWidgetDialog(
                                          context,
                                          getTextByKey(
                                              key: TranslationKey
                                                  .keySuccessUpdateProfile),
                                          "");
                                } else if (state is ErrorUpdateUserState) {
                                  _isSavingProfile = false;
                                  setState(() {});
                                  BottomSheetsCustom.showFailBottomWidgetDialog(
                                      context,
                                      getTextByKey(
                                          key: TranslationKey.keyError),
                                      "");
                                }
                              }, builder: (context, state) {
                                return ActionBtn(
                                    isLoading: _isSavingProfile,
                                    btnColor: primaryColor,
                                    onPressed: () {
                                      validateFormThenUpdate();
                                    },
                                    btnTitle: TranslationKey.keySaveData);
                              }, buildWhen: (previous, current) {
                                if (current is UpdatedUserState ||
                                    current is ErrorUpdateUserState) {
                                  return true;
                                } else {
                                  return false;
                                }
                              }),
                              const SizedBox(
                                height: 25,
                              ),
                              const Divider(
                                thickness: 1.5,
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Text(
                                getTextByKey(
                                    key: TranslationKey.keyDeleteAccount),
                                style: TextStyles.textStyleHeadline(context,
                                    titleSizeFactor: 0.6),
                              ),
                              Text(
                                getTextByKey(
                                    key: getTextByKey(
                                        key: TranslationKey
                                            .deleteTheAccountPermant)),
                                style: TextStyles.textStyleHelper(context),
                              ),
                              BlocConsumer<SettingBloc, SettingState>(
                                  listener: (context, state) async {
                                if (state is DeletedUserState) {
                                  await deleteUserAction();
                                } else if (state is ErrorDeletedUserState) {
                                  BottomSheetsCustom.showFailBottomWidgetDialog(
                                      context,
                                      getTextByKey(
                                          key: TranslationKey.keyError),
                                      "");
                                }
                              }, builder: (context, state) {
                                return ActionBtn(
                                    btnColor: Colors.grey.shade300,
                                    onPressed: () {
                                      CommonFunctions.showBottomWidgetDialog(
                                          context,
                                          Container(),
                                          DeleteDialog(
                                            userId: widget.user.id,
                                          ));
                                    },
                                    btnTitle:
                                        TranslationKey.keyDeleteMyAccount);
                              }, buildWhen: (previous, current) {
                                if (current is DeletedUserState ||
                                    current is UpdatedUserState) {
                                  return true;
                                } else {
                                  return false;
                                }
                              }),
                            ])
                      ],
                    ),
                  )
                ]),
          ),
        ));
  }

  deleteUserAction() async {
    Navigator.pop(context);
    BlocProvider.of<LoginBloc>(context).add( UserLoginInitialEvent());

    BottomSheetsCustom.showSuccessBottomWidgetDialog(
        context, getTextByKey(key: TranslationKey.keySuccessDeleteProfile), "");
    await CasheFile().setLogout(context);
  }

  void validateFormThenUpdate() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _isSavingProfile = true;
      setState(() {});
      BlocProvider.of<SettingBloc>(context).add(UpdateUserEvent({
        "id": widget.user.id,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "points": widget.user.points
      }));
    }
  }
}
