class TenantConfig {
  final String currentHostelId;
  final String appName;
  final String supportWebsite; // Email ki jajah aapki corporate support link

  const TenantConfig({
    required this.currentHostelId,
    required this.appName,
    required this.supportWebsite,
  });

  factory TenantConfig.fromEnvironment() {
    return const TenantConfig(
      currentHostelId: "TRUE_HOSTEL_MASTER_NODE",
      appName: "True Hostel",
      supportWebsite: "https://opnora.com", // Aapki official website jahan sab aapse judenge
    );
  }
}