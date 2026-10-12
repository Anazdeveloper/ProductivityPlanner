/// Which social providers can be offered on this device and build.
final class SocialSignInOptions {
  const SocialSignInOptions({required this.apple, required this.google});

  static const SocialSignInOptions none = SocialSignInOptions(apple: false, google: false);

  final bool apple;
  final bool google;

  @override
  bool operator ==(Object other) =>
      other is SocialSignInOptions &&
      other.apple == apple &&
      other.google == google;

  @override
  int get hashCode => Object.hash(apple, google);
}
