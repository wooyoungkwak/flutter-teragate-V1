import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teragate_test/config/env.dart';

// device IP 확인
class IpInfoApi {
  static Future<String?> getIPAddress() async {
    try {
      final url = Uri.parse('https://api.ipify.org');
      final response = await http.get(url);
      
      if(Env.isDebug) debugPrint("#################### response ");
      if(Env.isDebug) debugPrint(response.body);
      
      return response.body;
    } catch (e) {
      return null;
    }
  }
}
