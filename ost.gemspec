require "./lib/ost"

Gem::Specification.new do |s|
  s.name              = "ost"
  s.version           = Ost::VERSION
  s.summary           = "Redis based queues and workers."
  s.description       = "Ost lets you manage queues and workers with Redis."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "http://github.com/soveran/ost"

  s.files = Dir[
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/*.*"
  ]

  s.add_dependency "nest", "~> 1.0"
  s.add_development_dependency "cutest", "~> 1.0"
end
