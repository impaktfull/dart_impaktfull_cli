import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/integrations/slack/model/slack_message_attachment.dart';

class SlackPlugin extends ImpaktfullCliPlugin {
  SlackPlugin({required super.processRunner});

  Future<void> sendMessage({
    required String channelName,
    String? message,
    List<SlackMessageAttachment> attachments = const [],
  }) async {
    final slackBotToken = ImpaktfullCliEnvironmentVariables.getSlackBotToken();

    final response = await http.post(
      Uri.parse('https://slack.com/api/chat.postMessage'),
      headers: {
        'Authorization': 'Bearer $slackBotToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'channel': '#$channelName',
        if (message != null) ...{
          'text': message,
        },
        if (attachments.isNotEmpty) ...{
          'attachments': attachments.map((e) => e.toJson()).toList(),
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message to Slack: ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseBody['ok'] != true) {
      throw Exception('Slack API error: ${responseBody['error']}');
    }
  }
}
