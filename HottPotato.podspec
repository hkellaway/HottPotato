Pod::Spec.new do |s|

  s.name             = "HottPotato"
  s.version          = "0.1.0"
  s.summary          = "Delicious HTTP requests"
  s.description      = "Delicious HTTP requests."
  s.homepage         = "https://github.com/hkellaway/HottPotato"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Harlan Kellaway" => "hello@harlankellaway.com" }
  s.source           = { :git => "https://github.com/hkellaway/HottPotato.git", :tag => s.version.to_s }

  s.swift_version    = "5.0"
  s.platforms        = { :ios => "12.0" }  
  s.requires_arc     = true

  s.source_files     = 'Sources/*.{swift}'

end
