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
  pod 'FirebaseStorage'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      
      # Fix for duplicate framework issues
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      
      # Fix gRPC-Core compilation issues
      if target.name.start_with?('gRPC')
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1'
      end
      
      # Fix for abseil and other Google frameworks
      if target.name.start_with?('abseil') || target.name.start_with?('grpc') || target.name.start_with?('openssl')
        config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      end
      
      # Ensure all pods have minimum deployment target
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
  
  # Remove duplicate targets
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end