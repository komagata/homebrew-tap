class Tya < Formula
  desc "Small indentation-based dynamic language"
  homepage "https://github.com/komagata/tya"
  url "https://github.com/komagata/tya/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "1ed24a89657d66f8ea3f5c0abbcdca9de608dc62a1f80296fc709f361398a337"
  head "https://github.com/komagata/tya.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(output: bin/"tya"), "./cmd/tya"
    (pkgshare/"runtime").install Dir["runtime/*"]
    (pkgshare/"stdlib").install Dir["stdlib/*"]
  end

  test do
    (testpath/"hello.tya").write <<~TYA
      import string

      print "Hello, Tya"
      print string.blank(" ")
    TYA
    (testpath/"hello_test.tya").write <<~TYA
      import string

      assert string.blank(" ")
      assert_equal false, string.blank("tya")
    TYA

    assert_equal "0.11.0\n", shell_output("#{bin}/tya version")
    assert_equal "Hello, Tya\ntrue\n", shell_output("#{bin}/tya run #{testpath}/hello.tya")
    assert_empty shell_output("#{bin}/tya test #{testpath}/hello_test.tya")
  end
end
