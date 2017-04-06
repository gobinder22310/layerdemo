platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
target 'Atlas Messenger' do

  if ENV['LAYER_USE_UI_SDK_SUBMODULE'].blank? then
    pod 'Atlas'
  else
    pod 'Atlas', path: 'Libraries/Atlas'
  end
  
  if !ENV['LAYER_USE_CORE_SDK_LOCATION'].blank? then
    source 'git@github.com:layerhq/cocoapods-specs.git'
    pod 'LayerKit', path: ENV['LAYER_USE_CORE_SDK_LOCATION']
  end
  
  pod 'SVProgressHUD'
  pod 'ClusterPrePermissions', '~> 0.1'
  
  target 'Atlas MessengerTests' do
      inherit! :search_paths
      pod 'Expecta'
      pod 'OCMock'
      pod 'KIF'
      pod 'KIFViewControllerActions', git: 'https://github.com/blakewatters/KIFViewControllerActions.git'
      pod 'LYRCountDownLatch'
  end
end

# If we are building LayerKit from source then we need a post install hook to handle non-modular SQLite imports
unless ENV['LAYER_USE_CORE_SDK_LOCATION'].blank?
  post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
      configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
  end
end
