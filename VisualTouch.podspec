Pod::Spec.new do |s|
  s.name = 'VisualTouch'
  s.version = '1.1.1'
  s.license = 'MIT'
  s.summary = 'Make touch events visual'
  s.homepage = 'https://github.com/donpark/VisualTouch'
  s.authors = { 'Don Park' => 'donpark@docuverse.com' }
  s.source = { :git => 'https://github.com/donpark/VisualTouch.git', :tag => s.version }
  s.ios.deployment_target = '10.0'
  s.source_files = 'VisualTouch/*.swift'
  s.requires_arc = true
end
