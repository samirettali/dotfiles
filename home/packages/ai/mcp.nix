{...}: {
  programs.mcp = {
    enable = true;
    servers = {
      claude-design = {
        url = "https://api.anthropic.com/v1/design/mcp";
      };

      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--browserUrl=http://127.0.0.1:9222"
        ];
      };
    };
  };
}
