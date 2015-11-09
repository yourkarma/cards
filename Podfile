platform :ios, "8.0"
use_frameworks!

pod "pop", inhibit_warnings: true

target "CardsTests" do
  pod "Quick"
  pod "Nimble", "2.0.0-rc.3"
end

target "Example" do
  xcodeproj "Example/Example.xcodeproj"
  workspace "Cards.xcworkspace"
  pod "Cards", path: "./"
end

def fix_non_modular_header_error
  `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

post_install do |installer|
  fix_non_modular_header_error
end
