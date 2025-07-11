import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:ride_sharing_user_app/data/error_response.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  late String token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token) ?? '';
    customPrint('Token: $token');
    Address? address;
    try {
      address = Address.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
      customPrint(address.toJson().toString());
      // ignore: empty_catches
    } catch (e) {}
    updateHeader(token, address);
  }

  void updateHeader(String token, Address? address, {String? zoneId}) {
    Map<String, String> header = {};
    if (address != null) {
      header.addAll({'zoneId': address.zoneId.toString()});
    }
    if (zoneId != null) {
      header.addAll({'zoneId': zoneId});
    }
    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      AppConstants.localization:
          sharedPreferences.getString(AppConstants.languageCode) ??
              AppConstants.languages[0].languageCode,
      'Authorization': 'Bearer $token',
    });
    if (kDebugMode) {
      print('====> API Call: Zone: ${address?.zoneId ?? ''}');
    }

    _mainHeaders = header;
  }

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      http.Response response = await http
          .get(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('== ==> API Call: $uri\nHeader: $_mainHeaders');
        print('== ==> API Body: $body');
      }
      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartDataConversation(
      String? uri, Map<String, String> body, List<MultipartBody>? multipartBody,
      {Map<String, String>? headers, PlatformFile? otherFile}) async {
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri!));
    request.headers.addAll(headers ?? _mainHeaders);

    if (otherFile != null) {
      request.files.add(http.MultipartFile('files[${multipartBody!.length}]',
          otherFile.readStream!, otherFile.size,
          filename: basename(otherFile.name)));
    }
    if (multipartBody != null) {
      for (MultipartBody multipart in multipartBody) {
        Uint8List list = await multipart.file!.readAsBytes();
        request.files.add(http.MultipartFile(
          multipart.key,
          multipart.file!.readAsBytes().asStream(),
          list.length,
          filename: '${DateTime.now().toString()}.png',
        ));
      }
    }
    request.fields.addAll(body);
    http.Response response =
        await http.Response.fromStream(await request.send());
    return handleResponse(response, uri);
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body,
      MultipartBody profile, List<MultipartBody> multipartBody,
      {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print(
            '====> API Body: $body with ${multipartBody.length} picture and ${profile.key}');
      }
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      if (profile.file != null) {
        Uint8List list = await profile.file!.readAsBytes();
        request.files.add(http.MultipartFile(
          profile.key,
          profile.file!.readAsBytes().asStream(),
          list.length,
          filename: '${DateTime.now().toString()}.png',
        ));
      }

      for (MultipartBody multipart in multipartBody) {
        log("Here-----${multipart.file}/${multipart.key}");
        if (multipart.file != null) {
          log("Here----Inside-");
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: multipart.file?.path.split('/').last,
          ));
          log("===ImageKey==>${multipart.key}/${multipart.file!.readAsBytes().asStream()}");
        }
      }
      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      http.Response response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postAddCar(
      String uri,
      Map<String, String> body,
      List<MultipartBody> multipartBody,
      MultipartBody? logo,
      List<MultipartDocument> otherFile,
      {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        log('====> API Call: $uri\nHeader: $_mainHeaders');
        log('====> API Body: $body with ${multipartBody.length} picture');
      }
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);

      if (logo != null) {
        if (logo.file != null) {
          Uint8List list = await logo.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            logo.key,
            logo.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }

      if (otherFile.isNotEmpty) {
        for (MultipartDocument file in otherFile) {
          File aaa = File(file.file!.path!);
          Uint8List list0 = await aaa.readAsBytes();
          var part = http.MultipartFile(
              'other_documents[]', aaa.readAsBytes().asStream(), list0.length,
              filename: basename(aaa.path));
          request.files.add(part);
        }
      }

      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
      // ignore: empty_catches
    } catch (e) {}
    Response localResponse = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (localResponse.statusCode != 200 &&
        localResponse.body != null &&
        localResponse.body is! String) {
      if (localResponse.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse =
            ErrorResponse.fromJson(localResponse.body);
        localResponse = Response(
            statusCode: localResponse.statusCode,
            body: localResponse.body,
            statusText: errorResponse.errors![0].message);
      } else if (localResponse.body.toString().startsWith('{message')) {
        localResponse = Response(
            statusCode: localResponse.statusCode,
            body: localResponse.body,
            statusText: localResponse.body['message']);
      }
    } else if (localResponse.statusCode != 200 && localResponse.body == null) {
      localResponse = Response(statusCode: 0, statusText: noInternetMessage);
    }

    log('====> API Response: [${localResponse.statusCode}] $uri\n${localResponse.body}');

    return localResponse;
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class MultipartDocument {
  String key;
  PlatformFile? file;
  MultipartDocument(this.key, this.file);
}
