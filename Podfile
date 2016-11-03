target 'ChromecastDemo' do
    pod 'KalturaPlayerSDK', :git => 'https://github.com/kaltura/player-sdk-native-ios.git', :tag => 'v2.6.0.rc3'
    pod 'google-cast-sdk'
end

post_install do |installer|
    kp_targets = installer.pods_project.targets.select { |target| target.name == 'KalturaPlayerSDK' }
    kp_targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = '0'
        end
    end
end
