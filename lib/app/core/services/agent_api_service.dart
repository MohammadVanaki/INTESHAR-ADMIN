import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin/app/core/constants/constants.dart';
import 'package:admin/app/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AgentApiService {  
  static const String baseUrl = 'http://v2.inteshar.net/api/agent';
  final GetStorage _storage = GetStorage();

  // ============ Storage Methods ============

  String? getStoredActivationCode() {
    print(
      'Getting stored activation code: ${Constants.localStorage.read('agent_activation_code')}',
    );
    return Constants.localStorage.read('agent_activation_code');
  }

  // Store activation code
  Future<void> storeActivationCode(String code) async {
    print('Storing activation code: $code');
    await Constants.localStorage.write('agent_activation_code', code);
  }

  // Check if agent is activated
  String? isAgentActivated() {
    return Constants.localStorage.read('agent_activation_code');
  }

  // Set agent as activated
  Future<String> setAgentActivated(String activated) async {
    await Constants.localStorage.write('agent_activation_code', activated);
    return activated;
  }

  // Store agent token with debug
  Future<void> storeAgentToken(String token) async {
    print('💾 Storing agent_token: ${token.substring(0, 20)}...');
    await Constants.localStorage.write('agent_token', token);
    await _storage.write('agent_token_direct', token);
  }

  // Get agent token with debug
  String? getAgentToken() {
    final token = Constants.localStorage.read('agent_token');
    print(
      '🔍 DEBUG - Reading agent_token: ${token != null ? "Exists" : "Not found"}',
    );
    return token;
  }

  // Store agent id with debug
  Future<void> storeAgentId(int agentId) async {
    print('🔍 DEBUG - Storing agent_id: $agentId');
    await Constants.localStorage.write('agent_id', agentId);
  }

  // Get agent id with debug
  int? getAgentId() {
    final id = Constants.localStorage.read('agent_id');
    print('🔍 DEBUG - Reading agent_id: $id');
    return id;
  }

  // ============ NEW: Dashboard URL Methods ============

  /// ذخیره URL داشبورد
  Future<void> storeDashboardUrl(String url) async {
    print('💾 Storing dashboard URL: $url');
    await Constants.localStorage.write('agent_dashboard_url', url);
    await _storage.write('agent_dashboard_url_direct', url);

    // Verify storage
    final storedUrl = Constants.localStorage.read('agent_dashboard_url');
    print('✅ Dashboard URL stored: $storedUrl');
  }

  /// دریافت URL داشبورد
  String? getDashboardUrl() {
    final url = Constants.localStorage.read('agent_dashboard_url');
    print('🔍 Reading dashboard URL: $url');

    // Try direct storage if not found
    if (url == null) {
      final directUrl = _storage.read('agent_dashboard_url_direct');
      print('🔍 Trying direct storage: $directUrl');
      return directUrl;
    }

    return url;
  }

  /// پاک کردن URL داشبورد
  Future<void> removeDashboardUrl() async {
    print('🗑️ Removing dashboard URL');
    await Constants.localStorage.remove('agent_dashboard_url');
    await _storage.remove('agent_dashboard_url_direct');
  }

  // ============ Clear All Agent Data ============

  // Clear all agent data with debug
  Future<void> clearAgentData() async {
    print('🔍 DEBUG - Clearing all agent data');
    // await Constants.localStorage.remove('agent_activation_code');
    await Constants.localStorage.remove('agent_activated');
    await Constants.localStorage.remove('agent_token');
    await Constants.localStorage.remove('agent_id');
    await Constants.localStorage.remove('agent_email');
    await Constants.localStorage.remove('agent_dashboard_url'); // اضافه شده

    await _storage.remove('agent_activation_code_direct');
    await _storage.remove('agent_activated_direct');
    await _storage.remove('agent_token_direct');
    await _storage.remove('agent_dashboard_url_direct'); // اضافه شده
    await _storage.remove('agent_activation_code_getstorage');
  }

  // ============ API Methods ============

  // Helper method for making API requests
  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool includeLocation = true,
  }) async {
    try {
      // Get location data if needed
      Map<String, dynamic> locationData = {};
      if (includeLocation) {
        try {
          locationData = await LocationService.getLocationData();
        } catch (e) {
          debugPrint('Location error: $e');
        }
      }

      // Prepare final body
      Map<String, dynamic> finalBody = body ?? {};
      if (includeLocation && locationData.isNotEmpty) {
        finalBody['location'] = locationData;
      }

      // Add device info
      finalBody['device_info'] = {
        'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        // 'os_version': GetPlatform.operatingSystemVersion ?? 'unknown',
        'app_version': '1.0.0',
        'fcm_token': Constants.fcmToken.isNotEmpty ? Constants.fcmToken : null,
      };

      // Log request for debugging
      print('📡 API Request: $method $baseUrl/$endpoint');
      print('📡 Request Body: $finalBody');

      // Make request
      final uri = Uri.parse('$baseUrl/$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
        ...?headers,
      };

      http.Response response;
      switch (method.toLowerCase()) {
        case 'post':
          response = await http
              .post(uri, headers: requestHeaders, body: json.encode(finalBody))
              .timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Log response for debugging
      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'error': 'Response body is empty',
          'statusCode': response.statusCode,
        };
      }

      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        print('❌ JSON Decode Error: $e');
        return {
          'success': false,
          'error': 'Invalid JSON response: $e',
          'statusCode': response.statusCode,
          'rawResponse': response.body,
        };
      }

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      print(
        'Activation Code: ${responseBody?['data']?['activation_code'] ?? 'N/A'}',
      );
      return {
        'success': isSuccess,
        'data': responseBody,
        'statusCode': response.statusCode,
      };
    } on TimeoutException catch (e) {
      print('❌ TimeoutException: $e');
      return {
        'success': false,
        'error': 'انتهت مهلة الطلب. الرجاء التحقق من اتصال الإنترنت',
      };
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      return {'success': false, 'error': 'خطأ في الاتصال: ${e.message}'};
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      return {
        'success': false,
        'error': 'تعذر الاتصال بالخادم. الرجاء التحقق من اتصال الإنترنت',
      };
    } on Exception catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // 1. Register agent with name
  Future<Map<String, dynamic>> registerAgent(String name) async {
    return await _makeRequest(
      endpoint: 'register',
      method: 'POST',
      body: {'name': name},
      includeLocation: true,
    );
  }

  // 2. Activate agent with code
  Future<Map<String, dynamic>> activateAgent(String activationCode) async {
    return await _makeRequest(
      endpoint: 'activate',
      method: 'POST',
      body: {'activation_code': activationCode},
      includeLocation: true,
    );
  }

  // 3. Login agent
  Future<Map<String, dynamic>> loginAgent({
    required String email,
    required String password,
    required String activationCode,
  }) async {
    return await _makeRequest(
      endpoint: 'login',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'activation_code': activationCode,
      },
      includeLocation: true,
    );
  }

  // 4. Verify 2FA
  Future<Map<String, dynamic>> verify2FA({
    required int agentId,
    required String code,
    required String activationCode,
    double? lat,
    double? lon,
  }) async {
    print('🔍 Sending verify2FA request with:');
    print('   agent_id: $agentId');
    print('   code: $code');
    print('   activation_code: $activationCode');
    print('   lat: $lat');
    print('   lon: $lon');

    final Map<String, dynamic> body = {
      'agent_id': agentId,
      'code': code,
      'activation_code': activationCode,
    };

    // Add location data if available
    if (lat != null && lon != null) {
      body['lat'] = lat;
      body['lon'] = lon;
    }

    final result = await _makeRequest(
      endpoint: 'verify-2fa',
      method: 'POST',
      body: body,
      includeLocation: false,
    );

    print('🔍 Full verify2FA response: $result');

    return result;
  }

  // 5. Logout agent
  Future<Map<String, dynamic>> logoutAgent(String token) async {
    print('🔍 Logging out with token: ${token.substring(0, 20)}...');

    final result = await _makeRequest(
      endpoint: 'logout',
      method: 'POST',
      body: {'token': token},
      headers: {'Authorization': 'Bearer $token'},
      includeLocation: false,
    );

    print('🔍 Logout response: $result');

    return result;
  }
}
