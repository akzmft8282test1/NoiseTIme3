{ pkgs, ... }:
{
  # 안정적인 패키지 채널을 사용합니다.
  channel = "stable-25.05";

  packages = [
    pkgs.flutter
    pkgs.deno
    pkgs.docker
    # [고객님 제안 적용] npm을 사용하기 위해 Node.js를 설치합니다.
    pkgs.nodejs_22
    pkgs.supabase-cli
  ];

  # Docker 서비스를 활성화합니다.
  services.docker.enable = true;

  idx = {
    extensions = [
      "dart-code.flutter"
      "denoland.vscode-deno"
    ];
    workspace = {
      # 워크스페이스가 처음 생성될 때 한 번만 실행됩니다.
      onCreate = {
        # [고객님 제안 적용] npm을 사용하여 최신 버전의 supabase-cli를 전역으로 설치합니다.
        # 이 방법은 Nix 채널 문제로부터 자유롭고 훨씬 안정적입니다.
        install-supabase-cli-via-npm = "npm install -g supabase-cli";
      };
      onStart = {
        # 시작 시 flutter doctor를 실행하여 환경을 확인합니다.
        run-doctor = "flutter doctor";
      };
    };
  };
}
