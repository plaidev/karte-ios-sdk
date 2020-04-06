#
# Be sure to run `pod lib lint KarteTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'KarteDetectors'
  s.version                 = '2.0.0'
  s.summary                 = 'KARTE Detectors SDK'
  s.homepage                = 'https://karte.io'
  s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
  s.social_media_url        = 'https://twitter.com/karte_io'
  s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
  s.license                 = { :type => 'Apache', :file => 'LICENSE' }

  s.cocoapods_version       = '>= 1.9.0'

  s.platform                = :ios
  s.ios.deployment_target   = '9.0'
  
  s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "Detectors-#{s.version}" }
  s.vendored_frameworks     = 'KarteDetectors/KarteDetectors.xcframework'

  s.requires_arc            = true
end
