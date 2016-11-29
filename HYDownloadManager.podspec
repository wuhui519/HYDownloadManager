Pod::Spec.new do |s|
  s.name         = "HYDownloadManager"
  s.version      = "1.0.1"
  s.summary      = "iOS download manager, Download a set of files in parallel and sequential order. Updated version iscludes AFNetworking V3.0, and fixes compileing error in Xcode 8.0."
  s.homepage     = "https://github.com/wuhui519/HYDownloadManager"
  s.author       = { "wuhui519" => "wuhui519@gmail.com" }
  s.source       = { :git => "https://github.com/wuhui519/HYDownloadManager.git", :tag => "1.0.1" }
  s.source_files = 'HYDownloadManagerPod/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.license      = 'MIT'
  s.requires_arc = true

  s.dependency 'EGOCache', '~> 2.0'
  s.dependency 'AFNetworking', '~> 3.0'

end
