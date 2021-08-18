#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flic_button.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flic_button'
  s.version          = '0.0.1'
  s.summary          = 'An interface to the flic button.'
  s.description      = <<-DESC
An interface to the flic button.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  s.preserve_paths = './flic2lib.xcframework/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework flic2lib' }
  s.vendored_framework = 'flic2lib.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
