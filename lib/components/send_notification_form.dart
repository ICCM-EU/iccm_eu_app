import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:provider/provider.dart';

class SendNotificationForm extends StatefulWidget {
  final String nickname;
  final String pwd;

  const SendNotificationForm({
    super.key,
    required this.nickname,
    required this.pwd,
  });

  @override
  State<SendNotificationForm> createState() => _SendNotificationFormState();
}

class _SendNotificationFormState extends State<SendNotificationForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _authorController;
  late final TextEditingController _secretController;

  String? _selectedTopic;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: PreferencesProvider.fcmSendTitleNotifier.value,
    );
    _messageController = TextEditingController();
    _authorController = TextEditingController(text: widget.nickname);
    _secretController = TextEditingController(text: widget.pwd);

    _selectedTopic = PreferencesProvider.fcmSendTopicNotifier.value;

    _loadPreferences();

    PreferencesProvider.fcmSendTopicNotifier.addListener(_onTopicChanged);
    PreferencesProvider.fcmSendTitleNotifier.addListener(_onTitleChanged);
  }

  Future<void> _loadPreferences() async {
    await PreferencesProvider.loadSendTopic();
    await PreferencesProvider.loadSendTitle();
    if (mounted) {
      setState(() {
        _selectedTopic = PreferencesProvider.fcmSendTopicNotifier.value;
        if (_titleController.text != PreferencesProvider.fcmSendTitleNotifier.value) {
          _titleController.text = PreferencesProvider.fcmSendTitleNotifier.value;
        }
      });
    }
  }

  void _onTopicChanged() {
    if (mounted && _selectedTopic != PreferencesProvider.fcmSendTopicNotifier.value) {
      setState(() {
        _selectedTopic = PreferencesProvider.fcmSendTopicNotifier.value;
      });
    }
  }

  void _onTitleChanged() {
    if (mounted && _titleController.text != PreferencesProvider.fcmSendTitleNotifier.value) {
      _titleController.text = PreferencesProvider.fcmSendTitleNotifier.value;
    }
  }

  @override
  void didUpdateWidget(covariant SendNotificationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nickname != widget.nickname) {
      _authorController.text = widget.nickname;
    }
    if (oldWidget.pwd != widget.pwd) {
      _secretController.text = widget.pwd;
    }
  }

  @override
  void dispose() {
    PreferencesProvider.fcmSendTopicNotifier.removeListener(_onTopicChanged);
    PreferencesProvider.fcmSendTitleNotifier.removeListener(_onTitleChanged);
    _titleController.dispose();
    _messageController.dispose();
    _authorController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final topic = _selectedTopic ?? FcmNotificationsService.defaultTopic;
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final author = _authorController.text.trim();
    final secret = _secretController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message text.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final sendTitle = title.isEmpty ? 'Conference Announcement' : title;

    await PreferencesProvider.setSendTopic(topic);
    await PreferencesProvider.setSendTitle(sendTitle);

    final success = await FcmNotificationsService.sendMessage(
      topic: topic,
      title: sendTitle,
      messageText: message,
      author: author,
      secret: secret,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
      });
      if (success) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message. Please check password or server.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksProvider = Provider.of<TracksProvider>(context);
    final topics = FcmNotificationsService().getTopics(tracksProvider);

    if (_selectedTopic == null || !topics.contains(_selectedTopic)) {
      if (topics.contains(PreferencesProvider.fcmSendTopicNotifier.value)) {
        _selectedTopic = PreferencesProvider.fcmSendTopicNotifier.value;
      } else {
        _selectedTopic = topics.isNotEmpty ? topics.first : FcmNotificationsService.defaultTopic;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedTopic),
          initialValue: _selectedTopic,
          decoration: const InputDecoration(
            labelText: 'Topic',
          ),
          items: topics.map((topic) {
            return DropdownMenuItem<String>(
              value: topic,
              child: Text(topic),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTopic = value;
              });
              PreferencesProvider.setSendTopic(value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
          onChanged: (value) {
            PreferencesProvider.setSendTitle(value);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Message',
          ),
        ),
        const SizedBox(height: 12),
        Text("Author: ${widget.nickname}"),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSending ? null : _handleSend,
          child: _isSending
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Send Notification'),
        ),
      ],
    );
  }
}
