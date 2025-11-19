{...}: let
in {
  programs.mcp = {
    enable = true;
    servers = {
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
