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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/playbook-0.45.0-aarch64-apple-darwin"
      sha256 "5adc3dd75aa06b9e85bc27e8a8e417710f83c7505b042cba8c7efe6b17e78e34"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbdoc-0.45.0-aarch64-apple-darwin.tar.gz"
        sha256 "91f528ac7f3b66676f4e9b18b6d873ef006220d74c0adbcdf8b5e3b7b7f2ec89"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbsync-0.45.0-aarch64-apple-darwin.tar.gz"
        sha256 "47eff1f766cbb5340cc0bda13f6253d9ecce86413c12f36a2e696d3985e08f01"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/playbook-0.45.0-x86_64-apple-darwin"
      sha256 "cb97fb1c4dbefcd0ba1532a9d407df8a520ae5191f42dd5edef2d8be4710b5dc"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbdoc-0.45.0-x86_64-apple-darwin.tar.gz"
        sha256 "d6cd7a97f2d8d4d0ae3d956474dd1dc5a21c2d94db051185bdc7f36915b6cbd5"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbsync-0.45.0-x86_64-apple-darwin.tar.gz"
        sha256 "3a7437c6824a1076f444214d9cd70b9faeb03b4934d059eb4ffdc35b81fb5fbb"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/playbook-0.45.0-aarch64-unknown-linux-musl"
      sha256 "47a23c367256b097530ef83d845440c2cd8d4f2460d7936d4c461e9e444cc62e"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbdoc-0.45.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "b7a8c459136cb51607da83604ff159504fb08d95d6b4ce7fef536785078a1473"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbsync-0.45.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "1efc6ffd764efa2ae4f790e366cb2dc8adf958f2abe01fb154f2f74eae78bcc5"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/playbook-0.45.0-x86_64-unknown-linux-musl"
      sha256 "a6ce66ded0fb84735d440b0134a63bcdfe6bb855e8cdc2c75f25113d04a8ec81"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbdoc-0.45.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "242d07fd307c319d8f5ed4cfea40390e6c85d238898d3e7a7b65a5b302149356"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.45.0/pbsync-0.45.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "44dd8e8099419dd0076e457b4101939d685c94e5dcbb5234a9f8710bf0d75726"
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
