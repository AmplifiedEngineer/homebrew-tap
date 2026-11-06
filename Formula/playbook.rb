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
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/playbook-0.40.1-aarch64-apple-darwin"
      sha256 "50c848be5056076b93f44a76e36d0d7f4e9727cdb8ae5f529d0db918f837f2c3"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbdoc-0.40.1-aarch64-apple-darwin.tar.gz"
        sha256 "afeb0679ca8e53d2a82d296fed47407d003a18682e028433d03db6e4833939af"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/playbook-0.40.1-x86_64-apple-darwin"
      sha256 "2713e5571011d92563f24801a6b1981e234a6cb59136ef3e1c0281de8af1b107"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbdoc-0.40.1-x86_64-apple-darwin.tar.gz"
        sha256 "a4fb8225bc76e2b3ab1d47e74d80f52f8d146e14a094066fd7827781c8732483"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/playbook-0.40.1-aarch64-unknown-linux-musl"
      sha256 "7b253e94067b97f0c8f5a1fa202b979905b07dd7ca1fb42d930f61448c724844"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbdoc-0.40.1-aarch64-unknown-linux-musl.tar.gz"
        sha256 "363f4e4463ad601fd8d1d55197c92872e34f7d9a1d20cfa8fd3fbbaf11528c8a"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/playbook-0.40.1-x86_64-unknown-linux-musl"
      sha256 "af4e48cf8b1a45ccbbd6280d6a3af87b57ce7c0200364a53b261bab32d167c4c"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbdoc-0.40.1-x86_64-unknown-linux-musl.tar.gz"
        sha256 "88a52abcb6bfe733f9386c308bcdecc312f53dc4cde08d707126e3f4a5394db2"
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
