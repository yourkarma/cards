platform :ios, "8.0"
use_frameworks!

pod "pop", inhibit_warnings: true

target "Example" do
  xcodeproj "Example/Example.xcodeproj"
  workspace "Cards.xcworkspace"
  pod "Cards", path: "./"
end

target "CardsTests" do
  pod "Quick"
  pod "Nimble"
end
