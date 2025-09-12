#
# Be sure to run `pod lib lint KarteDebugger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'KarteDebugger'
  s.version                 = '1.1.0'
  s.summary                 = 'KARTE Debugger SDK'
  s.homepage                = 'https://karte.io'
  s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
  s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
  s.license                 = { :type => 'Apache', :file => 'LICENSE' }

  s.cocoapods_version       = '>= 1.10.0'
  s.swift_versions          = [5.2]
  s.static_framework        = true
  
  s.platform                = :ios
  s.ios.deployment_target   = '15.0'
  
  s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "Debugger-#{s.version}" }
  s.source_files            = 'KarteDebugger/**/*.{swift,h,m}'

  s.requires_arc            = true
  s.pod_target_xcconfig     = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'DEBUGGER_VERSION=' + s.version.to_s
  }

  s.dependency 'KarteCore', '~> 2.32'
  s.dependency 'KarteUtilities', '~> 3.14'
end
