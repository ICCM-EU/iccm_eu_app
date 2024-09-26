import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';

class TravelInformationPage extends StatelessWidget {
  const TravelInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return
      ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const PageTitle(title: "Travel Information"),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.train),
            title: const Text("Train"),
            subtitle: Column( // Use a Column for multi-line text
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left          child: Row(
            children: [
              RichText(
               text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    text:
                      "When arriving by train, please register "
                      "and give us a call when the train is delayed.\n\n"
                      "The nearest train station is at another village close by "
                      "but the transfer to the conference venue requires a lift.",
                  ),
                ]),
              )]
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.airplane_ticket),
            title: const Text("Plane"),
            subtitle: Column( // Use a Column for multi-line text
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left          child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: const <TextSpan>[
                          TextSpan(
                            text:
                            "When arriving by plane, please register "
                                "and give us a call when the train is delayed.\n\n"
                                "The nearest train station is at another village close by "
                                "but the transfer to the conference venue requires a lift.",
                          ),
                        ]),
                  )]
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.car_rental),
            title: const Text("Car"),
            subtitle: Column( // Use a Column for multi-line text
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left          child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: const <TextSpan>[
                          TextSpan(
                            text:
                            "When arriving by car, "
                                "please use the nearest parking lot and "
                                "consider taking other conference guests with you in your car.",
                          ),
                        ]),
                  )]
            ),
          ),
      ],
    );
  }
}