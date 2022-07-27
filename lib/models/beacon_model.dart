class BeaconData  {
   String name;
   String uuid;
   String major;
   String minor;
   String distance;
   String rssi;

  BeaconData (this.name, this.uuid, this.major, this.minor, this.distance, this.rssi);

  BeaconData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        uuid = json['uuid'],
        major = json['major'],
        minor = json['minor'],
        distance = json['distance'],
        rssi = json['rssi'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'uuid': uuid,
        'major': major,
        'minor': minor,
        'distance' : distance,
        'rssi':rssi,
      };
}
