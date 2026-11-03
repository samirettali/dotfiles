# The SSH client on every host: the servers by name, with rbw's hetzner key
# from rbw's own agent, and their host keys declared, so that no machine
# needs a hand-written ~/.ssh/config. The servers listen on 38719 over the
# tailnet only (servers' README).
{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # rbw's runtime directory: $XDG_RUNTIME_DIR on Linux; on macOS, which has
  # none, a directory per user under $TMPDIR.
  rbwAgent =
    if isDarwin
    then "\${TMPDIR}/rbw-%i/ssh-agent-socket"
    else "\${XDG_RUNTIME_DIR}/rbw/ssh-agent-socket";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = lib.optionals isDarwin ["~/.colima/ssh_config"];
    settings = {
      "Host andromeda orion vega" = {
        Port = 38719;
        User = "samir";
        IdentityFile = "~/.ssh/hetzner-rbw.pub";
        IdentitiesOnly = true;
        IdentityAgent = rbwAgent;
        UserKnownHostsFile = "~/.ssh/known_hosts.servers";
        StrictHostKeyChecking = true;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 4;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%C";
        ControlPersist = "10m";
      };
      "github.com" =
        {
          IdentityFile = "~/.ssh/github";
          IdentitiesOnly = true;
        }
        // lib.optionalAttrs isDarwin {
          AddKeysToAgent = true;
          UseKeychain = true;
        };
      # The work Mac, on the home network only.
      wk = lib.mkIf isDarwin {
        HostName = "192.168.1.73";
        User = "s.ettali";
        IdentityFile = "~/.ssh/wk";
        AddKeysToAgent = true;
        UseKeychain = true;
      };
    };
  };

  home.file = {
    # Replaces the file each host had by hand, and on andromeda and vega the
    # block servers' common role wrote before it left the file to this one.
    ".ssh/config".force = true;
    # Only the public half: rbw's agent holds the private one.
    ".ssh/hetzner-rbw.pub" = {
      force = true;
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEWO20PXHyDSxO9gC0Gk7W4LrsFB6P2lzovlLWmhG0A rbw-hetzner\n";
    };
    # Read from each host's /etc/ssh/ssh_host_ed25519_key.pub over a
    # connection already checked, on 2026-11-03.
    ".ssh/known_hosts.servers".text = ''
      [andromeda]:38719 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2VRYXMkyVwVxmGjWf3u8tQ+AqMmsaga+PS88gzwJiv
      [orion]:38719 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuDtCLd++YO1ZXmJRICOgbWAWX2s6Zcsx5VJNlvdvyw
      [vega]:38719 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1TcrACuaMNcYbGPqygod2Li+35MM3eYIJ5jqNryjbg
    '';
  };
}
