# source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
use_frameworks!
#install! 'cocoapods', :warn_for_unused_master_specs_repo => false
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false, :warn_for_unused_master_specs_repo => false

target 'EpubBookReader' do
  # Comment the next line if you don't want to use dynamic frameworks

  #Pods for EpubBookReader
  
  # Network
  pod 'Alamofire', :inhibit_warnings => true #, '~> 5.2.2' #5.5.0
  
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
