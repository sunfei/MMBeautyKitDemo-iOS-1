source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://cdn.cocoapods.org/'


#use_frameworks!

platform :ios, '10.0'

target 'MMBeautyKitDemo' do

  pod 'MetalPetal/Static', '1.13.0', :modular_headers => true

# 版本5
#pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS-1/MMBeautyKitLevel5/'
#pod 'MMBeautyMedia/Beauty', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Filter', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Sticker', :path => '../MMBeautyMedia-iOS'

# 版本4
#pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS-1/MMBeautyKitLevel4/'
#pod 'MMBeautyMedia/Beauty', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Filter', :path => '../MMBeautyMedia-iOS'

# 版本3
#pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS-1/MMBeautyKitLevel3/'
#pod 'MMBeautyMedia/Beauty', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Filter', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Sticker', :path => '../MMBeautyMedia-iOS'

# 版本2
#pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS-1/MMBeautyKitLevel2/'
#pod 'MMBeautyMedia/Beauty', :path => '../MMBeautyMedia-iOS'
#pod 'MMBeautyMedia/Filter', :path => '../MMBeautyMedia-iOS'

# 版本1
#pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS-1/MMBeautyKitLevel1/'
#pod 'MMBeautyMedia/Beauty', :path => '../MMBeautyMedia-iOS'

pod 'MMCV', :git => 'https://github.com/ybhjx1314/MMCV', :branch => 'MMVC-MMVideoSDK'
  
  # 解决HTTPDNS过大问题
#  pod 'PhotonHTTPDNS','1.0.2'
  
  # 七牛直播推流
  pod 'PLMediaStreamingKit'
  
  # 腾讯直播推流
  pod 'TXLiteAVSDK_Professional'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|

        target.build_configurations.each do |config|
            config.build_settings['PROVISIONING_PROFILE'] = ''
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
            config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
    end
end
