Pod::Spec.new do |s|
  s.name             =  "Cards"
  s.version          =  "0.0.1"
  s.summary          =  "A card stack container view controller"
  s.homepage         =  "https://github.com/yourkarma/Cards"
  s.license          =  "MIT"
  s.author           =  { "Klaas Pieter Annema" => "klaaspieter@annema.me" }
  s.social_media_url =  "http://twitter.com/klaaspieter"
  s.platform         =  :ios, "8.0"
  s.source           =  { :git => "https://github.com/yourkarma/Cards.git", :commit => "db92f1d" }
  s.source_files     =  "Cards/**/*.swift"
  s.requires_arc     =  true

  s.resource_bundles = {
    Cards: "Cards/**/*.png"
  }
  s.dependency "pop", "~> 1.0"
end
