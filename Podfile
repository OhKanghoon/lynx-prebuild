platform :ios, '16.0'

inhibit_all_warnings!
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! linkage: :static

  pod 'Lynx', '3.4.2', subspecs: %w[Framework]

  pod 'PrimJS', subspecs: %w[quickjs napi]
end
