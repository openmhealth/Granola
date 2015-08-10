Pod::Spec.new do |s|
  s.name             = "Granola"
  s.version          = "0.2.1" 
  s.summary          = "A healthful serializer for your HealthKit data."
  s.homepage         = "https://github.com/openmhealth/Granola"
  s.license          = { :type => 'Apache 2.0',
                         :file => 'LICENSE' }
  s.authors          = { "Brent Hargrave" => "brent@brent.is",
                         "Chris Schaefbauer" => "chris.schaefbauer@openmhealth.org",
                         "Emerson Farrugia" => "emerson@openmhealth.org",
                         "Simona Carini" => "simona@openmhealth.org" }
  s.source           = { :git => "https://github.com/openmhealth/Granola.git",
                         :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/openmhealth'
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  s.frameworks       = 'HealthKit'
  s.dependency 'ObjectiveSugar', '~> 1.1'
end

