Gem::Specification.new do |s|
  s.name	= 'fub'
  s.version	= '0.0.4'
  s.date	= '2022-06-22'
  s.summary	= "Followup Boss API library"
  s.description	= "Library to communicate with Followup Boss"
  s.authors	= ["Bill Nelson"]
  s.email	= 'bill@neuralstate.ai'
  s.files	= ["lib/fub.rb", "lib/events.rb"]
  s.homepage	= 'https://github.com/OlsonLabs/fub.gem'
  s.license	= 'Nonstandard'

  s.add_runtime_dependency 'httparty'
end
