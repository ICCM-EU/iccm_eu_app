import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/full_screen_qr_code.dart';
import 'package:iccm_eu_app/components/qr_scanner.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
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
  final Set<String> _pendingTopics = {};

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
    final tracksProvider = Provider.of<TracksProvider>(context, listen: false);
    await PreferencesProvider.loadCalendarColorByRoom();
    await PreferencesProvider.loadUseTestData();
    await PreferencesProvider.loadNotificationTopics(tracksProvider);
    await PreferencesProvider.loadNotificationsNickname();
    await PreferencesProvider.loadFcmAdminPwd();
    if (mounted) {
      _nicknameController.text = PreferencesProvider.notificationsNicknameNotifier.value;
      _pwdController.text = PreferencesProvider.fcmAdminPwdNotifier.value;
    }
  }

  void _sharePasswordQr(BuildContext context, String password) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenQrCode(
          url: password,
          title: 'FCM Admin Password',
          showText: false,
        ),
      ),
    );
  }

  Future<void> _scanPasswordQr(BuildContext context) async {
    final String? scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScanner(),
      ),
    );
    if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
      _pwdController.text = scannedCode;
      PreferencesProvider.setFcmAdminPwd(scannedCode);
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
          // Limit the topic subscription to platforms supported by firebase_messaging only.
          if (FcmNotificationsService.supportedPlatform)
            Consumer<TracksProvider>(
              builder: (context, tracksProvider, child) {
                final topics = FcmNotificationsService().getTopics(
                    tracksProvider);
                if (topics.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topics.map((topicName) {
                    return ValueListenableBuilder<List<String>>(
                      valueListenable: PreferencesProvider
                          .notificationTopicsNotifier,
                      builder: (context, subscribedTopics, child) {
                        final String topicKey = TextFunctions.normalizeListKey(
                          topicName,
                          PreferencesProvider.listSep,
                        );
                        final bool isSubscribed =
                            subscribedTopics.contains(topicKey) ||
                            subscribedTopics.contains(topicName);
                        final bool isPending =
                            _pendingTopics.contains(topicKey) ||
                            _pendingTopics.contains(topicName);
                        return ToggleButtonListTile(
                          value: isSubscribed,
                          onChanged: isPending
                              ? null
                              : (bool newValue) async {
                                  if (_pendingTopics.contains(topicKey) ||
                                      _pendingTopics.contains(topicName)) {
                                    return;
                                  }
                                  setState(() {
                                    _pendingTopics.add(topicKey);
                                    _pendingTopics.add(topicName);
                                  });
                                  try {
                                    if (newValue) {
                                      await PreferencesProvider.addNotificationTopic(
                                        topicName,
                                        userGesture: true,
                                        tracksProvider: tracksProvider,
                                      );
                                    } else {
                                      await PreferencesProvider.removeNotificationTopic(
                                        topicName,
                                        userGesture: true,
                                        tracksProvider: tracksProvider,
                                      );
                                    }
                                  } catch (e) {
                                    // Ignore exception to ensure finally block runs cleanly
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _pendingTopics.remove(topicKey);
                                        _pendingTopics.remove(topicName);
                                      });
                                    }
                                  }
                                },
                          title: topicName,
                          toggleTitle: topicName,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            if (FcmNotificationsService.supportedPlatform)
              const Divider(),
            if (FcmNotificationsService.supportedPlatform)
              ValueListenableBuilder<String>(
                valueListenable: PreferencesProvider
                    .notificationsNicknameNotifier,
                builder: (context, nickname, child) {
                  final bool showPassword = nickname
                      .trim()
                      .isNotEmpty;
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
                        ValueListenableBuilder<String>(
                          valueListenable: PreferencesProvider.fcmAdminPwdNotifier,
                          builder: (context, pwdValue, child) {
                            final bool hasPassword = pwdValue.isNotEmpty;
                            return TextField(
                              controller: _pwdController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'FCM Admin Password',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasPassword)
                                      IconButton(
                                        key: const Key('share_fcm_pwd_qr_button'),
                                        icon: const Icon(Icons.qr_code),
                                        tooltip: 'Share FCM Admin Password via QR code',
                                        onPressed: () => _sharePasswordQr(context, pwdValue),
                                      ),
                                    IconButton(
                                      key: const Key('scan_fcm_pwd_qr_button'),
                                      icon: const Icon(Icons.qr_code_scanner),
                                      tooltip: 'Scan FCM Admin Password QR code',
                                      onPressed: () => _scanPasswordQr(context),
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (value) {
                                PreferencesProvider.setFcmAdminPwd(value);
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              )
             else
                const Text(
                    'Notification topic subscriptions not supported on this platform.'
                ),
        ],
      ),
    );
  }
}
