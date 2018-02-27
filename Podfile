platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Alamofire'
    pod 'SwiftKeychainWrapper'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Messaging'
    pod 'Google/SignIn'
    pod 'GooglePlaces'
    pod 'FBSDKCoreKit'
    pod 'GoogleMaps'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
    pod 'FacebookShare'
    pod 'AlamofireImage'
    pod 'Branch'
    pod 'Instructions', '~> 1.0.0’
end

target ‘Teazer’ do
  shared_pods
end

target ‘Teazer-Dev’ do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
