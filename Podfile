# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!

def import_pods
  # Pods for ICONKit
  pod 'BigInt'
  pod 'secp256k1_ios'
  pod 'Result'
  pod 'CryptoSwift'
end

target 'ICONKit-ios' do
  platform :ios, '10.0'
  use_frameworks!

  import_pods

end

target 'ICONKit-osx' do
  platform :osx, '10.14'
  use_frameworks!

  import_pods
end
