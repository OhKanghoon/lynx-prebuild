platform :ios, '13.0'

inhibit_all_warnings!
source 'https://github.com/lynx-family/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! # Dynamic framework for resource bundle support

  pod 'Lynx', '4.1.0', subspecs: %w[Framework]

  pod 'PrimJS', '4.1.1', subspecs: %w[quickjs napi]

  pod 'LynxService', '4.1.0', subspecs: [
    'Devtool'
  ]
  pod 'LynxDevtool', '4.1.0'

  pod 'DebugRouter', '5.0.15'
  pod 'DebugRouter/MessageTransceiverEnable', '5.0.15'

  pod 'XElement', '4.1.0', subspecs: %w[
    BlurView
    Input
    Overlay
    ScrollCoordinator
    Video
    ViewPager
    WebView
  ]
end

post_install do |installer|
  target = installer.pods_project.targets.find { |t| t.name == 'LynxDevtool' }
  next unless target

  stubs = target.source_build_phase.files.select do |bf|
    bf.file_ref&.path.to_s.match?(/rts_inspector_manager_factory_stub(_ios)?\.cc\z/)
  end
  next unless stubs.size == 2

  ios_stub = stubs.find { |bf| bf.file_ref.path.to_s.end_with?('_stub_ios.cc') }
  target.source_build_phase.remove_build_file(ios_stub)
  puts "LynxDevtool: dropped rts_inspector_manager_factory_stub_ios.cc (duplicate of the generic stub)"
end
