class Tya < Formula
  desc "Small indentation-based dynamic language"
  homepage "https://github.com/komagata/tya"
  url "https://github.com/komagata/tya/archive/refs/tags/v0.72.12.tar.gz"
  sha256 "f8e0cafa52d88243bb3ad2a08a380ea462478efcf5b86a21c6fa557ad2630848"
  license "MIT"
  head "https://github.com/komagata/tya.git", branch: "main"

  depends_on "go" => :build
  depends_on "openssl@3"
  depends_on "zig"

  def install
    inreplace "runtime/tya_runtime.c",
      "#define _DEFAULT_SOURCE\n#endif",
      "#define _DEFAULT_SOURCE\n#endif\n#ifndef _DARWIN_C_SOURCE\n#define _DARWIN_C_SOURCE\n#endif"

    system "go", "build", *std_go_args(output: libexec/"tya"), "./cmd/tya"
    (pkgshare/"runtime").install Dir["runtime/*"]
    (pkgshare/"lib").install Dir["lib/*"]

    openssl = Formula["openssl@3"]
    (bin/"tya").write_env_script libexec/"tya",
      CPATH:           openssl.opt_include,
      LIBRARY_PATH:    openssl.opt_lib,
      PKG_CONFIG_PATH: openssl.opt_lib/"pkgconfig"
  end

  test do
    (testpath/"hello.tya").write <<~TYA
      print("Hello, Tya")
      print("  ".blank?())
    TYA

    assert_equal "0.72.12\n", shell_output("#{bin}/tya version")
    assert_equal "Hello, Tya\ntrue\n", shell_output("#{bin}/tya run #{testpath}/hello.tya")

    # v0.49: `tya new` scaffolds a minimal project tree.
    cd testpath do
      system bin/"tya", "new", "scaffold"
      assert_path_exists testpath/"scaffold/tya.toml"
      assert_path_exists testpath/"scaffold/src/main.tya"
      assert_path_exists testpath/"scaffold/.gitignore"
    end

    # v0.49: `tya task` lists tasks defined in tya.toml.
    cd testpath/"scaffold" do
      output = shell_output("#{bin}/tya task")
      assert_match "run", output
    end

    # v0.49: `tya lint` reports unused locals on dirty sources.
    (testpath/"dirty.tya").write <<~TYA
      x = 1
      y = 2
      print(x)
    TYA
    assert_match "TYAL0001", shell_output("#{bin}/tya lint #{testpath}/dirty.tya", 1)

    # v0.52: `tya lsp --help` prints usage and exits 0.
    assert_match "tya lsp", shell_output("#{bin}/tya lsp --help")

    # v0.51: `tya doc` walks src/ and reports top-level bindings.
    (testpath/"docproj/src").mkpath
    (testpath/"docproj/src/lib.tya").write <<~TYA
      # Returns the doubled value.
      double = x -> x * 2
    TYA
    cd testpath/"docproj" do
      assert_match "function double", shell_output("#{bin}/tya doc")
    end
  end
end
