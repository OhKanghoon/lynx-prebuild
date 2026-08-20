platform :ios, '13.0'

inhibit_all_warnings!
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! # Dynamic framework for resource bundle support

  pod 'Lynx', '3.9.0', subspecs: %w[Framework]

  pod 'PrimJS', '3.8.0-alpha.6', subspecs: %w[quickjs napi] # Pre-release required by Lynx 3.9.0; must be pinned explicitly

  pod 'LynxService', '3.9.0', subspecs: [
    'Devtool'
  ]
  pod 'LynxDevtool', '3.9.0'

  pod 'DebugRouter', '5.0.15'
  pod 'DebugRouter/MessageTransceiverEnable', '5.0.15'

  pod 'XElement', '3.9.0', subspecs: %w[
    ScrollCoordinator
    ViewPager
    Input
    Overlay
  ]
end
