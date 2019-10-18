Pod::Spec.new do |s|

  s.name         = "JSONRequest"
  s.version      = "0.9.2"
  s.summary      = "JSONRequest is a tiny Swift library for Synchronous and Asynchronous HTTP JSON requests."
  s.homepage     = "http://github.com/hathway/JSONRequest"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Eneko Alonso" => "eneko.alonso@gmail.com" }
  s.social_media_url   = "http://twitter.com/eneko"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
#  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/hathway/JSONRequest.git", :tag => s.version }
  s.source_files  = "Sources/*.swift"
  s.swift_version = '5.0'
end
