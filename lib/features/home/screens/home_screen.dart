import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/app_advertising.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/best_offers_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/coupon_home_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_map_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_my_address.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_referral_view_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/visit_to_mart_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/driver_request_dialog.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'good_morning'.tr;
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  bool clickedMenu = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Button position tracking for animation
  double _buttonTopPosition = 0.0;

  @override
  void initState() {
    super.initState();
    loadData();

    // Set initial button position
    _buttonTopPosition = Get.height * 0.5;

    // Add listener to track sheet position changes after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize scroll tracking after build is complete to avoid setState during build
      Get.find<LocationController>().initializeScrollTracking();

      // Set up sheet listener for bottom nav visibility control
      Get.find<LocationController>().setupSheetListener(_sheetController);

      // Listen to sheet changes and update button position
      _sheetController.addListener(() {
        if (_sheetController.isAttached && mounted) {
          _updateButtonPosition();
        }
      });
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // Simple button position update based on sheet size
  void _updateButtonPosition() {
    if (!mounted) return;

    // Use postFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Add small delay to ensure build is complete
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        double sheetSize = _sheetController.size;
        double screenHeight = Get.height;

        // Simple calculation: move button up as sheet expands
        // Sheet at 0.2 (collapsed) → button at 40% from top
        // Sheet at 0.9 (expanded) → button at 20% from top
        double newTop = screenHeight * (0.68 - sheetSize * 0.3);

        if (_buttonTopPosition != newTop) {
          setState(() {
            _buttonTopPosition = newTop;
          });
        }
      });
    });
  }

  Future<void> loadData({bool isReload = false}) async {
    if (isReload) {
      Get.find<ConfigController>().getConfigData();
    }

    Get.find<ParcelController>().getUnpaidParcelList();
    Get.find<BannerController>().getBannerList();
    Get.find<CategoryController>().getCategoryList();
    Get.find<AddressController>().getAddressList(1);
    Get.find<CouponController>().getCouponList(1, isUpdate: false);
    Get.find<OfferController>().getOfferList(1);
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfileInfo();
    }
    await Get.find<RideController>().getCurrentRideCarpool(type: "carpool");

    await Get.find<RideController>().getCurrentRide();
    if (Get.find<RideController>().currentTripDetails != null) {
      Get.find<RideController>().getBiddingList(
          Get.find<RideController>().currentTripDetails!.id!, 1);
      PusherHelper().pusherDriverStatus(
          Get.find<RideController>().currentTripDetails!.id!);
      if (Get.find<RideController>().currentTripDetails!.currentStatus ==
              'accepted' ||
          Get.find<RideController>().currentTripDetails!.currentStatus ==
              'ongoing') {
        Get.find<RideController>().startLocationRecord();
      }
    } else {
      Get.find<RideController>().clearBiddingList();
    }
    await Get.find<ParcelController>().getOngoingParcelList();
    if (Get.find<ParcelController>().parcelListModel!.data!.isNotEmpty) {
      for (var element in Get.find<ParcelController>().parcelListModel!.data!) {
        PusherHelper().pusherDriverStatus(element.id!);
      }
    }

    // Get current location first to ensure we have accurate coordinates
    await Get.find<LocationController>().getCurrentLocation(
      isAnimate: false,
      type: LocationType.from,
    );

    // Use current position for nearest drivers, fallback to saved address if current location fails
    double latitude = Get.find<LocationController>().position.latitude;
    double longitude = Get.find<LocationController>().position.longitude;

    // If current position is invalid, use saved address as fallback
    if (latitude == 0 && longitude == 0) {
      final savedAddress = Get.find<LocationController>().getUserAddress();
      latitude = savedAddress?.latitude ?? 0;
      longitude = savedAddress?.longitude ?? 0;
    }

    if (latitude != 0 && longitude != 0) {
      await Get.find<RideController>().getNearestDriverList(
        latitude.toString(),
        longitude.toString(),
      );
    }

    HomeScreenHelper().checkMaintanceMode();
  }

  @override
  Widget build(BuildContext context) {
    ConfigModel? config = Get.find<ConfigController>().config;

    return Scaffold(
      body: GetBuilder<RideController>(builder: (rideController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          int parcelCount = parcelController.parcelListModel?.totalSize ?? 0;
          int rideCount = (rideController.rideDetails != null &&
                  // rideController.rideDetails!.type == 'ride_request' &&
                  (rideController.rideDetails!.currentStatus == 'pending' ||
                      rideController.rideDetails!.currentStatus == 'accepted' ||
                      rideController.rideDetails!.currentStatus == 'ongoing' ||
                      (rideController.rideDetails!.currentStatus ==
                              'completed' &&
                          rideController.rideDetails!.paymentStatus! ==
                              'unpaid') ||
                      (rideController.rideDetails!.currentStatus ==
                              'cancelled' &&
                          rideController.rideDetails!.paymentStatus! ==
                              'unpaid')))
              ? 1
              : 0;

          return Stack(children: [
            // Map background
            const HomeMapView(title: 'rider_around_you'),

            // Current Location Button - moves with draggable sheet
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: _buttonTopPosition,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  // Get the map controller from MapController and use LocationController's getCurrentPosition
                  final mapController = Get.find<MapController>().mapController;
                  await Get.find<LocationController>().getCurrentPosition(
                    mapController: mapController,
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/image/current_location.png',
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Profile Button
            Positioned(
              top: Get.height * 0.05, // Position at top
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Navigate to profile screen
                  Get.find<BottomMenuController>()
                      .setTabIndex(3); // Profile tab
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Draggable bottom sheet with content
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.4, // Start at 40% of screen height
              minChildSize: 0.2, // Minimum height (20% of screen)
              maxChildSize: 0.9, // Maximum height (90% of screen)
              builder: (context, scrollController) {
                // Note: Sheet controller listener is set up in initState to avoid build conflicts

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 246, 248, 248),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: GetBuilder<ProfileController>(
                            builder: (profileController) {
                          return GetBuilder<RideController>(
                              builder: (rideController) {
                            return GetBuilder<ParcelController>(
                                builder: (parcelController) {
                              return BodyWidget(
                                body: RefreshIndicator(
                                  onRefresh: () async {
                                    await loadData(isReload: true);
                                  },
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: Dimensions.paddingSize,
                                          right: Dimensions.paddingSize,
                                        ),
                                        child: Column(children: [
                                          const HomeSearchWidget(),
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge),
                                          const BannerView(),
                                          // const Padding(
                                          //   padding: EdgeInsets.only(
                                          //       top: Dimensions
                                          //           .paddingSizeSmall),
                                          //   child: CategoryView(),
                                          // ),
                                          if ((config?.externalSystem ??
                                                  false) &&
                                              Get.find<AuthController>()
                                                  .isLoggedIn()) ...[
                                            const VisitToMartWidget(),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault)
                                          ],
                                          GetBuilder<LocationController>(
                                              builder: (locationController) {
                                            String? zoneExtraFareReason =
                                                _getExtraFairReason(
                                                    config?.zoneExtraFare,
                                                    locationController.zoneID);
                                            return zoneExtraFareReason != null
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        bottom: Dimensions
                                                            .paddingSizeSmall),
                                                    child: Text(
                                                        zoneExtraFareReason,
                                                        style: textRegular.copyWith(
                                                            color: Get
                                                                    .isDarkMode
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimaryContainer
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .inverseSurface,
                                                            fontSize: 11)),
                                                  )
                                                : const SizedBox();
                                          }),
                                        ]),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall),
                                      const HomeMyAddress(
                                          addressPage: AddressPage.home),
                                      if (config?.referralEarningStatus ??
                                          false)
                                        const HomeReferralViewWidget(),
                                      const BestOfferWidget(),
                                      const AppAdvertising(),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeLarge),
                                      const HomeCouponWidget(),
                                      const SizedBox(height: 140)
                                    ],
                                  ),
                                ),
                              );
                            });
                          });
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Ongoing ride/parcel indicator
            Positioned(
                child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: Get.height * 0.33),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      clickedMenu = true;
                    });
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    _onHorizontalDrag(details);
                  },
                  child: Stack(children: [
                    SizedBox(
                      width: 70,
                      child: Image.asset(
                        Images.homeMapIcon,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 15,
                      left: 35,
                      right: 0,
                      child: SizedBox(
                          height: 10,
                          child: Image.asset(Images.ongoing, scale: 2.7)),
                    ),
                    Positioned(
                      bottom: 85,
                      right: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                            child: Text(
                          '${rideCount + parcelCount}',
                          style: textRegular.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        )),
                      ),
                    )
                  ]),
                ),
              ),
            )),
            // Clicked menu overlay
            if (clickedMenu)
              Positioned(
                  child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.33),
                  child: GetBuilder<RideController>(builder: (rideController) {
                    return GetBuilder<ParcelController>(
                        builder: (parcelController) {
                      return Container(
                        width: 220,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).hintColor.withOpacity(.5),
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(1, 1),
                            )
                          ],
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(10)),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                clickedMenu = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Theme.of(context).hintColor,
                                size: Dimensions.iconSizeMedium,
                              ),
                            ),
                          ),
                          Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault),
                              child: InkWell(
                                onTap: () async {
                                  await rideController.getCurrentRideStatus(
                                      fromRefresh: true);
                                  setState(() {
                                    clickedMenu = false;
                                  });
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.5),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.125),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ongoing_ride'.tr),
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          child: Text(
                                            '$rideCount',
                                            style: textRegular.copyWith(
                                              color:
                                                  Theme.of(context).cardColor,
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ]),
                      );
                    });
                  }),
                ),
              )),
          ]);
        });
      }),
      floatingActionButton:
          GetBuilder<RideController>(builder: (rideController) {
        return rideController.biddingList.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.08),
                child: FloatingActionButton(
                  onPressed: () {
                    if (!rideController.isLoading) {
                      rideController
                          .getBiddingList(
                              rideController.currentTripDetails!.id!, 1)
                          .then((value) {
                        if (rideController.biddingList.isNotEmpty) {
                          Get.dialog(
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              DriverRideRequestDialog(
                                  tripId: Get.find<RideController>()
                                      .currentTripDetails!
                                      .id!));
                        }
                      });
                    }
                  },
                  backgroundColor: Colors.transparent,
                  child: Image.asset(Images.biddingIcon),
                ),
              )
            : const SizedBox();
      }),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) return;

    if (details.primaryVelocity!.compareTo(0) == -1) {
      debugPrint('dragged from left');
    } else {
      debugPrint('dragged from right');
    }
  }

  String? _getExtraFairReason(List<ZoneExtraFare>? list, String? zoneId) {
    for (int i = 0; i < (list?.length ?? 0); i++) {
      if (list?[i].zoneId == zoneId || list?[i].zoneId == 'all') {
        return list?[i].reason ?? '';
      }
    }
    return null;
  }
}
