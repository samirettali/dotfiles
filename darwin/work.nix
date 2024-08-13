{ ... }: {
  homebrew = {
    brews = [
      "amazon-ecs-cli"
      "granted"
      "terraform"
    ];
    casks = [
      "royal-tsx"
      "slack"
    ];
    taps = [
      "common-fate/granted"
    ];
  };
}
