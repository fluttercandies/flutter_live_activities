#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_live_activities.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_live_activities'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for Live Activities.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/fluttercandies/flutter_live_activities'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NONE' => 'l18281145312@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
