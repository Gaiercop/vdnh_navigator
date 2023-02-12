import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'utilities/computes_utilities.dart';

import 'models/lng_lat.dart';
import 'models/road.dart';
import 'utilities/localisation_instruction.dart';
import 'utilities/utils.dart';

/// OSRMManager
/// this class responsible to manage http call to get road from open-source osm server
/// or custom server that should be specified in constructor based on osrm project
/// contain only one public method [getRoad] to make the call
/// and return [Road] object.
/// for more detail see : https://github.com/Project-OSRM/osrm-backend
/// [server]   : (String) represent the osm server or any custom server that based of OSRM project
///
/// [roadType] : (RoadType) represent the type of road that you want to use, car or foot,bike only for osm servers
class OSRMManager {
  final String server;
  final RoadType roadType;
  final dio = Dio();

  OSRMManager()
      : server = oSRMServer,
        roadType = RoadType.car;

  OSRMManager.custom({
    required this.server,
    this.roadType = RoadType.car,
  });

  /// getRoad
  /// this method make http call to get road from specific server
  /// this method return Road that contain road information like distance and duration
  /// and instruction or return Road with empty values
  /// return Road object that contain information of road
  /// that will help to draw road in the map or show important information to the user
  /// you should take a specific case when road object will contain empty values like 0.0 or empty string
  /// in case of any problem
  Future<Road> getRoad({
    required List<LngLat> waypoints,
    RoadType roadType = RoadType.car,
    bool alternative = false,
    bool steps = true,
    Overview overview = Overview.full,
    Geometries geometrie = Geometries.geojson,
    String languageCode = "en",
  }) async {
    String path = generatePath(
      waypoints.toWaypoints(),
      steps: steps,
      overview: overview,
      geometry: geometrie,
    );
    path += "&alternatives=$alternative";

    final response = await dio.get(path);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = response.data;
      return compute(
        parseRoad,
        ParserRoadComputeArg(
          jsonRoad: responseJson,
          langCode: languageCode,
          alternative: alternative,
        ),
      );
    } else {
      return Road.withError();
    }
  }

  /// [getTrip]
  /// this method used to get route from trip service api
  /// used if you have more that 10 waypoint to generate route will more accurate
  /// that [getRoad].
  Future<Road> getTrip({
    required List<LngLat> waypoints,
    RoadType roadType = RoadType.car,
    bool roundTrip = true,
    SourceGeoPointOption source = SourceGeoPointOption.any,
    DestinationGeoPointOption destination = DestinationGeoPointOption.any,
    bool steps = true,
    Overview overview = Overview.full,
    Geometries geometry = Geometries.polyline,
    String languageCode = "en",
  }) async {
    if (!roundTrip &&
        (source == SourceGeoPointOption.any ||
            destination == DestinationGeoPointOption.any)) {
      return Road.empty();
    }
    String urlReq = generateTripPath(
      waypoints.toWaypoints(),
      roadType: roadType,
      roundTrip: roundTrip,
      source: source,
      destination: destination,
      steps: steps,
      overview: overview,
      geometrie: geometry,
    );
    final response = await dio.get(urlReq);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = response.data;
      return compute(
        parseTrip,
        ParserTripComputeArg(
          tripJson: responseJson,
          langCode: languageCode,
        ),
      );
    } else {
      return Road.withError();
    }
  }

  static String instructionFromDirection(
    String direction,
    Map<String, dynamic> jManeuver,
    String roadName,
    String languageCode,
  ) {
    if (direction == "turn" || direction == "ramp" || direction == "merge") {
      String modifier = jManeuver["modifier"];
      direction = "$direction-$modifier";
    } else if (direction == "roundabout") {
      int exit = jManeuver["exit"];
      direction = "$direction-$exit";
    } else if (direction == "rotary") {
      int exit = jManeuver["exit"];
      direction = "roundabout-$exit"; //convert rotary in roundabout...
    }
    int maneuverCode = 0;
    if (maneuvers.containsKey(direction)) {
      maneuverCode = maneuvers[direction] ?? 0;
    }
    return LocalisationInstruction(
      languageCode: languageCode,
    ).getInstruction(
      maneuverCode,
      roadName,
    );
  }
}

extension OSRMPrivateFunct on OSRMManager {
  @visibleForTesting
  String generatePath(
    String waypoints, {
    Profile profile = Profile.route,
    RoadType roadType = RoadType.car,
    bool steps = true,
    Overview overview = Overview.full,
    Geometries geometry = Geometries.polyline,
  }) {
    String url =
        "$server/routed-${roadType.value}/${profile.name}/v1/diving/$waypoints";
    var option = "";
    option += "steps=$steps&";
    option += "overview=${overview.value}&";
    option += "geometries=${geometry.value}";
    return "$url?$option";
  }

  @visibleForTesting
  String generateTripPath(
    String waypoints, {
    RoadType roadType = RoadType.car,
    bool roundTrip = true,
    SourceGeoPointOption source = SourceGeoPointOption.any,
    DestinationGeoPointOption destination = DestinationGeoPointOption.any,
    bool steps = true,
    Overview overview = Overview.full,
    Geometries geometrie = Geometries.polyline,
  }) {
    String baseGeneratedUrl = generatePath(
      waypoints,
      profile: Profile.trip,
    );

    return "$baseGeneratedUrl&source=${source.name}&destination=${destination.name}&roundtrip=$roundTrip";
  }
}
