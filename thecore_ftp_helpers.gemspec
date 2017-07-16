$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "thecore_ftp_helpers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "thecore_ftp_helpers"
  s.version     = ThecoreFtpHelpers::VERSION
  s.authors     = ["Gabriele Tassoni"]
  s.email       = ["gabriele.tassoni@gmail.com"]
  s.homepage = 'https://www.taris.it' #    = "TODO"
  s.summary = 'Thecorized thecore_ftp_helpers' #     = "TODO: Summary of ThecoreFtpHelpers."
  s.description = 'Thecorized thecore_ftp_helpers full description.' # = "TODO: Description of ThecoreFtpHelpers."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # s.add_dependency "rails", "~> 5.1.2"

  # s.add_development_dependency "sqlite3"
  s.add_dependency 'thecore', '~> 1.1'
end
