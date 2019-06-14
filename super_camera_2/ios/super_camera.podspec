#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'super_camera'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin used as a base for accessing a camera. This plugin handles most of differences between cameras on different platforms and creates an easy way to create more complex camera plugins.'
  s.description      = <<-DESC
A Flutter plugin used as a base for accessing a camera. This plugin handles most of differences between cameras on different platforms and creates an easy way to create more complex camera plugins.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

