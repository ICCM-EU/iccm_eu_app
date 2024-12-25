import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class EventData extends FlutterWeekViewEvent {
  final String? imageUrl;
  final String? track;
  final String? room;
  final String? speaker;
  final String? facilitator;
  final String name;
  final String details;
  String? surveyUrl;
  String? parallelSessions;
  bool? forceNotify = false;
  int? id = -1;


  EventData({
    // mandatory parameters
    required this.name,
    required this.details,
    required super.start,
    required super.end,

    // optional local parameters
    this.imageUrl,
    this.track,
    this.room,
    this.speaker,
    this.facilitator,
    this.surveyUrl,
    this.parallelSessions,
    this.forceNotify,
    this.id,

    // optional inherited parameters
    // FIXME: Set these based on local parameters
    super.backgroundColor,
    super.decoration,
    super.textStyle,
    super.padding,
    super.margin,

    // Set these with the context available
    super.onTap,
    super.onLongPress,

    super.eventTextBuilder,
  }) : super(
    title: name.toString(),
    description: details.toString(),
  );

  factory EventData.fromItemData(Map<String, dynamic> itemData) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Europe/Berlin');
    const Duration offset = Duration(hours: -9);
    DateTime utcStart = DateTime.parse(itemData['Date & Time']).add(offset);
    tz.TZDateTime localStart = tz.TZDateTime.from(utcStart, location);
    DateTime utcEnd = DateTime.parse(itemData['End Date & Time']).add(offset);
    tz.TZDateTime localEnd = tz.TZDateTime.from(utcEnd, location);
    return EventData(
      imageUrl: UrlFunctions.proxy(itemData['Photo']),
      name: itemData['Session'] ?? '',
      details: itemData['Description'] ?? '',
      start: localStart,
      end: localEnd,
      room: itemData['Room'],
      track: itemData['Category'],
      speaker: itemData['Speaker'],
      facilitator: itemData['Facilitator'],
      surveyUrl: itemData['Survey URL'],
      parallelSessions: itemData['Parallel'],
      forceNotify: itemData['Notify-after-Break'] == 'true',
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(0),
    );
  }

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      imageUrl: json['imageUrl'],
      name: json['name'] as String? ?? '',
      details: json['details'] as String? ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      track: json['track'],
      room: json['room'],
      speaker: json['speaker'],
      facilitator: json['facilitator'],
      surveyUrl: json['surveyUrl'],
      parallelSessions: json['parallelSessions'],
      forceNotify: bool.tryParse(json['forceNotify']),
      id: int.tryParse(json['id'] ?? '-1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.toString(),
      'details': details.toString(),
      'start': super.start.toIso8601String(),
      'end': super.end.toIso8601String(),
      'track': track?.toString(),
      'room': room?.toString(),
      'speaker': speaker?.toString(),
      'facilitator': facilitator?.toString(),
      'surveyUrl': surveyUrl.toString(),
      'parallelSessions': parallelSessions.toString(),
      'forceNotify': forceNotify.toString(),
      'id': id.toString(),
    };
  }
}
