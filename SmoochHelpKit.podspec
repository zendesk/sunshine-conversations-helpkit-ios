Pod::Spec.new do |s|
  s.name                  = "SmoochHelpKit"
  s.version               = "1.0.1"
  s.summary               = "Help Kit extension to the Smooch SDK"
  s.description           = "Smooch adds beautifully simple messaging to your app to keep your users engaged and coming back. Help Kit adds self-help through search and recommendations, as well as an app-wide gesture to get help from anywhere."
  s.homepage              = "https://smooch.io"
  s.license               = { :type => "Commercial", :text => "Smooch Technologies Inc.  All rights reserved." }
  s.author                = { "Smooch Technologies Inc." => "hello@smooch.io" }
  s.platform              = :ios, "7.0"
  s.source                = { :git => "https://github.com/smooch/smooch-helpkit-ios.git", :tag => "1.0.1" }
  s.source_files          = "SmoochHelpKit/Source/**/*.{h,m}"
  s.resources             = "SmoochHelpKit/SHKResources.bundle"
  s.frameworks            = "SystemConfiguration", "UIKit", "Foundation", "OpenGLES", "QuartzCore", "CoreText"
  s.library               = "xml2"
  s.xcconfig              = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "Smooch"
end