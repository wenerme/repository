# brew install --build-from-source wenerme/repository/tinc-pre
class TincPre < Formula
  desc "Virtual Private Network (VPN) tool"
  homepage "https://www.tinc-vpn.org/"
  url "https://github.com/wenerme/tinc/archive/573ab11543df5e18c720e930f596f9ab837b3012.tar.gz"
  version "1.1pre18"
  sha256 "9e53603b3325dbc800a99b89d44ca2c2fab7cf08089bd46ec2a3550043c21b2a"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "lzo"
  depends_on "lz4"
  depends_on "openssl"
  depends_on "zlib"

  # All patches (ConnectTo protection, dynamic autoconnect threshold,
  # macOS ifreq fix, lzo include path fix) are in the source repo.

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
