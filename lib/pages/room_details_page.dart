import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:provider/provider.dart';

class RoomDetailsPage extends StatefulWidget {
  final RoomData item;
  const RoomDetailsPage({
    super.key,
    required this.item,
  });

  @override
  RoomDetailsPageState createState() => RoomDetailsPageState();
}

class RoomDetailsPageState extends State<RoomDetailsPage> {
  late Timer _timer;

  void _fetchData() {
    Provider.of<GsheetsProvider>(context, listen: true).fetchData(
      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchData(); // Call fetchData every 5 minutes
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<RoomsProvider>(context, listen: true).loadCache;
    _fetchData(); // Call fetchData initially
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RoomData item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Details"),
        actions: const [
          // IconButton(
          //   icon: Icon(
          //     Icons.filter_alt,
          //     color: Colors.grey[700],
          //   ),
          //   onPressed: () {
          //
          //   },
          // ),
        ],
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.imageUrl.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 50,
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
                RichText(
                  text: item.name,
                  // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: item.details,
                  // style: const TextStyle(fontSize: 18),
                ),
                // Add more details here as needed
              ],
            ),
          ]
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}