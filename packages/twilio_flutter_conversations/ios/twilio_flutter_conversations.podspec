#
# Run `pod lib lint twilio_flutter_conversations.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'twilio_flutter_conversations'
  s.version          = '0.0.1'
  s.summary          = 'Typed Flutter wrapper for the Twilio Conversations SDK.'
  s.description      = <<-DESC
Typed Flutter wrapper for the Twilio Conversations SDK on iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/example/twilio-flutter-conversations'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Twilio Flutter Conversations' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'TwilioConversationsClient', '~> 4.0'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
