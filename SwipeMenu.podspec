Pod::Spec.new do |s|
  s.name = 'SwipeMenu'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Zero-tap, Fastest, Easy to use.'
  s.homepage = 'https://github.com/harryzjm/SwipeMenu'
  s.authors = { 'Hares' => 'harryzjm@live.com' }
  s.source = { :git => 'https://github.com/harryzjm/SwipeMenu.git', :tag => s.version }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Source/*.swift'

  s.swift_versions = ['5.0']
end
