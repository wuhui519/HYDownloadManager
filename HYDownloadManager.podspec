Pod::Spec.new do |s|
  s.name         = "HYDownloadManager"
  s.version      = "1.0.3"
  s.summary      = "A tool downloads file with memory cache, temporary cache and permanent store."
  s.homepage     = "https://github.com/wuhui519/HYDownloadManager"
  s.author       = { "wuhui519" => "wuhui519@gmail.com" }
  s.source       = { :git => "https://github.com/wuhui519/HYDownloadManager.git", :tag => "1.0.3" }
  s.source_files = 'HYDownloadManagerPod/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.license      = 'MIT'
  s.requires_arc = true

  s.dependency 'EGOCache', '~> 2.0'
  s.dependency 'AFNetworking', '~> 3.0'

end
