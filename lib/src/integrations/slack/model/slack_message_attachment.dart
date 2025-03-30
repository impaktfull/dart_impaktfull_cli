class SlackMessageAttachment {
  final String color;
  final String text;

  const SlackMessageAttachment({
    required this.text,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'color': color,
        'text': text,
      };
}
