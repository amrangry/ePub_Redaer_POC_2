# source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
use_frameworks!
#install! 'cocoapods', :warn_for_unused_master_specs_repo => false
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false, :warn_for_unused_master_specs_repo => false

target 'EpubBookReader' do
  # Comment the next line if you don't want to use dynamic frameworks
  
  #Pods for EpubBookReader
  
  # CodeSmell
  pod 'SwiftLint', :inhibit_warnings => true #, '~> 0.39.2' # 0.45.1
  # KeyBoard
  pod 'IQKeyboardManagerSwift', :inhibit_warnings => true #, '~> 6.5.6' #6.5.9
  # Network
  pod 'Alamofire', :inhibit_warnings => true #, '~> 5.2.2' #5.5.0
  pod 'Kingfisher', :inhibit_warnings => true #, '~> 5.14.1' # 7.1.2
  pod 'ReachabilitySwift', :inhibit_warnings => true #, '~> 5.0.0'
  # Secure layers
  pod 'KeychainSwift', :inhibit_warnings => true #, '~> 19.0' # 20.0.0
  pod 'JWTDecode', :inhibit_warnings => true #, '~> 2.6.3'
  # UI
  pod 'RAMAnimatedTabBarController', :inhibit_warnings => true #5.2.0
  pod 'FloatRatingView', :git => 'https://github.com/amrangry/FloatRatingView.git', :inhibit_warnings => true #, '~> 4.0'
  pod 'MGStarRatingView', :git => 'https://github.com/amrangry/MGStarRatingView.git', :inhibit_warnings => true
  pod 'AnimatedField', :inhibit_warnings => true #, '~> 2.4.4'
  pod 'Loaf', :inhibit_warnings => true #, '~> 0.7.0'
  # Loader & alert
  pod 'SVProgressHUD', :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git' , :inhibit_warnings => true #SVProgressHUD (2.2.6)
  pod "KRProgressHUD", :inhibit_warnings => true #, '~> 3.4.6' # 3.4.7 #https://github.com/krimpedance/KRProgressHUD
  pod 'SwiftMessages', :inhibit_warnings => true #, '~> 9.0.5' # 9.0.6
  # Helper
  pod 'ClockWise', :inhibit_warnings => true #, '~> 1.2.3' #1.2.5
  pod 'PocketSVG' # 2.7.2

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO' # issue while signing via xCode 14.0.1
      #            config.build_settings['SWIFT_2.4.0'] = '5.1.4'
      #            config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
