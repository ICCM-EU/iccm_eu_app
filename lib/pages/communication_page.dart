import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/url_button.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/model/communication_data.dart';
import 'package:provider/provider.dart';

class CommunicationPage extends StatelessWidget {

  const CommunicationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication'),
      ),
      body: Consumer<CommunicationProvider>(
        builder: (context, itemProvider, child) {
          final itemList = itemProvider.items();
          if (itemList.isEmpty) {
            return const Center(
              child: Text('Loading dynamic content...'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: itemList.length,
            itemBuilder: (context, index) {
              CommunicationData item = itemList[index];
              if (item.title.isEmpty ||
                  !item.url.startsWith('https://')) {
                return SizedBox.shrink();
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: UrlButton(
                      title: item.title,
                      url: item.url,
                    ),
                  ),
                  Text(
                    item.url,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}