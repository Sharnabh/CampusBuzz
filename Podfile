# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'
use_frameworks!

target 'CampusBuzz' do
  # CometChat UI Kit for Swift
  pod 'CometChatUIKitSwift', '5.0.4'

  # Optional: Include if you're using Audio/Video Calling
  pod 'CometChatCallsSDK', '4.1.2'
  
  # Firebase
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseCore'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      
      # Fix gRPC-Core compilation issues
      if target.name.start_with?('gRPC')
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1'
      end
      
      # Ensure all pods have minimum deployment target
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end