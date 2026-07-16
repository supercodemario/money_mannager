/// Remote / cached force-update policy for one platform.
class ForceUpdatePolicy {
  const ForceUpdatePolicy({
    required this.minBuild,
    required this.storeUrl,
    this.message,
  });

  final int minBuild;
  final String storeUrl;
  final String? message;

  ForceUpdatePolicy copyWith({
    int? minBuild,
    String? storeUrl,
    String? message,
  }) {
    return ForceUpdatePolicy(
      minBuild: minBuild ?? this.minBuild,
      storeUrl: storeUrl ?? this.storeUrl,
      message: message ?? this.message,
    );
  }
}
