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
