{pkgs, ...}: {
  home.packages = with pkgs; [
    colima
    docker-client
    docker-compose
  ];

  home.file.".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
}
