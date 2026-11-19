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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbtop-0.45.0-aarch64-apple-darwin.tar.gz"
      sha256 "97f68a0a2abfd3020466eec89da5df4c5cffa6099fed389da44ce416cc999801"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbtop-0.45.0-x86_64-apple-darwin.tar.gz"
      sha256 "c122e6fc02cfa6fa07f32c57dca58392e3b7cb9fcf1781415950a54a7e00a3c3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbtop-0.45.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e845e4128dd9eca17ad9d417ddcc892147fe7ce9d10298ff5391038a6b1f641c"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbtop-0.45.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "64e485490f17f0fb056b07c5d4465c8679f429d7edc30fd7320a273d943fc3ba"
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
