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
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbtop-0.40.0-aarch64-apple-darwin.tar.gz"
      sha256 "3f297cf06332f55885da4f84e5cfa45125b8fb702669696241adb9587c0edf2c"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbtop-0.40.0-x86_64-apple-darwin.tar.gz"
      sha256 "ae2b8a0f81a37396139db2bf01a91f754f748642bbffbecf8fcea1bfc9a525f6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbtop-0.40.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ad76d2809dbcd1d1659ada930254fca1bcba78c30f4094a92791b0826f866241"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbtop-0.40.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6009325adaa2508bb563bde3c720419d679d66a92f3b68e600cbd8ec32fa0e61"
    end
  end

  def install
    bin.install "pbtop"
  end

  def caveats
    <<~EOS
      Run `pbtop` to start.
      Release notes: https://github.com/pragmatic-engineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pbtop --version")
  end
end
