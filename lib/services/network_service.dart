import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

// device IP 확인
Future<Map<String, dynamic>> getIPAddressByWifi() async {
  final networkInfo = NetworkInfo();
  var ip = await networkInfo.getWifiIP();
  var ssid = await networkInfo.getWifiBSSID();
  
  Map<String, dynamic> map = {
      "ip" : ip,
      "ssid" : ssid
  };
  return map;
}

Future<Map<String, dynamic>> getIPAddressByMobile() async {
  final url = Uri.parse('https://api.ipify.org');
  final response = await http.get(url);
  var ip = response.body;
  Map<String, dynamic> map = {
      "ip" : ip,
      "ssid" : ""
  };
  return map;
}
  
