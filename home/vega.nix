# vega: where Samir and the agents work (servers' README), mevbot's alone.
_: {
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
