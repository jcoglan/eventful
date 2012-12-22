Gem::Specification.new do |s|
  s.name              = "eventful"
  s.version           = "1.0.1"
  s.summary           = "A little pub/sub abstraction based on Observable"
  s.author            = "James Coglan"
  s.email             = "jcoglan@gmail.com"
  s.homepage          = "http://github.com/jcoglan/eventful"

  s.extra_rdoc_files  = %w[README.rdoc]
  s.rdoc_options      = %w[--main README.rdoc]
  s.require_paths     = %w[lib]

  s.files = %w[README.rdoc History.txt] + Dir.glob("{lib,spec}/**/*.rb")

  s.add_dependency "methodphitamine", "= 1.0.0"
  s.add_development_dependency "rspec"
end

