platform :ios, "8.0"
use_frameworks!

target "Cards" do
  project "Cards.xcodeproj"
  pod "pop"
end

target "CardsTests" do
  project "Cards.xcodeproj"
  pod "Quick"
  pod "Nimble"
end

target "Example" do
  project "Example/Example.xcodeproj"
  workspace "Cards.xcworkspace"
  pod "Cards", path: "./"
end

