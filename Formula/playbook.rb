class Playbook < Formula
  desc "Claude Code plugin toolkit: hooks, launcher, and installer in one binary"
  homepage "https://github.com/pragmatic-engineer/playbook"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  conflicts_with "pbtop", because: "playbook already provides pbtop. Run: brew uninstall pbtop, then brew reinstall playbook"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/playbook-0.40.2-aarch64-apple-darwin"
      sha256 "7d72c57347c5452df43315db2e14cf032c8407260ffb1cc6ebdb8c75ea05db90"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbdoc-0.40.2-aarch64-apple-darwin.tar.gz"
        sha256 "09b3046b9158c3f7711717986283066359563791abfc99996e00a01defd7f54e"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/playbook-0.40.2-x86_64-apple-darwin"
      sha256 "dfe572c8bca983c7e59a1e8494924a59fa9786b91f2ed198b5954906ca2f5bca"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbdoc-0.40.2-x86_64-apple-darwin.tar.gz"
        sha256 "23dcd1cdf576f06735b7fc3c308bbfe6250e7c178f74a3f5484249a20c942d62"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/playbook-0.40.2-aarch64-unknown-linux-musl"
      sha256 "017d6447c77f01662ac7e675734d321ffa72c800b83d18e8d2c4b333118109d4"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbdoc-0.40.2-aarch64-unknown-linux-musl.tar.gz"
        sha256 "3b7006e47066989cd226196dd78ef05fc04714b2250f4c46c0f0782e0082efa8"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/playbook-0.40.2-x86_64-unknown-linux-musl"
      sha256 "32686c31d4ccdbeb874122416b160b41bf349278bf5b01a25c1155cc69758654"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.2/pbdoc-0.40.2-x86_64-unknown-linux-musl.tar.gz"
        sha256 "dc5b3246ead807a87ff4f9a22f113e165f9e484577138f11beaee4e79b49a6ae"
      end
    end
  end

  def install
    bin.install Dir["playbook-*"].first => "playbook"
    bin.install_symlink "playbook" => "pbtop"
    bin.install_symlink "playbook" => "pb"
    resource("pbdoc").stage do
      bin.install "pbdoc"
      doc.install "NOTICE-pbdoc"
    end
  end

  def caveats
    <<~EOS
      Run `playbook setup` once (`playbook init` on 0.34 and earlier). In a
      terminal it asks before it adds the safety hooks to ~/.claude/settings.json,
      and it puts playbook on PATH for every shell, including the ones Claude
      Code starts for hooks.
      If you used the old playbook-hooks plugin, run
      `claude plugin uninstall playbook-hooks@pragmatic-engineer` first.
      Start sessions with `playbook cc` or `playbook ccd`. `pb` is a short alias,
      so `pb cc` and `pb ccd` work too.
      `pbtop` is a link to `playbook` too. It opens the usage dashboard and always has
      the version of `playbook`, so `brew upgrade playbook` updates both. If the separate
      `pbtop` formula is installed, run `brew uninstall pbtop`, then `brew reinstall playbook`.
      Installing never edits your Claude Code settings. Upgrade with `brew upgrade playbook`.
      Release notes: https://github.com/pragmatic-engineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/playbook --version")
    assert_match "pbtop #{version}", shell_output("#{bin}/pbtop --version")
    assert_match version.to_s, shell_output("#{bin}/pb --version")
    assert_match version.to_s, shell_output("#{bin}/pbdoc --version")
  end
end
