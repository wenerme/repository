# brew install --build-from-source wenerme/repository/tinc-pre
class TincPre < Formula
  desc "Virtual Private Network (VPN) tool"
  homepage "https://www.tinc-vpn.org/"
  url "https://github.com/wenerme/tinc/archive/9f8c4f415d35b33342f40ff35b52f0d3e4681fab.tar.gz"
  version "1.1pre18"
  sha256 "9d8a49321c733e0e18d548642fe2a6c13e32781c9a75f45f6ef0a83ade636842"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "lzo"
  depends_on "lz4"
  depends_on "openssl"
  depends_on "zlib"

  # All patches (ConnectTo protection, dynamic autoconnect threshold,
  # EWMA edge weights, macOS ifreq fix, lzo include path fix) are in
  # the source repo.

  def install
    args = %W[
      -Dcrypto=openssl
      -Dlzo=enabled
      -Dlz4=enabled
      -Dsysconfdir=#{etc}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match "tinc version", shell_output("#{sbin}/tincd --version")
  end
end
