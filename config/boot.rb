ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
# bootsnap を一時的に無効化
unless ENV["DISABLE_BOOTSNAP"] == "1"
  require "bootsnap/setup" # Speed up boot time by caching expensive operations.
end
