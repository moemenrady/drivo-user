import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/interface/repository_interface.dart';

abstract class RideRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getEstimatedFare({
    required LatLng pickupLatLng,
    required LatLng destinationLatLng,
    required LatLng currentLatLng,
    required String type,
    required String pickupAddress,
    required String destinationAddress,
    LatLng? extraOneLatLng = const LatLng(0, 0),
    LatLng? extraTwoLatLng = const LatLng(0, 0),
    bool extraOne = false,
    bool extraTwo = false,
    String? parcelWeight,
    String? parcelCategoryId,
  });

  Future<dynamic> submitRideRequest({
    required String pickupLat,
    required String pickupLng,
    required String destinationLat,
    required String destinationLng,
    required String customerCurrentLat,
    required String customerCurrentLng,
    required String vehicleCategoryId,
    required String estimatedDistance,
    required String estimatedTime,
    required String estimatedFare,
    required String actualFare,
    required bool bid,
    required String note,
    required String paymentMethod,
    required String type,
    required String pickupAddress,
    required String destinationAddress,
    required String encodedPolyline,
    required List<String> middleAddress,
    required String entrance,
    required double extraEstimatedFare,
    required double extraDiscountFare,
    required double extraDiscountAmount,
    required double extraReturnFee,
    required double extraCancellationFee,
    required double extraFareAmount,
    required double extraFareFee,
    required String? zoneId,
    String? areaId,
    String extraLatOne = '',
    String extraLngOne = '',
    String extraLatTwo = '',
    String extraLngTwo = '',
    bool extraOne = false,
    bool extraTwo = false,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    String? receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? parcelCategoryId,
    String? weight,
    String? payer,
    String? tripRequestId,
    double? returnFee,
    double? cancellationFee,
    int? carpollRouteId,
  });

  Future<dynamic> carpoolSubmitRideRequest({
    required String carpollRouteId,
    required double price,
    required double pickupLat,
    required double pickupLng,
    required double destinationLat,
    required double destinationLng,
  });

  Future<dynamic> getRideDetails(String tripId);
  Future<dynamic> tripStatusUpdate(
      String id, String status, String cancellationCause);
  Future<dynamic> remainDistance(String requestID);
  Future<dynamic> biddingList(String tripId, int offset);
  Future<dynamic> nearestDriverList(String lat, String lng);
  Future<dynamic> tripAcceptOrReject(
      String tripId, String type, String driverId);
  Future<dynamic> ignoreBidding(String biddingId);
  Future<dynamic> currentRideStatus(String typ);
  Future<dynamic> getFinalFare(String id);
  Future<dynamic> arrivalPickupPoint(String tripId);
  Future<dynamic> getDriverLocation(String tripId);
  Future<dynamic> getDirection(
      {required LatLng pickupLatLng,
      required LatLng destinationLatLng,
      required LatLng extraOneLatLng,
      required LatLng extraTwoLatLng});
  Future<dynamic> parcelReceived(String tripId);
}
