class Pbtop < Formula
  desc "Terminal dashboard of Claude Code token use and cost"
  homepage "https://github.com/pragmatic-engineer/playbook"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbtop-0.40.2-aarch64-apple-darwin.tar.gz"
      sha256 "05a399ff997589a6076a8d03ea37f4cfe8d33c3267c2317571ca786b26e2e557"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbtop-0.40.2-x86_64-apple-darwin.tar.gz"
      sha256 "ad68cd5db92e03d8418124c37854c434699e2c01ce6070390796597555183171"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbtop-0.40.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c5371ad01546f82d614346ad18e2c53fd0e6cc2dde2ff5fe3e76996f4d23133b"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbtop-0.40.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "270d4ca09d0df6d29daa186f8730219fc8ee9e6f30cf9deded2d0217f73df28b"
    end
  end

  conflicts_with "playbook",
                because: "playbook already provides pbtop. Run: brew uninstall pbtop, then brew reinstall playbook"

  def install
    bin.install "pbtop"
  end

  def caveats
    <<~EOS
      Run `pbtop` to start.
      This formula is for a machine without playbook. The playbook formula links
      `pbtop` to `playbook`, so if you install playbook later, run `brew uninstall pbtop` first.
      Release notes: https://github.com/pragmatic-engineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pbtop --version")
  end
end
