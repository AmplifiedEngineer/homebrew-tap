class Helios < Formula
  desc "Terminal UI for your pull requests across GitHub accounts and hosts"
  homepage "https://github.com/amplifiedengineer/helios"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/helios/releases/download/v0.1.0/helios-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "906c690097a5b8448366ddd19777736901b376cfd1467f6f03da3bf4122f34b8"
    else
      url "https://github.com/amplifiedengineer/helios/releases/download/v0.1.0/helios-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "221e34a9e6b31fb168a2aa5cbc2cba2854a1f5cbd6d26cbeda2d91d41428a724"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amplifiedengineer/helios/releases/download/v0.1.0/helios-0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7ba52d390b38e0b820110b57ef8a9c3aeca93bdea98e4512c004d074e9e5fd0d"
    else
      url "https://github.com/amplifiedengineer/helios/releases/download/v0.1.0/helios-0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "cf5d9b93c01de60cf51e50c9dce571bc9552be325489792c343ed28395c904af"
    end
  end

  def install
    bin.install "helios"
  end

  def caveats
    <<~EOS
      Run `helios` to start.
      Release notes: https://github.com/amplifiedengineer/helios/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/helios --version")
  end
end
