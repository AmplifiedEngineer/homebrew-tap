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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbtop-0.43.0-aarch64-apple-darwin.tar.gz"
      sha256 "790744b4e5f465b69fa887db1c4a03f18ef422602aabc473ac07fecb77ede293"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbtop-0.43.0-x86_64-apple-darwin.tar.gz"
      sha256 "eae916c35c4a938e3dddacb1e3f54c9646be15ee13fa3ecf3fed355fb4cc6ef4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbtop-0.43.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c666ae3bc15edde0581a77fa26dc7e5437090e1a78fff9735ca31d95b6ba9a7b"
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbtop-0.43.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1239d39a6a688d4e09bb603c06aabb909debe5252fc154326570f5b1afd5d017"
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
