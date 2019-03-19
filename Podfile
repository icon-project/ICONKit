# Uncomment the next line to define a global platform for your project
platform :ios, 10

inhibit_all_warnings!

def import_pods
  # Pods for ICONKit
  pod 'BigInt'
  pod 'secp256k1_ios'
  pod 'Result'
  pod 'CryptoSwift'
  pod 'scrypt', :git => 'https://github.com/a1ahn/scrypt-cryptoswift.git'
end

target 'ICONKit' do
  use_frameworks!

  import_pods

end
