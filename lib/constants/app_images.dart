enum AppImages {
  loginBackground('login_bg'),

  noImageAvatar('no_image_avatar'),
  appLogo('app_logo');

  const AppImages(this.imageName);
  final String imageName;

  String get pngPath => 'assets/images/png/$imageName.png';
}
