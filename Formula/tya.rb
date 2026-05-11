class Tya < Formula
  desc "Small indentation-based dynamic language"
  homepage "https://github.com/komagata/tya"
  url "https://github.com/komagata/tya/archive/refs/tags/v0.48.0.tar.gz"
  sha256 "03ae3593b2fa4be6ad3cc9a9b7a98d28bf8e412a78239faeab360b14ca469f8d"
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

      print("Hello, Tya")
      print(string.blank(" "))
    TYA

    assert_equal "0.48.0\n", shell_output("#{bin}/tya version")
    assert_equal "Hello, Tya\ntrue\n", shell_output("#{bin}/tya run #{testpath}/hello.tya")
  end
end
