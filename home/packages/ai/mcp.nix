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
      # Rex docs, changelog and beta Discord; signs in with Discord OAuth.
      superlogical.url = "https://www.superlogical.com/rex/community-mcp";
    };
  };
}
