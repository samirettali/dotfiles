{...}: {
  programs.mcp = {
    enable = true;
    servers = {
      elevenlabs = {
        command = "uvx";
        args = ["elevenlabs-mcp"];
      };
      # Same hosted endpoint the official Exa plugin installs into Claude Code,
      # but declared once here so pi and Codex get it too. `tools` pins the two
      # non-deprecated defaults; everything else Exa ships is either deprecated
      # or needs an API key. `login` forces the OAuth handshake, which is what
      # buys a real quota without a secret in the world-readable nix store.
      exa = {
        url = "https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa&login";
      };
      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--browserUrl=http://127.0.0.1:9222"
        ];
      };
      #   everything = {
      #     command = "npx";
      #     args = [
      #       "-y"
      #       "@modelcontextprotocol/server-everything"
      #     ];
      #   };
      #   context7 = {
      #     url = "https://mcp.context7.com/mcp";
      #     # headers = {
      #     #   CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
      #     # };
      #   };
      #   playwright = {
      #     command = "npx";
      #     args = [
      #       "@playwright/mcp@latest"
      #     ];
      #   };
      #   ast-grep = {
      #     command = "uvx";
      #     args = [
      #       "--from"
      #       "git+https://github.com/ast-grep/ast-grep-mcp"
      #       "ast-grep-server"
      #     ];
      #   };
    };
  };
}
