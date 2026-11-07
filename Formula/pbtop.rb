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
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.41.0/pbtop-0.41.0-aarch64-apple-darwin.tar.gz"
      sha256 "477c63f649697528b993f926f2adb5a9fdc60d55aee6199d381044b0dd00fced"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.41.0/pbtop-0.41.0-x86_64-apple-darwin.tar.gz"
      sha256 "438811cb7522846a54771b9b24ee45b233ddbd18f39bf5ca554fd6320441abca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.41.0/pbtop-0.41.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d335fe431b873e3be81e05f071cb8fe1b01518eb335c45cedb3961e9d718011a"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.41.0/pbtop-0.41.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "8ff8da3f3b4758f8ea94edf9637aa0430a5875748beef09ac1fb86fa417833fb"
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
