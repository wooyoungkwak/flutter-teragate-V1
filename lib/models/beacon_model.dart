class BeaconData  {
   String name;
   String uuid;
   String macAddress;
   String major;
   String minor;
   String distance;
   String proximity;
   String scanTime;
   String rssi;
   String txPower;

  BeaconData (this.name, this.uuid, this.macAddress, this.major, this.minor,
      this.distance, this.proximity, this.scanTime, this.rssi, this.txPower);

  BeaconData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        uuid = json['uuid'],
        macAddress = json['macAddress'],
        major = json['major'],
        minor = json['minor'],
        distance = json['distance'],
        proximity = json['proximity'],
        scanTime = json['scanTime'],
        rssi = json['rssi'],
        txPower = json['txPower']
        ;

  get userId => null;
  Map<String, dynamic> toJson() => {
        'name': name,
        'uuid': uuid,
        'macAddress' : macAddress,
        'major': major,
        'minor': minor,
        'distance' : distance,
        'proximity':proximity,
        'scanTime':scanTime,
        'rssi':rssi,
        'txPower':txPower
      };
}
