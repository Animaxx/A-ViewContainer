Pod::Spec.new do |s|
  s.name         = "A_ViewContainer"
  s.version      = "1.0.1"
  s.summary      = "Multiple controller cards container"
  s.homepage     = "https://github.com/Animaxx/A-ViewContainer"
  s.license      = "MIT"
  s.authors      = { 'Animax Deng' => 'Animax.deng@gmail.com'}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Animaxx/A-ViewContainer.git", :tag => s.version }
  s.source_files = "A_ViewContainer/A_ViewContainer/*.{h,m}"
  s.requires_arc = true
end