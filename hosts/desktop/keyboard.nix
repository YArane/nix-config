# Replaces SharpKeys on Windows: the IBM Model M (1984) has no Windows key,
# so remap Scroll Lock → Left Super (Meta). keyd works at the kernel input
# level, so it applies in Plasma, on the login screen, and in TTYs.
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.scrolllock = "leftmeta";
    };
  };
}
