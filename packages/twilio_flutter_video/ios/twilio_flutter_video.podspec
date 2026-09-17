Pod::Spec.new do |s|
  s.name             = 'twilio_flutter_video'
  s.version          = '0.0.1'
  s.summary          = 'Typed Flutter wrapper for the Twilio Video SDK (scaffold).'
  s.description      = <<-DESC
Scaffold plugin for Twilio Video in the twilio-flutter-sdk monorepo.
                       DESC
  s.homepage         = 'https://github.com/example/twilio-flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Twilio Flutter' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
