import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class EventData extends FlutterWeekViewEvent {
  final String? imageUrl;
  final TextSpan? track;
  final TextSpan? room;
  final TextSpan? speaker;
  final TextSpan? facilitator;
  final TextSpan name;
  final TextSpan details;
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
    title: name.text ?? '',
    description: details.text ?? '',
  );

  factory EventData.fromItemData(Map<String, dynamic> itemData) {
    final startValue = double.tryParse(itemData['Date & Time'] ?? '0') ?? 0;
    final startDaysSinceEpoch = startValue - 25569;
    final startMsSinceEpoch = startDaysSinceEpoch * 24 * 60 * 60 * 1000;
    final startTime = DateTime.fromMillisecondsSinceEpoch(startMsSinceEpoch.toInt());
    final endValue = double.tryParse(itemData['End Date & Time'] ?? '0') ?? 0;
    final endDaysSinceEpoch = endValue - 25569;
    final endMsSinceEpoch = endDaysSinceEpoch * 24 * 60 * 60 * 1000;
    final endTime = DateTime.fromMillisecondsSinceEpoch(endMsSinceEpoch.toInt());

    return EventData(
      imageUrl: itemData['Photo'] ?? '',
      name: TextSpan(text: itemData['Session'] ?? ''),
      details: TextSpan(text: itemData['Description'] ?? ''),
      // final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      // fineTime = dateFormat.parse(dateTimeString);
      start: startTime,
      end: endTime,
      room: TextSpan(text: itemData['Room']),
      track: TextSpan(text: itemData['Category']),
      speaker: TextSpan(text: itemData['Speaker']),
      facilitator: TextSpan(text: itemData['Facilitator']),
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(0),
    );
  }

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      imageUrl: json['imageUrl'],
      name: TextSpan(text: json['name'] as String? ?? ''),
      details: TextSpan(text: json['details'] as String? ?? ''),
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      track: TextSpan(text: json['track']),
      room: TextSpan(text: json['room']),
      speaker: TextSpan(text: json['speaker']),
      facilitator: TextSpan(text: json['facilitator']),
      id: int.tryParse(json['id'] ?? '-1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name.text.toString(),
      'details': details.text.toString(),
      'start': super.start.toIso8601String(),
      'end': super.end.toIso8601String(),
      'track': track?.text.toString(),
      'room': room?.text.toString(),
      'speaker': speaker?.text.toString(),
      'facilitator': facilitator?.text.toString(),
      'id': id.toString(),
    };
  }
}
