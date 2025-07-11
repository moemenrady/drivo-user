import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_map_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarPollOtpSentBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const CarPollOtpSentBottomSheet(
      {super.key,
      required this.firstRoute,
      required this.secondRoute,
      required this.expandableKey});

  @override
  State<CarPollOtpSentBottomSheet> createState() =>
      _CarPollOtpSentBottomSheetState();
}

class _CarPollOtpSentBottomSheetState extends State<CarPollOtpSentBottomSheet> {
  int currentState = 0;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarPollRideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return currentState == 0
            ? rideController.tripDetails != null
                ? Column(children: [
                    TollTipWidget(
                        title:
                            '${(rideController.remainingDistanceModel.isNotEmpty) ? (rideController.remainingDistanceModel[0].duration) ?? '0' : '0'} ${'away'.tr}'),
                    const SizedBox(
                      height: Dimensions.paddingSizeDefault,
                    ),
                    const OtpWidget(fromPage: true),
                    const ActivityScreenRiderDetails(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const EstimatedFareAndDistance(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    RouteWidget(
                        totalDistance: rideController
                                .tripDetails?.estimatedDistance
                                .toString() ??
                            '',
                        fromAddress:
                            rideController.tripDetails?.pickupAddress ?? "",
                        toAddress:
                            rideController.tripDetails?.destinationAddress ??
                                '',
                        extraOneAddress: widget.firstRoute,
                        extraTwoAddress: widget.secondRoute,
                        entrance: rideController.tripDetails?.entrance ?? ''),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    rideController.isLoading
                        ? Center(
                            child: SpinKitCircle(
                                color: Theme.of(context).primaryColor,
                                size: 40.0))
                        : Center(
                            child: SliderButton(
                              action: () {
                                currentState = 1;
                                widget.expandableKey.currentState?.expand();
                                setState(() {});
                              },
                              label: Text('cancel_ride'.tr,
                                  style: TextStyle(
                                      color: Get.isDarkMode
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).cardColor)),
                              dismissThresholds: 0.5,
                              dismissible: false,
                              shimmer: false,
                              width: 1170,
                              height: 40,
                              buttonSize: 40,
                              radius: 20,
                              icon: Center(
                                  child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor),
                                child: Center(
                                  child: Icon(
                                    Get.find<LocalizationController>().isLtr
                                        ? Icons.arrow_forward_ios_rounded
                                        : Icons.keyboard_arrow_left,
                                    color: Colors.grey,
                                    size: 20.0,
                                  ),
                                ),
                              )),
                              isLtr: Get.find<LocalizationController>().isLtr,
                              boxShadow: const BoxShadow(blurRadius: 0),
                              buttonColor: Colors.transparent,
                              backgroundColor: Theme.of(context).primaryColor,
                              baseColor: Theme.of(context).primaryColor,
                            ),
                          )
                  ])
                : const Column(children: [
                    BannerShimmer(),
                    BannerShimmer(),
                    BannerShimmer()
                  ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: Dimensions.paddingSizeSmall,
                  ),
                  Text(
                    'rider_is_coming'.tr,
                    style: textSemiBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(
                    height: Dimensions.paddingSizeSmall,
                  ),
                  CancellationRadioButton(isOngoing: false),
                  const SizedBox(
                    height: Dimensions.paddingSizeLarge,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ButtonWidget(
                              buttonText: 'no_continue_trip'.tr,
                              showBorder: true,
                              transparent: true,
                              backgroundColor: Theme.of(context).primaryColor,
                              borderColor: Theme.of(context).primaryColor,
                              textColor: Theme.of(context).cardColor,
                              radius: Dimensions.paddingSizeSmall,
                              onPressed: () {
                                currentState = 0;
                                setState(() {});
                              })),
                      const SizedBox(
                        width: Dimensions.paddingSizeSmall,
                      ),
                      Expanded(
                          child: ButtonWidget(
                              buttonText: 'submit'.tr,
                              showBorder: true,
                              transparent: true,
                              textColor:
                                  Get.isDarkMode ? Colors.white : Colors.black,
                              borderColor: Theme.of(context).hintColor,
                              radius: Dimensions.paddingSizeSmall,
                              onPressed: () {
                                Get.find<CarPollRideController>()
                                    .stopLocationRecord();
                                rideController
                                    .tripStatusUpdate(
                                        rideController.tripDetails!.id!,
                                        'cancelled',
                                        'ride_request_cancelled_successfully',
                                        Get.find<TripController>()
                                            .rideCancellationReasonList!
                                            .data!
                                            .acceptedRide![Get.find<
                                                TripController>()
                                            .rideCancellationCauseCurrentIndex])
                                    .then((value) {
                                  if (value.statusCode == 200) {
                                    Get.find<CarpollMapController>()
                                        .notifyMapController();
                                    Get.find<BottomMenuController>()
                                        .navigateToDashboard();
                                  }
                                });
                              })),
                    ],
                  )
                ],
              );
      });
    });
  }
}
