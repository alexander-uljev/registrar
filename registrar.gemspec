Gem::Specifications.new |spec| do

  spec.name = 'registrar'
  spec.summary = 'Performs safe user registrations'
  spec.description =  File.read(File.join(File.dirname(__FILE__), 'README'))
  spec.requirements = [ 'None' ]
  spec.version = '0.2.0'
  spec.author = 'Alexander Uljev'
  spec.email = 'aleksandr.uljev@yandex.ru'
  spec.homepage = 'https://github.com/alexander-uljev/registrar'
  spec.platform = Gem::Platform::Ruby
  spec.required_ruby_version = '>=2.4.0'
  spec.files = Dir['**/**']
  spec.test_files = 'test/test*.rb'
  spec.has_rdoc = true

end