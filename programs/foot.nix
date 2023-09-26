{ font
, ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=12";
        term = "xterm-256color";
      };
      cursor = {
        color = "111111 cccccc";
      };
      colors = {
        foreground = "dddddd";
        background = "000000";
        regular0 = "000000";
        regular1 = "cc0403";
        regular2 = "19cb00";
        regular3 = "cecb00";
        regular4 = "0d73cc";
        regular5 = "cb1ed1";
        regular6 = "0dcdcd";
        regular7 = "dddddd";
        bright0 = "767676";
        bright1 = "f2201f";
        bright2 = "23fd00";
        bright3 = "fffd00";
        bright4 = "1a8fff";
        bright5 = "fd28ff";
        bright6 = "14ffff";
        bright7 = "ffffff";
      };
    };
  };
}
