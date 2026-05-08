class Tya < Formula
  desc "Small indentation-based dynamic language"
  homepage "https://github.com/komagata/tya"
  url "https://github.com/komagata/tya/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "a9c70b1a2b9c090c326327efe76cc104e3842c6c3d965f2f2a2b7aeed9ca51c1"
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

    assert_equal "0.19.0\n", shell_output("#{bin}/tya version")
    assert_equal "Hello, Tya\ntrue\n", shell_output("#{bin}/tya run #{testpath}/hello.tya")
    assert_empty shell_output("#{bin}/tya test #{testpath}/hello_test.tya")
  end
end
