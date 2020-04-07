#
# Be sure to run `pod lib lint KarteTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'KarteCrashReporting'
  s.version                 = '1.0.0'
  s.summary                 = 'KARTE Crash reporting SDK'
  s.homepage                = 'https://karte.io'
  s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
  s.social_media_url        = 'https://twitter.com/karte_io'
  s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
  s.license                 = { :type => 'Apache', :file => 'LICENSE' }

  s.cocoapods_version       = '>= 1.7.0'
  s.swift_versions          = [5.1]
  s.static_framework        = true

  s.platform                = :ios
  s.ios.deployment_target   = '9.0'
  
  s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "CrashReporting-#{s.version}" }
  s.source_files            = 'KarteCrashReporting/**/*.{swift,h,m}'
  s.exclude_files           = 'KarteCrashReporting/PLCrashReporter'
  
  s.requires_arc            = true
  s.pod_target_xcconfig     = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'CRASH_REPORTING_VERSION=' + s.version.to_s,
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/KarteCrashReporter"'
  }

  s.dependency 'KarteCore', '~> 2.0'
  s.dependency 'KarteCrashReporter', '1.2.4'
end
