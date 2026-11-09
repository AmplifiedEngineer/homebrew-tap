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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbtop-0.42.0-aarch64-apple-darwin.tar.gz"
      sha256 "e61743fcb663fe6e6ae8c4f4bc796608211c75c7cecef750f5e5bfe7af98299d"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbtop-0.42.0-x86_64-apple-darwin.tar.gz"
      sha256 "73196996349c48a3ec2ed84a7478a4b112fffa05f5d50cefe66e7403a4d4a236"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbtop-0.42.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cb3c37d5a30672f767fe88eb890634193d4d6ef816e1df7125d9590c28e52491"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbtop-0.42.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e8c0c8715f903349c1292017115410312717cc5d98ef45a1c5d631bf31ab17a9"
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
