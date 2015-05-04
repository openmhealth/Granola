# Granola

_*A healthful serializer for your HealthKit data.*_

## Overview

So you want to store your app's [HealthKit](https://developer.apple.com/healthkit/)
data somewhere *outside* of HealthKit, perhaps a remote server for analysis or
backup? Use Granola to serialize your data.

Granola spares you the effort of mapping HealthKit's API to JSON yourself,
and emits JSON that validates against
[schemas developed by Open mHealth](http://www.openmhealth.org/developers/schemas/)
to ensure the data is intuitive and clinically meaningful.


***

## Installation

### CocoaPods

Granola is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod "Granola"
```

***

## Usage

### Quick start

First, be sure to study Apple's
[HealthKit Framework Reference](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework),
which includes code samples illustrating how to ask your app's user for
permission to access their HealthKit data, and how to query that data after
you've gained permission.

Now, let's say you want to see what a "steps" sample data point looks like
serialized to JSON.

```objective-c
// Granola includes OMHSerializer for serializing HealthKit data
#import "OMHSerializer.h"

// (initialize your HKHealthStore instance, request permissions with it)
// ...

// create a query for steps data
HKSampleType *stepsSampleType =
  [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
HKSampleQuery* query =
  [[HKSampleQuery alloc] initWithSampleType:stepsSampleType
                                  predicate:nil
                                      limit:HKObjectQueryNoLimit
                            sortDescriptors:nil
                             resultsHandler:^(HKSampleQuery *query,
                                              NSArray *results,
                                              NSError *error) {
     if (!results) abort();
     // pick a sample to serialize
     HKQuantitySample *sample = [results first];
     // create and use a serializer instance
     OMHSerializer *serializer = [OMHSerializer new];
     NSString* jsonString = [serializer jsonForSample:sample error:nil];
     NSLog(@"sample json: %@", jsonString);
   }];
// run the query with your authorized HKHealthStore instance
[self.healthStore executeQuery:query];
```

Upon running your code, the console would render the data sample as Open mHealth compliant JSON:

```json
{
  "body" : {
    "step_count" : 45,
    "effective_time_frame" : {
      "time_interval" : {
        "start_date_time" : "2015-05-12T18:58:06.969Z",
        "end_date_time" : "2015-05-12T18:58:32.524Z"
      }
    }
  },
  "header" : {
    "id" : "4A00E553-B01D-4757-ADD0-A4283BABAC6F",
    "creation_date_time" : "2015-05-12T18:58:06.969Z",
    "schema_id" : {
      "namespace" : "omh",
      "name" : "step-count",
      "version" : "1.0"
    }
  }
}
```

### HKObjectType support

The serializer doesn't yet support all of HealthKit's data types. The list of
supported types is available through a class method:

```objective-c
[OMHSerializer supportedTypeIdentifiers]
//=> [HKQuantityTypeIdentifierStepCount, ...]
```

Attempting to serialize an HKObject of unsupported type or values returns `nil`
and populates the provided error.

```objective-c
HKQuantitySample *sampleOfUnsupportedType = [results first];
// create a serializer with the sample
NSError* error = nil;
OMHSerializer *serializer = [OMHSerializer new];
NSString* jsonString = [serializer jsonForSample:sampleOfUnsupportedType
                                           error:&error];
if (serializer == nil) {
  // handle failure
  NSLog(@"%@", error.localizedDescription];
} else {
  // continue...
}
```

Support for all possible HKObjectType identifiers, pulled from the
[HealthKit Constant Reference](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants),
is summarized [here](Docs/hkobject_type_coverage.md). Note that the majority
of these identifiers are not yet in use by most applications.

[Contact us](##contact) to request support for a particular type or
[contribute](#contributing) support with a pull request.


## Contact

Have a question? Please [open an issue](https://github.com/openmhealth/Granola/issues/new)!

Also, feel free to tweet at Open mHealth ([@openmhealth](http://twitter.com/openmhealth)).


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

Granola is available under the Apache 2 license. See the [LICENSE](/LICENSE) file for more info.


## Authors

Brent Hargrave ([@brenthargrave](http://twitter.com/brenthargrave))

