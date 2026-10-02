import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/link_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/model/communication_data.dart';
import 'package:provider/provider.dart';

import '../components/send_notification_form.dart';
import '../data/notifications/fcm_notifications_service.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({
    super.key,
  });

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  @override
  void initState() {
    super.initState();
    PreferencesProvider.loadNotificationsNickname();
    PreferencesProvider.loadFcmAdminPwd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Websites and Mailing Lists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Consumer<CommunicationProvider>(
            builder: (context, itemProvider, child) {
              final itemList = itemProvider.items();
              if (itemList.isEmpty) {
                return const Center(
                  child: Text('Loading dynamic content...'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  CommunicationData item = itemList[index];
                  if (item.title.isEmpty ||
                      !item.url.startsWith('https://')) {
                    return const SizedBox.shrink();
                  }
                  return LinkListTile(
                    item: item,
                    inApp: false,
                  );
                },
              );
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: PreferencesProvider.notificationsNicknameNotifier,
            builder: (context, nickname, child) {
              return ValueListenableBuilder<String>(
                valueListenable: PreferencesProvider.fcmAdminPwdNotifier,
                builder: (context, pwd, child) {
                  if (nickname.trim().isEmpty || pwd.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Send Notification',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (FcmNotificationsService.supportedPlatform)
                        SendNotificationForm(
                          nickname: nickname,
                          pwd: pwd,
                        )
                      else
                        const Text(
                          'Notification topic subscriptions not supported on this platform.',
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
