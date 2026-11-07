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
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/playbook-0.41.0-aarch64-apple-darwin"
      sha256 "99ccd6855b981e68ce3a28d2faa899cf18556c3612368d92c527dd8b3168f2b0"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/pbdoc-0.41.0-aarch64-apple-darwin.tar.gz"
        sha256 "c0b90bfa20da96a64c9bd858067647ac62f7ebd245c75411c5b4fc6e949de9dc"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/playbook-0.41.0-x86_64-apple-darwin"
      sha256 "3e07ad5cbfe20ce7ce290b6eb5c11b6e8f3a9852d6b7067f7d6d9804d7ebadf2"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/pbdoc-0.41.0-x86_64-apple-darwin.tar.gz"
        sha256 "a7b32ad8cc228b660e34d93b7e5e97a9a86ae36143fc1401a44f612a444935e2"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/playbook-0.41.0-aarch64-unknown-linux-musl"
      sha256 "f4457a8060ff222e3821224a6d1108922fdfa33bc5f744eadfbc3cc985e3b658"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/pbdoc-0.41.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "0b32ee06a2d9f37936d8c2b75e441711752c6564216ca3a6461024da4d13ee34"
      end
    else
      url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/playbook-0.41.0-x86_64-unknown-linux-musl"
      sha256 "d05329ff82acc60e76e4606d2211f22019045db96b6f3cc740c3ba48b924e392"
      resource "pbdoc" do
        url "https://github.com/amplifiedengineer/playbook/releases/download/v0.41.0/pbdoc-0.41.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "d70f24e6eb8b2c7d07e5cb864439672ac1b353e755818d4da92ac0876afa629d"
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
      Release notes: https://github.com/amplifiedengineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/playbook --version")
    assert_match "pbtop #{version}", shell_output("#{bin}/pbtop --version")
    assert_match version.to_s, shell_output("#{bin}/pb --version")
    assert_match version.to_s, shell_output("#{bin}/pbdoc --version")
  end
end
