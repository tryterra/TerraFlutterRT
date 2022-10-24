#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint terra_flutter_rt.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'terra_flutter_rt'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://tryterra.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'JaafarRammal' => 'jaafar@tryterra.co' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'TerraRTiOS', '~> 0.0.4'
  s.frameworks = ['HealthKit']

  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
