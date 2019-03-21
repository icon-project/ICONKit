# Uncomment the next line to define a global platform for your project
platform :ios, 10

inhibit_all_warnings!
use_frameworks!

def import_pods
  # Pods for ICONKit
  pod 'BigInt'
  pod 'secp256k1_ios'
  pod 'Result'
  pod 'CryptoSwift', '~> 0.11.0'
  pod 'scrypt', :git => 'https://github.com/a1ahn/scrypt-cryptoswift.git'
end

#def test_ICONKit
#  pod 'ICONKit', :path => '~/works/ICONKit'
#end

target 'ICONKit-ios' do

  import_pods

end
