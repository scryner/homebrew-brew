class MyStreamdeck < Formula
  desc "Menu bar controller for an Elgato Stream Deck"
  homepage "https://github.com/scryner/my-streamdeck"
  url "https://github.com/scryner/my-streamdeck/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "65806fe00c95f07973e6a0e9befcd883515cdacb93d2fcbe2b117c3ce013df3a"
  license "MIT"
  head "https://github.com/scryner/my-streamdeck.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  service do
    run [opt_bin/"my-streamdeck"]
    keep_alive crashed: true
    process_type :interactive
    environment_variables PATH: std_service_path_env
    log_path var/"log/my-streamdeck.log"
    error_log_path var/"log/my-streamdeck.err.log"
  end

  def caveats
    <<~EOS
      To customize the app configuration:
        my-streamdeck init

      Start the menu bar app with:
        brew services start my-streamdeck

      The service must run in the logged-in macOS user session for the menu bar item to appear.
    EOS
  end

  test do
    ENV["HOME"] = testpath

    config_template = testpath/".my-streamdeck/config.yaml.template"
    output = shell_output("#{bin}/my-streamdeck init")

    assert_match "created #{config_template}", output
    assert_path_exists config_template
  end
end
