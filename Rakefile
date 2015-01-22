namespace :test do
  task :default do
    sh "xcodebuild -destination 'OS=latest,name=iPhone 5s,platform=iOS Simulator' -workspace Cards.xcworkspace -scheme Example test | xcpretty"
  end

  task :ci do
    sh "xcodebuild -sdk iphonesimulator -destination 'OS=latest,name=iPhone 5s,platform=iOS Simulator' -workspace Cards.xcworkspace -scheme Example test"
  end
end

task :test => "test:default"
task :default => :test
