platform :ios, '13.0'

inhibit_all_warnings!
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks!  # Dynamic framework for resource bundle support

  pod 'Lynx', '3.6.0', subspecs: %w[Framework]

  pod 'PrimJS', subspecs: %w[quickjs napi]
end
