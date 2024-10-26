import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class EventData extends FlutterWeekViewEvent {
  final String? imageUrl;
  final TextSpan? track;
  final TextSpan? room;
  final TextSpan name;
  final TextSpan details;

  factory EventData.fromItemData(Map<String, dynamic> itemData) {
    final startValue = double.tryParse(itemData['StartTime'] ?? '0') ?? 0;
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
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(0),
    );
  }

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
}
