#
# Be sure to run `pod lib lint Highlightr.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Highlightr"
  s.version          = "0.1.0"
  s.summary          = "Hightlight your code strings."

  s.description      = <<-DESC
                Takes a NSString with code and returns NSAttributtedString with highlighted code.
                       DESC

  s.homepage         = "https://github.com/raspu/Highlightr"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Illanes, Juan Pablo" => "jpillaness@gmail.com" }
  s.source           = { :git => "https://github.com/raspu/Highlightr.git", :tag => s.version.to_s, :submodules => true}

  s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '8.0'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{swift}', 


  s.resources  = 'Pod/Assets/**/*.{css,js}'

  #s.preserve_paths = 'Pod/Assets/Highlighter/**'
  #s.resource_bundles = {
  # 'Highlightr' => ['Pod/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'WebKit'
  # s.dependency 'DTCoreText', '~> 1.6'
end





