Pod::Spec.new do |s|

  s.name         = 'ICONKit'
  s.version      = '0.3.1'
  s.summary      = 'ICON SDK for swift'
  s.homepage     = 'https://github.com/icon-project/ICONKit'
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "a1ahn" => "jeonghwan.ahn@icon.foundation" }
  s.social_media_url = 'https://twitter.com/helloicon'
  s.module_name = 'ICONKit'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'

  s.source       = { :git => "https://github.com/icon-project/ICONKit.git", :tag => s.version.to_s }
  
  s.source_files  = "Source/*.swift"

  s.frameworks = 'Security'

  s.dependency 'Result'
  s.dependency 'scrypt'
  s.dependency 'secp256k1_ios', '~> 0.1.3'
  s.dependency 'BigInt'
  s.dependency 'CryptoSwift', '~> 0.11.0'

end
