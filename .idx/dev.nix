{ pkgs, ... }: {
  # 채널을 가장 최신 버전인 'unstable'로 설정하여 패키지 호환성을 높입니다.
  channel = "stable-25.05";

  packages = [
    pkgs.flutter
    pkgs.firebase-tools
    pkgs.jdk
  ];

  env = {
    JAVA_HOME = pkgs.jdk.home;
    # Android SDK 라이선스에 동의합니다.
    NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = "1";
    # 결정적인 단서: 'unfree' 라이선스를 가진 패키지의 설치를 허용합니다.
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  idx = {
    extensions = [
      "dart-code.flutter"
    ];
    workspace = {
      onCreate = {
        # flutter config에 올바른 SDK 경로를 알려줍니다.
        # flutter doctor를 통해 라이선스에 동의합니다.
        accept-licenses-flutter = ''
          yes | flutter doctor --android-licenses
        '';
      };
      onStart = {
        # 시작 시 flutter doctor를 실행하여 최종 상태를 확인합니다.
        check-status = "flutter doctor";
      };
    };
  };
}
