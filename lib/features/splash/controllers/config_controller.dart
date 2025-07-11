import 'dart:async';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/config_service_interface.dart';

class ConfigController extends GetxController implements GetxService {
  final ConfigServiceInterface configServiceInterface;
  ConfigController({required this.configServiceInterface});

  ConfigModel? _config;

  ConfigModel? get config => _config;

  bool loading = false;
  Future<bool> getConfigData({bool reload= false}) async {
    bool isSuccess = false;
    loading = true;
    if(loading){
      update();
    }
    Response response = await configServiceInterface.getConfigData();
    if(response.statusCode == 200) {
      loading = false;
      isSuccess = true;
      _config = ConfigModel.fromJson(response.body);
    }else {loading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return isSuccess;

  }

  Future<bool> initSharedData() {
    return configServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return configServiceInterface.removeSharedData();
  }

  bool showIntro() {
    return configServiceInterface.showIntro()!;

  }
  void disableIntro() {
    configServiceInterface.disableIntro();
  }


  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection){
    _pusherConnectionStatus = connection;
  }

  bool haveOngoingRides() {
    return configServiceInterface.haveOngoingRides();
  }

  void saveOngoingRides(bool value) {
    return configServiceInterface.saveOngoingRides(value);
  }

}