Pod::Spec.new do |s|
  s.name             = "HottPotato"
  s.version          = "0.0.1"
  s.summary          = "Delicious HTTP requests"
  s.description      = "Delicious HTTO requests."
  s.homepage         = "https://github.com/hkellaway/HottPotato"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Harlan Kellaway" => "hello@harlankellaway.com" }
  s.source           = { :git => "https://github.com/hkellaway/HottPotato.git", :tag => s.version.to_s }

  s.platforms     = { :ios => "12.0" }  
  s.requires_arc = true

  s.source_files     = 'Sources/*.{swift}'

end
