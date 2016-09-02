target 'ChromecastDemo' do
  pod 'KalturaPlayerSDK', '~> 2.4.2’
  pod 'google-cast-sdk', '2.10.4'
end

post_install do |installer|
    kp_targets = installer.pods_project.targets.select { |target| target.name == 'KalturaPlayerSDK' }
    kp_targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = '0'
        end
    end
end