Gem::Specification.new do |s|
  s.name              = "ost"
  s.version           = "1.0.0.rc1"
  s.summary           = "Redis based queues and workers."
  s.description       = "Ost lets you manage queues and workers with Redis."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "http://github.com/soveran/ost"
  s.license           = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "redic"
  s.add_dependency "nido"
  s.add_development_dependency "cutest"
end
