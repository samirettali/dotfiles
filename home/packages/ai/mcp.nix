{...}: {
  programs.mcp = {
    enable = true;
    servers = {
      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@1.9.0"
          "--browserUrl=http://127.0.0.1:9222"
        ];
      };
    };
  };
}
