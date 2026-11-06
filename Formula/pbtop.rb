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
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbtop-0.40.1-aarch64-apple-darwin.tar.gz"
      sha256 "0306b36ee7c0dcf36ad2a81a7fe79b61aeb1857091947dc259ca4046b83b0e64"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbtop-0.40.1-x86_64-apple-darwin.tar.gz"
      sha256 "fc81061d17d865e46328e2280a54371b08cb1fbf98611278f6582b3467971adf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbtop-0.40.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e9d3648cfa025e3eae2e2abddf2dd95899a4943ef456fabf40f4d74ea573d04d"
    else
      url "https://github.com/pragmatic-engineer/playbook/releases/download/v0.40.1/pbtop-0.40.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "654115f64e28ae10f28d6d80eab839b78eadf7d1fc4d18d055e896a98c914e8a"
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
