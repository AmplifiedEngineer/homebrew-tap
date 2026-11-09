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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/playbook-0.42.0-aarch64-apple-darwin"
      sha256 "600e39e398e3da732ad336a17a0a253c5d7b53876f679db212cfd6a1a81630e7"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbdoc-0.42.0-aarch64-apple-darwin.tar.gz"
        sha256 "b7a8e126e669c61d0237235ec17b0aaa21c283e801ae0bfdc1942d068695c437"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbsync-0.42.0-aarch64-apple-darwin.tar.gz"
        sha256 "377b5354436e1f6041795c69961cd99ba5f411a361006beece14b43f479fcbca"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/playbook-0.42.0-x86_64-apple-darwin"
      sha256 "73b272bbf41a9184645c319566fa8d08419fa5f4bd0274335f2218c242ba10a6"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbdoc-0.42.0-x86_64-apple-darwin.tar.gz"
        sha256 "dbace89bf32364c4fc899b041b68c8347a087f8f39794772aa3faef933ffd39a"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbsync-0.42.0-x86_64-apple-darwin.tar.gz"
        sha256 "5f3f77060d4850a14b174cc0f01c76fd344f0bce5413dfb8e3e4109f0a5d2a0e"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/playbook-0.42.0-aarch64-unknown-linux-musl"
      sha256 "cef5a5951f9e14efc4aaa9b6eb6bb058f4d04934d919c2ec1307a1e0a4bacad4"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbdoc-0.42.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "f94762523b0974b9375af4af463800272b1053d3227a02074c87eb27dd41489e"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbsync-0.42.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "7f1a14269ac783ceb54a31f119d56626a63af3dac2b688dcf0eb35aa6e22878e"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/playbook-0.42.0-x86_64-unknown-linux-musl"
      sha256 "49e023cab880e39ebcbbd254f0f6902a16823a6b98706112148ec803f82f10d5"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbdoc-0.42.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "748bc8ca0636e2dc27d141efd3d51f2bbd5588d0d349603a0510107cc4bddf93"
      end
      resource "pbsync" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.42.0/pbsync-0.42.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "b36a224d0d336e42b044b13158b4029745391063c2c6b1a5fab260442479ee16"
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
