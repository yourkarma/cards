namespace :test do
  task :default do
    sh "set -o pipefail && xcodebuild -workspace Cards.xcworkspace -scheme Cards -sdk iphonesimulator test | xcpretty -ct"
  end

  task :ci do
    sh "set -o pipefail && xcodebuild -workspace Cards.xcworkspace -scheme Cards -sdk iphonesimulator test"
  end

end

task :test => "test:default"
task :default => :test
