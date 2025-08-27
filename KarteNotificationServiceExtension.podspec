#
# Be sure to run `pod lib lint KarteNotificationServiceExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                    = 'KarteNotificationServiceExtension'
    s.version                 = '1.3.0'
    s.summary                 = 'KARTE Notification Service Extension'
    s.homepage                = 'https://karte.io/'
    s.author                  = { 'PLAID' => 'dev.share@plaid.co.jp' }
    s.documentation_url       = 'https://developers.karte.io/docs/ios-sdk'
    s.license                 = { :type => 'Apache', :file => 'LICENSE' }

    s.cocoapods_version       = '>= 1.10.0'
    s.platform                = :ios
    s.ios.deployment_target   = '15.0'

    s.source                  = { :git => 'https://github.com/plaidev/karte-ios-sdk.git', :tag => "NotificationServiceExtension-#{s.version}" }
    s.source_files            = 'KarteNotificationServiceExtension/**/*.{swift,h,m}'
    
    s.requires_arc            = true
end
