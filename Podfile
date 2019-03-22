# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!

def import_pods
  # Pods for ICONKit
  pod 'BigInt'
  pod 'secp256k1_ios', :modular_headers => true
  pod 'Result'
  pod 'CryptoSwift', '~> 0.11.0'
  pod 'scrypt', :git => 'https://github.com/a1ahn/scrypt-cryptoswift.git'
end

target 'ICONKit-ios' do
  platform :ios, 10
  use_frameworks!

  import_pods

end

target 'ICONKit-osx' do
  platform :osx, '10.14'

  import_pods
end
