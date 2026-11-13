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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/playbook-0.43.0-aarch64-apple-darwin"
      sha256 "55ec3d032607096130706d0b1e73acf0c026176bf83622a46c7d7b99b8f56a7e"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbdoc-0.43.0-aarch64-apple-darwin.tar.gz"
        sha256 "3b7d8335a36e637b3f6a8bdcb96e04664539e6d1306fd4463566ef3dec74162f"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbsync-0.43.0-aarch64-apple-darwin.tar.gz"
        sha256 "71cc138796e99051c73b4949f362a12c9cc84bacee2c04263ddbb3d9039cf55f"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/playbook-0.43.0-x86_64-apple-darwin"
      sha256 "ae32c928a0b593bc3d71a87902ea158f349a51bd7748866a168e11562ad27f2e"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbdoc-0.43.0-x86_64-apple-darwin.tar.gz"
        sha256 "d2117bc743ecc907104c41251baf5785c5bc06e3dd739ee786217a4af25247f6"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbsync-0.43.0-x86_64-apple-darwin.tar.gz"
        sha256 "3050bd8383defa88542fe236f043a328b79ea1830bac0c6b136cbf70016c78ac"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/playbook-0.43.0-aarch64-unknown-linux-musl"
      sha256 "a36f144bb4492e7f4088f686b710923fb20a97f2af1bdb9c110a9adf5a5fbcd0"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbdoc-0.43.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "adedf882f2dff9430baeef5ed26e657d73b3be3a206d1c9232bf997be0d13552"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbsync-0.43.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "13f3d2509b67e74363dd8e63ff4dfda50e135e602aa9bae8b53f1df786f8437f"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/playbook-0.43.0-x86_64-unknown-linux-musl"
      sha256 "bf60586b7cb30c415733ebab1ca6a50cfd1dfa5c59c4e07882fc40a3bd2ef47b"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbdoc-0.43.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "b19ba8d21f1f8f4798784b2b6f3ca4138e9d14396ef07e953c25ca6524b7b522"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.43.0/pbsync-0.43.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "716b0fd8e3fb6218c8a7d8f3c1b13f84971a98df756723884b0565087b854c25"
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
      This formula installs `playbook`, `pbtop`, `pbdoc` and `pbsync`. `pb` is a short alias for `playbook`.
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
