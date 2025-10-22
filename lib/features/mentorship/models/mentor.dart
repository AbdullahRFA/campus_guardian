class Mentor {
  final String id;
  final String name;
  final String title;
  final String company;
  final String profileImageUrl;
  final List<String> expertise;

  // Add 'const' here
  const Mentor({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.profileImageUrl,
    required this.expertise,
  });
}