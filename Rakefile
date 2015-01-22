task :test do
  sh "set -o pipefail && xcodebuild -workspace Cards.xcworkspace -scheme Cards -sdk iphonesimulator test | xcpretty -ct"
end

task :default => :test
