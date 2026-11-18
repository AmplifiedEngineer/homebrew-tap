class Pbtop < Formula
  desc "Terminal dashboard of Claude Code token use and cost"
  homepage "https://github.com/amplifiedengineer/playbook"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbtop-0.44.0-aarch64-apple-darwin.tar.gz"
      sha256 "5ee363098c74cc5e4bda8954c5eca08ec32d6a506ce78ebeb3c12417e788f771"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbtop-0.44.0-x86_64-apple-darwin.tar.gz"
      sha256 "6a1d3431dc86a0701c87f05371fe44d8e2c1ecb550f326f14b5d1fc9fe922ddc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbtop-0.44.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "796f454a08fdbeef0ab8b5bf19f68ae99e60983f4589fef77283c04b2961551f"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbtop-0.44.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "82347233e8b37433fe1c43298a88e785426c8032b256f04b925d259d5b07538f"
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
      Release notes: https://github.com/amplifiedengineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pbtop --version")
  end
end
