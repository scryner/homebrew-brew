class Hellouvpy < Formula
  desc "A simple Python CLI application packaged with uv"
  homepage "https://github.com/scryner/hellopyuv"
  url "https://github.com/scryner/hellopyuv.git", branch: "main"
  version "0.1.0"

  depends_on "python"
  depends_on "uv"

  def install
    # Copy all source files into Homebrew's private libexec directory.
    libexec.install Dir["*"]

    # Create a dedicated virtual environment inside libexec.
    venv_dir = libexec/"venv"
    system Formula["uv"].opt_bin/"uv", "venv", venv_dir, "--python", Formula["python"].opt_bin/"python3"

    # Prepend the venv's bin to PATH and set VIRTUAL_ENV for subsequent commands.
    ENV.prepend_path "PATH", venv_dir/"bin"
    ENV["VIRTUAL_ENV"] = venv_dir

    # Install the package (and its dependencies) into the virtual environment.
    Dir.chdir(libexec) do
      system "uv", "pip", "install", "."
    end

    # Create a wrapper script that runs the main entry point inside the virtual environment.
    # The script invokes the Python interpreter from the venv and executes libexec/main.py.
    (bin/"hellopyuv").write <<~EOS
      #!/usr/bin/env bash
      exec "#{venv_dir}/bin/python" "#{libexec}/main.py" "$@"
    EOS

  end

  test do
    # Verify that the command runs and produces the expected output.
    assert_match "Hello from hellopyuv!", shell_output("#{bin}/hellopyuv")
  end
end
