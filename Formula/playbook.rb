class Playbook < Formula
  desc "Claude Code plugin toolkit: hooks, launcher, and installer in one binary"
  homepage "https://github.com/amplifiedengineer/playbook"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/playbook-0.44.0-aarch64-apple-darwin"
      sha256 "28e46a87c582cc89630a9d29a3c72d054d42ffc52a20ad3ff69e0e924438df0e"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbdoc-0.44.0-aarch64-apple-darwin.tar.gz"
        sha256 "06a376562461203e231760ff3e657cd37acda91e26ab42051c4aa9d54a2c783f"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbsync-0.44.0-aarch64-apple-darwin.tar.gz"
        sha256 "d9bdca5e75b8a0d6374f7e660308094f96e94c8d7ce7705f15010e72f0b65759"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/playbook-0.44.0-x86_64-apple-darwin"
      sha256 "cda32622f80ee56c2f61b20d55611dcb3bfc63b1bc2fc4132e36050ffdc6a43a"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbdoc-0.44.0-x86_64-apple-darwin.tar.gz"
        sha256 "ce6402330b472cac4aa86f370b49c56ecba3c75e2ff96c5876b995f6c7762ef4"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbsync-0.44.0-x86_64-apple-darwin.tar.gz"
        sha256 "078bf9081bc27f44da8653ef16bc6cc91068bdaa1240ae47e79e734182e1c9bd"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/playbook-0.44.0-aarch64-unknown-linux-musl"
      sha256 "c6767b6ac9f3c580e632b1917b76fdef2bdbae09e278955519fba7e51b875187"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbdoc-0.44.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "55822218d5c4845431c0f03b42e7a260b46d3e56547c84f23be507414458e061"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbsync-0.44.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "5083b43a6cecabaeaf18bddbd9112db38470f2d7ebd59ab6c891ebc131c6b326"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/playbook-0.44.0-x86_64-unknown-linux-musl"
      sha256 "db7ed527910932ff2c84499b8724aaf6d9e59121a707c65a9805449273a526b5"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbdoc-0.44.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "3d1da612f6cb1206ac01f82c6cb3774faa80cd3864c85615ebc16b122795f1b2"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.44.0/pbsync-0.44.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "0bbb95dabb80209e56333664ee1852ba02666df0c9d7ab6b60f2bb9450f6e6be"
      end
    end
  end

  conflicts_with "pbtop",
                because: "playbook already provides pbtop. Run: brew uninstall pbtop, then brew reinstall playbook"

  def install
    bin.install Dir["playbook-*"].first => "playbook"
    bin.install_symlink "playbook" => "pbtop"
    bin.install_symlink "playbook" => "pb"
    resource("pbdoc").stage do
      bin.install "pbdoc"
      doc.install "NOTICE-pbdoc"
    end
    resource("pbsync").stage do
      bin.install "pbsync"
    end
  end

  def caveats
    <<~EOS
      This formula installs the `playbook` and `pbtop` commands. `pb` is a short
      alias for `playbook`.
      It also installs the helpers `pbdoc` and `pbsync`, which `playbook` calls for you.
      Usage sync is off until you run `playbook sync enable`.
      Run `playbook setup` once (`playbook init` on 0.34 and earlier). In a
      terminal it asks before it adds the safety hooks to ~/.claude/settings.json,
      and it puts playbook on PATH for every shell, including the ones Claude
      Code starts for hooks.
      The plugin is `playbook@amplifiedengineer`, from the marketplace `amplifiedengineer/marketplace`.
      If you used the old playbook-hooks plugin, run
      `claude plugin uninstall playbook-hooks@pragmatic-engineer` first.
      Start sessions with `playbook cc` or `playbook ccd`. `pb cc` and `pb ccd`
      work too.
      `pbtop` is a link to `playbook` too. It opens the usage dashboard and always has
      the version of `playbook`, so `brew upgrade playbook` updates both. If the separate
      `pbtop` formula is installed, run `brew uninstall pbtop`, then `brew reinstall playbook`.
      Installing never edits your Claude Code settings. Upgrade with `brew upgrade playbook`.
      Release notes: https://github.com/amplifiedengineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/playbook --version")
    assert_match "pbtop #{version}", shell_output("#{bin}/pbtop --version")
    assert_match version.to_s, shell_output("#{bin}/pb --version")
    assert_match version.to_s, shell_output("#{bin}/pbdoc --version")
    assert_match version.to_s, shell_output("#{bin}/pbsync --version")
  end
end
