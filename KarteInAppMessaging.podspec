#
# Be sure to run `pod lib lint KarteTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'KarteInAppMessaging'
  s.version                 = '2.10.1'
  s.summary                 = 'KARTE In-app messaging SDK'
  s.homepage                = 'https://karte.io'
  s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
  s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
  s.license                 = { :type => 'Apache', :file => 'LICENSE' }

  s.cocoapods_version       = '>= 1.7.0'
  s.swift_versions          = [5.1]
  s.static_framework        = true

  s.platform                = :ios
  s.ios.deployment_target   = '10.0'
  
  s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "InAppMessaging-#{s.version}" }
  s.source_files            = 'KarteInAppMessaging/**/*.{swift,h,m}'

  s.requires_arc            = true
  s.pod_target_xcconfig     = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'IN_APP_MESSAGING_VERSION=' + s.version.to_s
  }

  s.dependency 'KarteCore', '~> 2.3'
  s.dependency 'KarteUtilities', '~> 3.0'
end
