#
# Be sure to run `pod lib lint NYLBluetooth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NYLBluetooth'
  s.version          = '0.2.0'
  s.summary          = '蓝牙封装'
  s.homepage         = 'https://github.com/Nieyinlong/NYLBluetooth'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nieyinlong' => 'nyl0819@126.com' }
  s.source           = { :git => 'https://github.com/Nieyinlong/NYLBluetooth.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'NYLBluetooth/Classes/**/*'

end
