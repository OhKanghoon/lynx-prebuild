platform :ios, '13.0'

inhibit_all_warnings!
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! # Dynamic framework for resource bundle support

  pod 'Lynx', '4.0.1', subspecs: %w[Framework]

  pod 'PrimJS', '4.0.0', subspecs: %w[quickjs napi] # Version Lynx 4.0.1 pins exactly; kept explicit so the napi subspec is requested too

  # LynxService declares no default_subspecs, so naming Devtool is what keeps
  # Http, Image and Log out. Http and Log would cost no extra framework; Image
  # would add SDWebImage, SDWebImageWebPCoder and libwebp to the release. None
  # of the three is needed as long as the host app supplies its own
  # implementations through LynxServiceAPI.
  pod 'LynxService', '4.0.1', subspecs: [
    'Devtool'
  ]
  pod 'LynxDevtool', '4.0.1'

  pod 'DebugRouter', '5.0.15'
  pod 'DebugRouter/MessageTransceiverEnable', '5.0.15'

  # XElement's default is all ten subspecs; these six are the ones that add no
  # framework to the release, so the list has to be spelled out. Four are left
  # out, for two different reasons:
  #
  #   Markdown, Behavior -- unavailable, not declined. Markdown pulls
  #     ServalMarkdown, whose own dependency LynxTextra ships as a statically
  #     linked binary, and CocoaPods refuses to embed that under
  #     use_frameworks!. Behavior (the LynxUI*AutoRegistry glue) depends on
  #     Markdown, so it is unreachable for the same reason -- which is why the
  #     host app has to register components itself.
  #
  #   SVG, Refresh -- buildable, but each drags a third-party pod (ServalSVG,
  #     MJRefresh) into the release as its own framework that consumers must
  #     then embed and version-match. Add them only if something needs those
  #     elements.
  pod 'XElement', '4.0.1', subspecs: %w[
    BlurView
    Input
    Overlay
    ScrollCoordinator
    ViewPager
    WebView
  ]
end
