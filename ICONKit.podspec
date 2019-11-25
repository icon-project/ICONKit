Pod::Spec.new do |s|

  s.name         = 'ICONKit'
  s.version      = '0.4.2'
  s.summary      = 'ICON SDK for swift'
  s.homepage     = 'https://github.com/icon-project/ICONKit'
  s.license      = { :type => "Apache-2.0", :file => "LICENSE" }
  s.author             = { "a1ahn" => "hello@icon.foundation" }
  s.social_media_url = 'https://twitter.com/helloicon'
  s.module_name = 'ICONKit'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/icon-project/ICONKit.git", :tag => s.version.to_s }
  
  s.source_files  = "Source/*.swift"

  s.frameworks = 'Security'

  s.dependency 'secp256k1_swift'
  s.dependency 'BigInt'
  s.dependency 'CryptoSwift'

end
