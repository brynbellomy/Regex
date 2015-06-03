Pod::Spec.new do |s|
  s.name = 'Regex'
  s.version = '0.2.1'
  s.license = { :type => 'MIT', :file => 'LICENSE.md' }
  s.homepage = 'https://github.com/brynbellomy/Regex'
  s.authors = { 'bryn austin bellomy' => 'bryn.bellomy@gmail.com' }
  s.summary = 'Regular expression class (in Swift).  Wraps NSRegularExpression.'
  s.documentation_url = 'http://brynbellomy.github.io/Regex/index.html'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source_files = 'src/*.swift'
  s.requires_arc = true

  s.source = { :git => 'https://github.com/brynbellomy/Regex.git', :tag => s.version }
end
