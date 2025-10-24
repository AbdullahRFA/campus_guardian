class SkillRequest {
  final String id;
  final String title;
  final String description;
  final String requesterName;
  final int creditsOffered;
  final List<String> tags;

  const SkillRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.requesterName,
    required this.creditsOffered,
    required this.tags,
  });
}