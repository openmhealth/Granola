# HealthKitIO

(TODO: perhaps create a logo? Examples:
[AFNetworking](https://github.com/AFNetworking/AFNetworking),
[CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack),
[Alamofire](https://github.com/Alamofire/Alamofire),
[Spring](https://github.com/MengTo/Spring),
[Quick](https://github.com/Quick/Quick))

(TODO: continuous integration badges, like...)
[![CI Status](http://img.shields.io/travis/openmhealth/HealthKitIO.svg?style=flat)](https://travis-ci.org/openmhealth/HealthKitIO)
[![Version](https://img.shields.io/cocoapods/v/HealthKitIO.svg?style=flat)](http://cocoapods.org/pods/HealthKitIO)
[![License](https://img.shields.io/cocoapods/l/HealthKitIO.svg?style=flat)](http://cocoapods.org/pods/HealthKitIO)
[![Platform](https://img.shields.io/cocoapods/p/HealthKitIO.svg?style=flat)](http://cocoapods.org/pods/HealthKitIO)


## Overview

So you want to store your app's [HealthKit](https://developer.apple.com/healthkit/) data somewhere *outside* of HealthKit, perhaps a remote server for analysis or backup? Use HealthKitIO to serialize your data.

HealthKitIO spares you the effort of mapping HealthKit's API to JSON yourself,
and emits JSON that validates against [schemas developed by Open mHealth](http://www.openmhealth.org/developers/schemas/) to ensure the data is intuitive and clinically meaningful.


***

## Installation

### CocoaPods

HealthKitIO is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod "HealthKitIO"
```

***

## Usage

### Quick start

First, be sure to study Apple's [HealthKit Framework Reference](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework), which includes code samples illustrating how to ask your app's user for permission to access their HealthKit data, and how to query that data after you've gained permission.

Now, let's say you want to see what a "steps" sample data point looks like serialized to JSON.

```objective-c
// HealthKitIO includes OMHSerializer for serializing HealthKit data
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
     // create a serializer with the sample, skip error-handling for example
     OMHSerializer *serializer = [OMHSerializer forHKSample:sample error:nil];
     NSString* jsonString = [serializer jsonOrError:nil];
     NSLog(@"sample json: %@", jsonString);
   }];
// run the query with your authorized HKHealthStore instance
[self.healthStore executeQuery:query];
```

Upon running your code, the console would render the data sample as Open mHealth compliant JSON:

```json
{
  "effective-time-frame" : {
    "end-time" : "2014-09-17T19:44:32-04:00",
    "start-time" : "2014-09-17T19:44:27-04:00"
  },
  "step_count" : 14
}
```

### HKObjectType support

The serializer doesn't yet support all of HealthKit's data types. The list of supported types is available through a class method:

```objective-c
[OMHSerializer supportedTypeIdentifiers]
//=> [HKQuantityTypeIdentifierStepCount, ...]
```

Attempting to init a serializer with an HKObject of unsupported type or values
returns `nil` and populates the provided error.

```objective-c
HKQuantitySample *sampleOfUnsupportedType = [results first];
// create a serializer with the sample
NSError* error = nil;
OMHSerializer *serializer =
  [[OMHSerializer alloc] initWithHKSample:sampleOfUnsupportedType
                                    error:&error];
if (serializer == nil) {
  // handle failure
  NSLog(@"%@", error.localizedDescription];
} else {
  // continue...
}
```

Support for all possible HKObjectType identifiers, pulled from
the [HealthKit Constant Reference](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/doc/constant_group/Body_Measurements),
is summarized [here](../doc/hkobject_type_coverage.md). Note that the majority
of these identifiers are not yet in use by most applications.

[Contact us](#contact) to request support for a particular type or
[contribute](#contributing) support with a pull request.


## Contact

Follow HealthKitIO on Twitter (@HealthKitIO)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

HealthKitIO is available under the MIT license. See the LICENSE file for more info.

