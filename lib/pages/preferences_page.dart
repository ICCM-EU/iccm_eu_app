import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';
import 'package:provider/provider.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _pwdController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: PreferencesProvider.notificationsNicknameNotifier.value,
    );
    _pwdController = TextEditingController(
      text: PreferencesProvider.fcmAdminPwdNotifier.value,
    );

    _loadPreferences();

    PreferencesProvider.notificationsNicknameNotifier.addListener(_onNicknameChanged);
    PreferencesProvider.fcmAdminPwdNotifier.addListener(_onPwdChanged);
  }

  void _onNicknameChanged() {
    if (_nicknameController.text != PreferencesProvider.notificationsNicknameNotifier.value) {
      _nicknameController.text = PreferencesProvider.notificationsNicknameNotifier.value;
    }
  }

  void _onPwdChanged() {
    if (_pwdController.text != PreferencesProvider.fcmAdminPwdNotifier.value) {
      _pwdController.text = PreferencesProvider.fcmAdminPwdNotifier.value;
    }
  }

  Future<void> _loadPreferences() async {
    await PreferencesProvider.loadCalendarColorByRoom();
    await PreferencesProvider.loadUseTestData();
    await PreferencesProvider.loadSubscribeTestTopic();
    await PreferencesProvider.loadNotificationTopics();
    await PreferencesProvider.loadNotificationsNickname();
    await PreferencesProvider.loadFcmAdminPwd();
    if (mounted) {
      _nicknameController.text = PreferencesProvider.notificationsNicknameNotifier.value;
      _pwdController.text = PreferencesProvider.fcmAdminPwdNotifier.value;
    }
  }

  @override
  void dispose() {
    PreferencesProvider.notificationsNicknameNotifier.removeListener(_onNicknameChanged);
    PreferencesProvider.fcmAdminPwdNotifier.removeListener(_onPwdChanged);
    _nicknameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Preferences',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text('Theme',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
          ToggleIsDarkModeListTile(context: context),
          const Divider(),
          Text('Calendar Colors',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: PreferencesProvider.calendarColorByRoomNotifier,
            builder: (context, builderValue, child) {
              return ToggleButtonListTile(
                value: builderValue,
                onChanged: (bool newValue) {
                  PreferencesProvider.setCalendarColorByRoom(newValue);
                },
                title: 'Calendar Color by Room',
                toggleTitle: 'Calendar Colors',
              );
            },
          ),
          if (EventsProvider.showTestDataOption())
            const Divider()
          else
            const SizedBox.shrink(),
          if (EventsProvider.showTestDataOption())
            Text('Test Data',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            )
          else
            const SizedBox.shrink(),
          if (EventsProvider.showTestDataOption())
            ValueListenableBuilder<bool>(
              valueListenable: PreferencesProvider.useTestDataNotifier,
              builder: (context, builderValue, child) {
                return ToggleButtonListTile(
                  value: builderValue,
                  onChanged: (bool newValue) {
                    PreferencesProvider.setUseTestData(newValue);
                    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
                      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
                      force: true,
                    );
                  },
                  title: 'Use Test Data',
                  toggleTitle: 'Test Data',
                );
              },
            )
          else
            const SizedBox.shrink(),
          const Divider(),
          Text('Notification Subscriptions',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
          if (CommunicationProvider.showTestTopicOption())
            ValueListenableBuilder<bool>(
              valueListenable: PreferencesProvider.subscribeTestTopicNotifier,
              builder: (context, builderValue, child) {
                return ToggleButtonListTile(
                  value: builderValue,
                  onChanged: (bool newValue) {
                    PreferencesProvider.setSubscribeTestTopic(newValue);
                    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
                      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
                      force: true,
                    );
                  },
                  title: 'Test',
                  toggleTitle: 'Test',
                );
              },
            )
          else
            const SizedBox.shrink(),
          Consumer<TracksProvider>(
            builder: (context, tracksProvider, child) {
              final tracks = tracksProvider.items();
              if (tracks.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tracks.map((track) {
                  return ValueListenableBuilder<List<String>>(
                    valueListenable: PreferencesProvider.notificationTopicsNotifier,
                    builder: (context, subscribedTopics, child) {
                      final String topicKey = TextFunctions.normalizeListKey(
                        track.name,
                        PreferencesProvider.listSep,
                      );
                      final String defaultTopicKey = TextFunctions.normalizeListKey(
                        FcmNotificationsService.defaultTopic,
                        PreferencesProvider.listSep,
                      );
                      final bool isDefaultTopic =
                          topicKey == defaultTopicKey ||
                              track.name.toLowerCase().trim() ==
                                  FcmNotificationsService.defaultTopic.toLowerCase().trim();
                      final bool isSubscribed = isDefaultTopic ||
                          subscribedTopics.contains(topicKey) ||
                          subscribedTopics.contains(track.name);
                      return ToggleButtonListTile(
                        value: isSubscribed,
                        onChanged: isDefaultTopic
                            ? null
                            : (bool newValue) {
                                if (newValue) {
                                  PreferencesProvider.addNotificationTopic(track.name);
                                } else {
                                  PreferencesProvider.removeNotificationTopic(track.name);
                                }
                              },
                        title: track.name,
                        toggleTitle: track.name,
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),
          ValueListenableBuilder<String>(
            valueListenable: PreferencesProvider.notificationsNicknameNotifier,
            builder: (context, nickname, child) {
              final bool showPassword = nickname.trim().isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Notification Nickname',
                    ),
                    onChanged: (value) {
                      PreferencesProvider.setNotificationsNickname(value);
                    },
                  ),
                  if (showPassword) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pwdController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'FCM Admin Password',
                      ),
                      onChanged: (value) {
                        PreferencesProvider.setFcmAdminPwd(value);
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
