#
# Be sure to run `pod lib lint KarteTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'KarteUtilities'
  s.version                 = '3.9.0'
  s.summary                 = 'KARTE Utilities SDK'
  s.homepage                = 'https://karte.io'
  s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
  s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
  s.license                 = { :type => 'Apache', :file => 'LICENSE' }

  s.cocoapods_version       = '>= 1.10.0'
  s.swift_versions          = [5.1]

  s.platform                = :ios
  s.ios.deployment_target   = '11.0'
  
  s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "Utilities-#{s.version}" }
  s.default_subspec  = 'standard'
  
  s.requires_arc            = true
  s.pod_target_xcconfig     = {
    'OTHER_SWIFT_FLAGS' => '$(inherited) -suppress-warnings',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'UTILITIES_VERSION=' + s.version.to_s
  }
  
  s.subspec 'standard' do |ss|
    ss.source_files = 'KarteUtilities/**/*.{swift,h,m}'
    ss.resource_bundles        = { 'KarteUtilities' => ['KarteUtilities/PrivacyInfo.xcprivacy'] }
    ss.library = 'sqlite3'
  end

  s.subspec 'sqlite-standalone' do |ss|
    ss.source_files = 'KarteUtilities/**/*.{swift,h,m}'
    ss.xcconfig = {
      'OTHER_SWIFT_FLAGS' => '$(inherited) -DKARTE_SQLITE_STANDALONE',
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) KARTE_SQLITE_STANDALONE=1'
    }
    ss.dependency 'sqlite3'
  end
end
