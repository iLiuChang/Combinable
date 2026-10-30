Pod::Spec.new do |s|
  s.name         = "Combinable"
  s.version      = "1.0.0"
  s.summary      = "A UIKit extension based on Combine."
  s.homepage     = "https://github.com/iLiuChang/Combinable"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/iLiuChang/Combinable.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.5"
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'Combinable' => ['Sources/PrivacyInfo.xcprivacy'] }
end
