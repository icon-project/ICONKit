Pod::Spec.new do |s|

  s.name         = "ICONKit"
  s.version      = "0.0.1"
  s.summary      = "ICON SDK for swift"

  s.swift_version = "4.2"

  s.description  = <<-DESC
                  ICON SDK for Swift
                   DESC

  s.homepage     = "https://github.com/icon-project/ICONKit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "a1ahn" => "jeonghwan.ahn@icon.foundation" }
  s.social_media_url = 'https://twitter.com/helloicon'

  s.platform     = :ios, "10.0"

  #  When using multiple platforms
  s.ios.deployment_target = "10.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/icon-project/ICONKit.git", :tag => s.version.to_s }
  
  s.source_files  = "ICONKit/ICON/*.swift"

  s.dependency 'BigInt', '~> 3.1.0'
  s.dependency 'CryptoSwift', '~> 0.10'
  s.dependency 'Result', '~> 4.0.0'
  s.dependency 'scrypt', '~> 1.5'
  s.dependency 'secp256k1_ios'
end
