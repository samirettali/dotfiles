# vega: where Samir and the agents work (servers' README), mevbot's alone.
_: {
  # The headless browser lives here alone: andromeda is aarch64, where the
  # binary cache has no ungoogled-chromium 157, and building it from source
  # filled andromeda's root (2026-11-16).
  imports = [./packages/dev/headless-browser.nix];

  # Every heavy step of the agents (mevbot's heavy script, on the volume)
  # runs in this slice with no cap of its own: one ceiling for all of them,
  # under the machine's 62 GiB, so that a run that grows without bound
  # leaves the research-rpc proxies and the shells their memory.
  systemd.user.slices.mevbot-heavy = {
    Unit.Description = "mevbot's heavy steps";
    Slice = {
      MemoryMax = "54G";
      MemorySwapMax = "0";
    };
  };
}
