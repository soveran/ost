task :test do
  require "cutest"
  ENV["OST_TIMEOUT"] ||= "1"
  Cutest.run(Dir["test/ost*"])
end

task :default => :test
