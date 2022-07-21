import 'package:network_info_plus/network_info_plus.dart';
// device IP 확인
class WifiInfo {
  
  static Future<Map<String, dynamic>> getIPAddress() async {
    final networkInfo = NetworkInfo();
    var ip = await networkInfo.getWifiIP();
    var ssid = await networkInfo.getWifiBSSID();
    
    Map<String, dynamic> map = {
        "ip" : ip,
        "ssid" : ssid
    };
    return map;
  }
  
}
