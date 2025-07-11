import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/settings/widget/language_select_bottomsheet.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/reset_password_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    Get.find<LocalizationController>().setInitialIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String languageName = '';
    AppConstants.languages.any((element) {
      if (element.languageCode ==
          Get.find<LocalizationController>().locale.languageCode) {
        languageName = element.languageName;
        return true;
      }
      return false;
    });
    return Scaffold(
        body: BodyWidget(
      appBar: AppBarWidget(title: 'settings'.tr, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSize,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                border: Border.all(
                    color: Theme.of(context).primaryColor, width: .5)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Image.asset(Images.languageSetting,
                        scale: 2,
                        color:
                            Theme.of(context).buttonTheme.colorScheme!.scrim),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Text('language'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        )),
                  ]),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: false,
                        enableDrag: false,
                        backgroundColor: Theme.of(context).cardColor,
                        context: context,
                        builder: (context) {
                          return const LanguageSelectBottomSheet();
                        },
                      );
                    },
                    child: Row(children: [
                      Text(languageName,
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(
                        width: Dimensions.paddingSizeExtraSmall,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: Dimensions.fontSizeLarge,
                      )
                    ]),
                  ),
                ]),
          ),
          // const SizedBox(
          //   height: Dimensions.paddingSize,
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(Dimensions.paddingSize),
          //       border: Border.all(
          //           color: Theme.of(context).primaryColor, width: .5)),
          //   child: Row(
          //     children: [
          //       Expanded(
          //           child: ListTile(
          //         title: Text('theme'.tr,
          //             style: textRegular.copyWith(
          //               color: Theme.of(context).textTheme.bodyLarge!.color,
          //             )),
          //         leading: Image.asset(Images.themeLogo,
          //             width: 20,
          //             color: Theme.of(context).buttonTheme.colorScheme!.scrim),
          //       )),
          //       GetBuilder<ThemeController>(builder: (themeController) {
          //         return Padding(
          //           padding: const EdgeInsets.only(right: 8.0),
          //           child: FlutterSwitch(
          //             value: themeController.darkTheme,
          //             onToggle: (value) {
          //               themeController.changeThemeSetting(value);
          //             },
          //             width: 60,
          //             height: 30,
          //             activeIcon: Image.asset(Images.darkThemeIcon,
          //                 color: Theme.of(context).primaryColor),
          //             activeToggleColor:
          //                 Theme.of(context).primaryColorDark.withOpacity(0.25),
          //             inactiveToggleColor: Theme.of(context).primaryColorDark,
          //             inactiveIcon: Image.asset(Images.lightThemeIcon),
          //             inactiveColor: Colors.grey.withOpacity(0.25),
          //             activeColor:
          //                 Theme.of(context).primaryColorDark.withOpacity(0.25),
          //           ),
          //         );
          //       })
          //     ],
          //   ),
          // ),
          ListTile(
            onTap: () => Get.to(() => const ResetPasswordScreen(
                fromChangePassword: true, phoneNumber: '')),
            title: Text('change_password'.tr,
                style: textMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color)),
            leading: Image.asset(Images.password,
                width: 20, height: 20, color: Theme.of(context).primaryColor),
          ),
        ]),
      ),
    ));
  }
}
