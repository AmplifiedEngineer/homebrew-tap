class Playbook < Formula
  desc "Claude Code plugin toolkit: hooks, launcher, and installer in one binary"
  homepage "https://github.com/pragmatic-engineer/playbook"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/playbook-0.40.0-aarch64-apple-darwin"
      sha256 "2174578d96cd65b1c3d8384998085d9fc951cba2cb9d3aed8c0e335f4c639bf6"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbdoc-0.40.0-aarch64-apple-darwin.tar.gz"
        sha256 "48613ea4bf0927565308fd86194fcbb4e99194c1e60921443c4c6602aed3e6f0"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/playbook-0.40.0-x86_64-apple-darwin"
      sha256 "828690ccd32de50d1bf0130903b5671cf27a06feb1e2415906da7e0d5c543e12"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbdoc-0.40.0-x86_64-apple-darwin.tar.gz"
        sha256 "e0c99a39320e66ff3538f9d765c53bff78f93dcabde5891c98cb92bc9a288839"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/playbook-0.40.0-aarch64-unknown-linux-musl"
      sha256 "cbe43f96269eed0c9effacd51924e2ca9bdb841c59c540e9d3bcc1f8c8a657ba"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbdoc-0.40.0-aarch64-unknown-linux-musl.tar.gz"
        sha256 "b244dc5a1e105238e7a480f5fe466f56368ae12a724825fbdae6d0bcdc2fd714"
      end
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/playbook-0.40.0-x86_64-unknown-linux-musl"
      sha256 "41f68aa1d60cc3ba642d66d143b14521a87377f2ea0dc6ee43c1a256ee2bb586"
      resource "pbdoc" do
        url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.0/pbdoc-0.40.0-x86_64-unknown-linux-musl.tar.gz"
        sha256 "0f6cb58b02e361ab0a780427ba7bc5a6968006e37a01370631ca24afd68c08e4"
      end
    end
  end

  def install
    bin.install Dir["playbook-*"].first => "playbook"
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
      Installing never edits your Claude Code settings. Upgrade with `brew upgrade playbook`.
      Release notes: https://github.com/pragmatic-engineer/playbook/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/playbook --version")
    assert_match version.to_s, shell_output("#{bin}/pb --version")
    assert_match version.to_s, shell_output("#{bin}/pbdoc --version")
  end
end
