#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_email.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'flutter_email'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  s.header_dir = "CZCore"
  s.public_header_files = 'Classes/**/*.h'
  s.preserve_paths = "Classes/xx/*.h"
  s.vendored_libraries = 'Classes/**/*.a'
  s.framework = 'Foundation'
  s.libraries = 'c', 'z', 'c++'
  s.requires_arc = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
