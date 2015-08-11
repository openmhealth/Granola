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

The serializer has support for all HealthKit samples (HKSample), either through curated Open mHealth schemas or through generic HealthKit schemas. The list of supported types along with their associated schemas is viewable [here](Docs/hkobject_type_coverage.md). The HKObjectType identifiers are pulled from the
[HealthKit Constant Reference](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/#//apple_ref/doc/uid/TP40014710-CH2-DontLinkElementID_3). 

You can retrieve a map (NSDictionary) of the supported types in Granola and the class name of the specific serializer they use by calling the static method:
```objective-c 
[OMHHealthKitConstantsMapper allSupportedTypeIdentifiersToClasses]
``` 

You can also retrieve a list of those types, without their associated serializers, using the method:
```objective-c 
[OMHSerializer supportedTypeIdentifiers]
``` 

And retrieve the list of types that serialize with OMH curated schemas (instead of the generic type schemas) by using the method:
```objective-c 
[OMHSerializer supportedTypeIdentifiersWithOMHSchema]
```

Over time, as curated schemas are developed that correspond to the HealthKit data represented by the generic schemas, the generic mappings will be replaced by mappings to the curated schemas.

[Contact us](#contact) to request support for a particular type or
[contribute](#contributing) support with a pull request.

### Timezones

As of 0.3.0, we are accurately creating timestamps for serialized data. Previous versions set the UTC offset as 'Z' even though timestamps used local time. 

With 0.3.0, the serializer uses the time zone of the device on which the serializer is running and correctly sets that as the UTC offset in timestamps. For an iOS app using Granola, this means that data created contains timestamps with the UTC offset of the device running it. Although these timestamps are correct, some data, especially older data, that is being serialized may be offset incorrectly if it was originally created by HealthKit in a different timezone than the device is in when Granola serializes it. For example, if a datapoint was originally created by HealthKit in San Francisco on June 1st, 2015 at 8:00a (-07:00), but then serialized three months later in New York, the timestamp would read 2015-06-01T11:00-04:00. These are technically the same point in time, however they are offset differently. 

In a future update, we plan to allow developers to specify the prefered timezone for serializing datapoints to give them the control over how timestamps are displayed. 


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
Chris Schaefbauer (chris.schaefbauer@openmhealth.org)  
Emerson Farrugia (emerson@openmhealth.org)  

