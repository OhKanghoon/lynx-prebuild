platform :ios, '13.0'

inhibit_all_warnings!
# lynx-family stopped publishing to CocoaPods trunk after 4.0.2 ("cocoapods trunk
# is no longer maintained" -- github.com/lynx-family/Specs). From 4.1.0 on the
# Lynx, LynxBase, LynxServiceAPI, LynxService, LynxDevtool, BaseDevtool and
# XElement podspecs exist only in that self-hosted repo. PrimJS, DebugRouter and
# SocketRocket are still on trunk, so both sources stay.
source 'https://github.com/lynx-family/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'LynxPrebuild' do
  use_frameworks! # Dynamic framework for resource bundle support

  pod 'Lynx', '4.1.0', subspecs: %w[Framework]

  pod 'PrimJS', '4.1.1', subspecs: %w[quickjs napi] # Version Lynx 4.1.0 pins exactly; kept explicit so the napi subspec is requested too

  # LynxService declares no default_subspecs, so naming Devtool is what keeps
  # Http, Image and Log out. Http and Log would cost no extra framework; Image
  # would add SDWebImage, SDWebImageWebPCoder and libwebp to the release. None
  # of the three is needed as long as the host app supplies its own
  # implementations through LynxServiceAPI.
  pod 'LynxService', '4.1.0', subspecs: [
    'Devtool'
  ]
  pod 'LynxDevtool', '4.1.0'

  pod 'DebugRouter', '5.0.15'
  pod 'DebugRouter/MessageTransceiverEnable', '5.0.15'

  # XElement's default is eleven subspecs; these seven are the ones that add no
  # framework to the release, so the list has to be spelled out. The rest are
  # left out, for two different reasons:
  #
  #   Markdown, Behavior, AnimaX -- unavailable, not declined. Markdown pulls
  #     ServalMarkdown, whose own dependency LynxTextra ships as a statically
  #     linked binary, and CocoaPods refuses to embed that under
  #     use_frameworks!. Behavior (the LynxUI*AutoRegistry glue) depends on
  #     Markdown, so it is unreachable for the same reason -- which is why the
  #     host app has to register components itself. AnimaX (not in the default
  #     set) is a static_framework pod that also depends on LynxTextra.
  #
  #   SVG, Refresh -- buildable, but each drags a third-party pod (ServalSVG,
  #     MJRefresh) into the release as its own framework that consumers must
  #     then embed and version-match. Add them only if something needs those
  #     elements.
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
