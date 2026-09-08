platform :ios, '13.0'

inhibit_all_warnings!
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! # Dynamic framework for resource bundle support

  pod 'Lynx', '4.0.1', subspecs: %w[Framework]

  pod 'PrimJS', '4.0.0', subspecs: %w[quickjs napi] # Version Lynx 4.0.1 pins exactly; kept explicit so the napi subspec is requested too

  pod 'LynxService', '4.0.1', subspecs: [
    'Devtool'
  ]
  pod 'LynxDevtool', '4.0.1'

  pod 'DebugRouter', '5.0.15'
  pod 'DebugRouter/MessageTransceiverEnable', '5.0.15'

  pod 'XElement', '4.0.1', subspecs: %w[
    ScrollCoordinator
    ViewPager
    Input
    Overlay
  ]
end
