#import <Granola/OMHSerializer.h>
#import <VVJSONSchemaValidation/VVJSONSchema.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <Granola/OMHError.h>
#import <Granola/OMHHealthKitConstantsMapper.h>
#import "OMHSampleFactory.h"
#import "OMHSchemaStore.h"
#import "NSDate+RFC3339.h"


void (^logTypeSupportTableString)() = ^{
  id allTypesGrouped = @{
    @"Body Measurements": @[
      HKQuantityTypeIdentifierBodyMassIndex,
      HKQuantityTypeIdentifierBodyFatPercentage,
      HKQuantityTypeIdentifierHeight,
      HKQuantityTypeIdentifierBodyMass,
      HKQuantityTypeIdentifierLeanBodyMass,
      ],
    @"Fitness Identifiers": @[
      HKQuantityTypeIdentifierStepCount,
      HKQuantityTypeIdentifierDistanceWalkingRunning,
      HKQuantityTypeIdentifierDistanceCycling,
      HKQuantityTypeIdentifierActiveEnergyBurned,
      HKQuantityTypeIdentifierFlightsClimbed,
      HKQuantityTypeIdentifierNikeFuel,
      ],
    @"Vital Signs Identifiers": @[
      HKQuantityTypeIdentifierHeartRate,
      HKQuantityTypeIdentifierBodyTemperature,
      HKQuantityTypeIdentifierBloodPressureSystolic,
      HKQuantityTypeIdentifierBloodPressureDiastolic,
      HKQuantityTypeIdentifierRespiratoryRate
      ],
    @"Results Identifiers": @[
      HKQuantityTypeIdentifierOxygenSaturation,
      HKQuantityTypeIdentifierPeripheralPerfusionIndex,
      HKQuantityTypeIdentifierBloodGlucose,
      HKQuantityTypeIdentifierNumberOfTimesFallen,
      HKQuantityTypeIdentifierElectrodermalActivity,
      HKQuantityTypeIdentifierInhalerUsage,
      HKQuantityTypeIdentifierBloodAlcoholContent,
      HKQuantityTypeIdentifierForcedVitalCapacity,
      HKQuantityTypeIdentifierForcedExpiratoryVolume1,
      HKQuantityTypeIdentifierPeakExpiratoryFlowRate,
      ],
    @"Nutrition Identifiers": @[
      HKQuantityTypeIdentifierDietaryBiotin,
      HKQuantityTypeIdentifierDietaryCaffeine,
      HKQuantityTypeIdentifierDietaryCalcium,
      HKQuantityTypeIdentifierDietaryCarbohydrates,
      HKQuantityTypeIdentifierDietaryChloride,
      HKQuantityTypeIdentifierDietaryCholesterol,
      HKQuantityTypeIdentifierDietaryChromium,
      HKQuantityTypeIdentifierDietaryCopper,
      HKQuantityTypeIdentifierDietaryEnergyConsumed,
      HKQuantityTypeIdentifierDietaryFatMonounsaturated,
      HKQuantityTypeIdentifierDietaryFatPolyunsaturated,
      HKQuantityTypeIdentifierDietaryFatSaturated,
      HKQuantityTypeIdentifierDietaryFatTotal,
      HKQuantityTypeIdentifierDietaryFiber,
      HKQuantityTypeIdentifierDietaryFolate,
      HKQuantityTypeIdentifierDietaryIodine,
      HKQuantityTypeIdentifierDietaryIron,
      HKQuantityTypeIdentifierDietaryMagnesium,
      HKQuantityTypeIdentifierDietaryManganese,
      HKQuantityTypeIdentifierDietaryMolybdenum,
      HKQuantityTypeIdentifierDietaryNiacin,
      HKQuantityTypeIdentifierDietaryPantothenicAcid,
      HKQuantityTypeIdentifierDietaryPhosphorus,
      HKQuantityTypeIdentifierDietaryPotassium,
      HKQuantityTypeIdentifierDietaryProtein,
      HKQuantityTypeIdentifierDietaryRiboflavin,
      HKQuantityTypeIdentifierDietarySelenium,
      HKQuantityTypeIdentifierDietarySodium,
      HKQuantityTypeIdentifierDietarySugar,
      HKQuantityTypeIdentifierDietaryThiamin,
      HKQuantityTypeIdentifierDietaryVitaminA,
      HKQuantityTypeIdentifierDietaryVitaminB12,
      HKQuantityTypeIdentifierDietaryVitaminB6,
      HKQuantityTypeIdentifierDietaryVitaminC,
      HKQuantityTypeIdentifierDietaryVitaminD,
      HKQuantityTypeIdentifierDietaryVitaminE,
      HKQuantityTypeIdentifierDietaryVitaminK,
      HKQuantityTypeIdentifierDietaryZinc
      ],
    @"Sleep Identifiers": @[
      HKCategoryTypeIdentifierSleepAnalysis
      ],
    @"Characteristics Identifiers": @[
      HKCharacteristicTypeIdentifierBiologicalSex,
      HKCharacteristicTypeIdentifierBloodType,
      HKCharacteristicTypeIdentifierDateOfBirth
      ],
    @"Correlation Identifiers": @[
      HKCorrelationTypeIdentifierBloodPressure,
      HKCorrelationTypeIdentifierFood
      ],
    @"Workout Identifier": @[
      HKWorkoutTypeIdentifier
      ]
  };
  NSMutableArray* tableRows = [NSMutableArray array];
  [@[
    @[ @"HKObject type", @"Granola" ],
    @[ @"-------------", @":---------:" ],
    ] each:^(id row) { [tableRows push: row]; }];
  [allTypesGrouped each:^(id groupName, id typesList){
    // types group
    NSString* formattedGroupName =
      [NSString stringWithFormat:@"*__%@__*", groupName];
    [tableRows push: @[formattedGroupName, @""]];
    // types
    [typesList each:^(id typeName) {
      BOOL typeSupported =
        [[OMHSerializer typeIdentifiersWithOMHSchema] includes:typeName];
      NSString* typeSupportedString =
        (typeSupported) ? @":white_check_mark:" : @"  ";
      [tableRows push:@[typeName, typeSupportedString]];
    }];
  }];
  NSString* typeSupportTableString =
    [[tableRows map:^id(id cols) {
      return NSStringWithFormat(@"|%@|", [cols join:@"|"]);
    }] join:@"\n"];
  NSLog(@"type support table markdown: \n%@", typeSupportTableString);
};

id (^deserializedJsonForSample)(HKSample* sample) =
  ^(HKSample* sample){
    OMHSerializer* instance = [OMHSerializer new];
    NSString* json = [instance jsonForSample:sample error:nil];
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
  };

SpecBegin(OMHSerializer)
describe(@"OMHSerializer", ^{
  //beforeAll(^{ logTypeSupportTableString(); });

  NSArray* typeIdentifiersWithOMHSchema = [OMHSerializer typeIdentifiersWithOMHSchema];
  NSString* supportedTypeIdentifier =  [typeIdentifiersWithOMHSchema firstObject];

  NSArray* additionalTypeIdentifiersToTest = [NSMutableArray arrayWithArray:@[
                                                                                HKQuantityTypeIdentifierDietaryBiotin,
                                                                                HKCorrelationTypeIdentifierFood,
                                                                                HKWorkoutTypeIdentifier
                                                                            ]];
    typeIdentifiersWithOMHSchema = [[[NSMutableArray arrayWithArray:additionalTypeIdentifiersToTest] arrayByAddingObjectsFromArray:typeIdentifiersWithOMHSchema] copy];

  describe(@"+supportedTypeIdentifiers ", ^{
    __block NSArray* subject;
    beforeEach(^{
      subject = typeIdentifiersWithOMHSchema;
    });
    it(@"includes supported types", ^{
      expect(subject).to.contain(supportedTypeIdentifier);
    });

  });

  describe(@"-jsonForSample:error:", ^{
    __block NSError* error;
    __block HKSample* sample;
    __block OMHSerializer* instance;
    __block NSString* json;
    beforeEach(^{
      instance = [OMHSerializer new];
    });
    it(@"without sample raises exception", ^{
      expect(^{
        [instance jsonForSample:nil error:nil];
      }).to.raise(NSInternalInconsistencyException);
    });

    [typeIdentifiersWithOMHSchema each:^(NSString* typeIdentifier){
      context([NSString stringWithFormat:
      @"with sample of supported type %@", typeIdentifier], ^{
        it(@"and supported values returns json result without error", ^{
          NSError* error = nil;
          HKSample* sample = [OMHSampleFactory typeIdentifier:typeIdentifier];
          json = [instance jsonForSample:sample error:&error];
          expect(json).notTo.beNil();
          expect(error).to.beNil();
        });
      });
    }];
  });

});
SpecEnd

SharedExamplesBegin(AnySerializerForSupportedSample)
sharedExamplesFor(@"AnySerializerForSupportedSample", ^(NSDictionary* data) {
  describe(@"-jsonForSample:error:", ^{
    __block id object = nil;
    __block HKSample* sample = nil;
    __block id pathsToValues = nil;
    beforeEach(^{
      sample = data[@"sample"];
      object = deserializedJsonForSample(sample);
      pathsToValues = data[@"pathsToValues"];
    });
    it(@"validates against data-point schema", ^{
      NSError* validationError = nil;
      BOOL valid = [OMHSchemaStore validateObject:object
                              againstSchemaAtPath:@"omh/data-point"
                                        withError:&validationError];
      expect(valid).to.beTruthy();
    });
    it(@"validates against body schema", ^{
        NSError* validationError = nil;
        BOOL valid = [OMHSchemaStore validateObject:[object valueForKeyPath:@"body"]
                                againstSchemaAtPath:[NSString stringWithFormat:@"%@/%@",[pathsToValues valueForKeyPath:@"header.schema_id.namespace"],[pathsToValues valueForKeyPath:@"header.schema_id.name"]]
                                          withError:&validationError];
        expect(valid).to.beTruthy();
    });
    it(@"contains correct data", ^{
      NSMutableDictionary* allKeysValues =
        [NSMutableDictionary dictionaryWithDictionary:pathsToValues];
      // shared header keys
      [allKeysValues addEntriesFromDictionary:@{
        @"header.id": sample.UUID.UUIDString,
        @"header.creation_date_time": [sample.startDate RFC3339String],
        @"header.schema_id.version": @"1.0",
      }];
      [allKeysValues each:^(id keyPath, id keyPathValue){
          if([keyPath containsString:@"quantity_samples"] || [keyPath containsString:@"category_samples"] || [keyPath containsString:@"metadata"]){
              //These properties are arrays, so we need to iterate through and check to make sure each value exists in the returned array.
              //The order of the values in the array can change, so need to check whether the array contains expected values instead of matching an exact array
              for(NSObject *keyArrayValue in keyPathValue){
                  expect([object valueForKeyPath:keyPath]).to.contain(keyArrayValue);
              }
          }
          else{
              expect([object valueForKeyPath:keyPath]).to.equal(keyPathValue);
          }
        
      }];
    });
  });
});
SharedExamplesEnd

SpecBegin(AllSupportedHKTypes)

describe(HKQuantityTypeIdentifierStepCount, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSNumber* value = [NSNumber numberWithDouble:6];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierStepCount
                                 attrs:@{ @"value": value }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"step-count",
        @"header.schema_id.namespace":@"omh",
        @"body.step_count": value,
        @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(HKQuantityTypeIdentifierHeight, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSString* unitString = @"cm";
    NSNumber* value = [NSNumber numberWithDouble:182.88];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierHeight
                                 attrs:@{ @"unitString": unitString,
                                          @"value": value }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"body-height",
        @"header.schema_id.namespace":@"omh",
        @"body.body_height.value": value,
        @"body.body_height.unit": unitString,
        @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(HKQuantityTypeIdentifierBodyMass, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSString* unitString = @"lb";
    NSNumber* value = [NSNumber numberWithDouble:180];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyMass
                                 attrs:@{ @"unitString": unitString,
                                          @"value": value }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"body-weight",
        @"header.schema_id.namespace":@"omh",
        @"body.body_weight.value": value,
        @"body.body_weight.unit": unitString,
        @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(HKQuantityTypeIdentifierHeartRate, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSNumber* value = [NSNumber numberWithDouble:43];
    NSDate* sampledAt = [NSDate date];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierHeartRate
                                 attrs:@{ @"value": value,
                                          @"start": sampledAt,
                                          @"end": sampledAt }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"heart-rate",
        @"header.schema_id.namespace":@"omh",
        @"body.heart_rate.value": value,
        @"body.heart_rate.unit": @"beats/min",
        @"body.effective_time_frame.date_time": [sample.startDate RFC3339String],
      }
    };
  });
});

describe(HKQuantityTypeIdentifierBloodGlucose, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSString* unitString = @"mg/dL";
    NSNumber* value = [NSNumber numberWithDouble:120];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodGlucose
                                 attrs:@{ @"value": value,
                                          @"unitString": unitString }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"blood-glucose",
        @"header.schema_id.namespace":@"omh",
        @"body.blood_glucose.value": value,
        @"body.blood_glucose.unit": unitString,
        @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(@"HKQuantityTypeIdentifierBloodGlucose with metadata", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSString* unitString = @"mg/dL";
        NSNumber* value = [NSNumber numberWithDouble:120];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodGlucose
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"metadata":@{
                                                    HKMetadataKeyWasTakenInLab:@YES
                                                    }
                                            }];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"blood-glucose",
                         @"header.schema_id.namespace":@"omh",
                         @"body.blood_glucose.value": value,
                         @"body.blood_glucose.unit": unitString,
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String],
                         @"body.metadata.key":@[HKMetadataKeyWasTakenInLab.description], //Because metadata value validation iterates over an array, these values must be in array form
                         @"body.metadata.value":@[@YES]
                         
                         }
                 };
    });
});






describe(HKQuantityTypeIdentifierActiveEnergyBurned, ^{
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSString* unitString = @"kcal";
    NSNumber* value = [NSNumber numberWithDouble:160];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned
                                 attrs:@{ @"value": value,
                                          @"unitString": unitString }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"calories-burned",
        @"header.schema_id.namespace":@"omh",
        @"body.kcal_burned.value": value,
        @"body.kcal_burned.unit": unitString,
        @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(@"HKCategoryTypeIdentifierSleepAnalysis InBed", ^{
  
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
      NSDate* start = [NSDate date];
      NSDate* end = [start dateByAddingTimeInterval:60*60*8];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierSleepAnalysis
                                 attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueSleepAnalysisInBed)}];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"hk-category-sample",
        @"header.schema_id.namespace":@"granola",
        @"body.category_value": @"InBed",
        @"body.category_type": HKCategoryTypeIdentifierSleepAnalysis,
        @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String],
      }
    };
  });
});

describe(@"HKCategoryTypeIdentifierSleepAnalysis Asleep",^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSInteger secs = [@1800 integerValue];
        NSDate* end = [start dateByAddingTimeInterval:secs];
        

        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierSleepAnalysis
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueSleepAnalysisAsleep)}];
        return @{
                 @"sample":sample,
                 @"pathsToValues":@{
                         @"header.schema_id.name": @"sleep-duration",
                         @"header.schema_id.namespace":@"omh",
                         @"body.sleep_duration.value": [NSNumber numberWithInteger:secs],
                         @"body.sleep_duration.unit": @"sec",
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]

                         }
                 };
    });
});

describe(HKQuantityTypeIdentifierBodyMassIndex, ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:29.3];
        NSString *unitString = @"count";
        HKSample* sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyMassIndex
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
            @"sample": sample,
            @"pathsToValues": @{
                @"header.schema_id.name": @"body-mass-index",
                @"header.schema_id.namespace":@"omh",
                @"body.body_mass_index.value": value,
                @"body.body_mass_index.unit": @"kg/m2",
                @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
            }
        };
        
    });
});

describe(@"HKQuantityTypeIdentifierDietaryBiotin with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:8.8];
        NSString *unitString = @"mcg";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryBiotin
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
            @"sample":sample,
            @"pathsToValues": @{
                @"header.schema_id.name": @"hk-quantity-sample",
                @"header.schema_id.namespace":@"granola",
                @"body.quantity_type":[HKQuantityTypeIdentifierDietaryBiotin description],
                @"body.unit_value.value":value,
                @"body.unit_value.unit":unitString,
                @"body.effective_time_frame.time_interval.start_date_time":[start RFC3339String],
                @"body.effective_time_frame.time_interval.end_date_time":[end RFC3339String]
            }
        };
    });
});

describe(@"HKQuantityTypeIdentifierDietaryBiotin with meta_data", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:8.8];
        NSNumber *referenceLowValue = [NSNumber numberWithDouble:2.0];
        NSString *unitString = @"mcg";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryBiotin
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end,
                                                              @"metadata":@{
                                                                    HKMetadataKeyWasTakenInLab:@YES,
                                                                    HKMetadataKeyTimeZone:@"CST",
                                                                    HKMetadataKeyReferenceRangeLowerLimit:referenceLowValue
                                                                            }
                                                              }];
        return @{
                 @"sample":sample,
                 @"pathsToValues":@{
                         @"header.schema_id.name":@"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"body.quantity_type":[HKQuantityTypeIdentifierDietaryBiotin description],
                         @"body.unit_value.value":value,
                         @"body.unit_value.unit":unitString,
                         @"body.effective_time_frame.time_interval.start_date_time":[start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time":[end RFC3339String],
                         @"body.metadata.key":@[HKMetadataKeyWasTakenInLab.description,HKMetadataKeyTimeZone.description, HKMetadataKeyReferenceRangeLowerLimit.description],
                         @"body.metadata.value":@[@YES,@"CST",referenceLowValue]
                         }
                 };

    });
                       
});

describe(@"HKQuantityTypeIdentifierInhalerUsage with date_time", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = start;
        NSNumber *value = [NSNumber numberWithInt:3];
        NSString *unitString = @"count";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierInhalerUsage
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"body.quantity_type":[HKQuantityTypeIdentifierInhalerUsage description],
                         @"body.count":value,
                         @"body.effective_time_frame.date_time":[start RFC3339String]
                    }
                 };
    });
});

describe(HKCorrelationTypeIdentifierFood,^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        //energyConsumedQuantitySample = nil;
        //carbConsumedQuantitySample = nil;
        NSDate *sampleDate = [NSDate date];
        NSLog(@"In Correlation, sampleDate: %@",[sampleDate description]);
        NSNumber *calorieValue = [NSNumber numberWithDouble:105];
        NSNumber *carbValue = [NSNumber numberWithDouble:29.3];
        NSString *calorieUnitString = @"kcal";
        NSString *carbUnitString = @"g";
        //beforeAll(^{
        HKSample *energyConsumedQuantitySample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed
                                                                  attrs:@{ @"start":sampleDate,
                                                                           @"end":sampleDate,
                                                                           @"value":calorieValue,
                                                                           @"unitString":calorieUnitString
                                                                           }];
        HKSample *carbConsumedQuantitySample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates
                                                                attrs:@{ @"start":sampleDate,
                                                                         @"end":sampleDate,
                                                                         @"value":carbValue,
                                                                         @"unitString":carbUnitString
                                                                         }];
        
        NSSet *dietaryComponentSamples = [NSSet setWithArray:@[energyConsumedQuantitySample,carbConsumedQuantitySample]];
        NSLog(@"In Correlation, samples order: %@",[dietaryComponentSamples description]);
        NSDate *correlationStart = [NSDate date];
        NSDate *correlationEnd = [correlationStart dateByAddingTimeInterval:360];
        HKSample *foodSample = [OMHSampleFactory typeIdentifier:HKCorrelationTypeIdentifierFood
                                                          attrs:@{@"start": correlationStart,
                                                                  @"end": correlationEnd,
                                                                  @"objects":dietaryComponentSamples
                                                                  }];
        
        return @{
                 @"sample":foodSample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-correlation",
                         @"header.schema_id.namespace":@"granola",
                         @"body.effective_time_frame.time_interval.start_date_time": [correlationStart RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [correlationEnd RFC3339String],
                         @"body.correlation_type": [HKCorrelationTypeIdentifierFood description],
                         @"body.quantity_samples.effective_time_frame.date_time": @[[sampleDate RFC3339String],[sampleDate RFC3339String]],
                         @"body.quantity_samples.unit_value.value": @[carbValue,calorieValue],
                         @"body.quantity_samples.unit_value.unit": @[carbUnitString,calorieUnitString],
                         @"body.quantity_samples.quantity_type": @[[HKQuantityTypeIdentifierDietaryCarbohydrates description],[HKQuantityTypeIdentifierDietaryEnergyConsumed description]]
                         
                         
                         }
                 };
    });
    
});

describe(@"HKWorkoutTypeIdentifier with no details", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *activityStart = [NSDate date];
        NSDate *activityEnd = [activityStart dateByAddingTimeInterval:3600];
        
        HKSample *workoutSample = [OMHSampleFactory typeIdentifier:HKWorkoutTypeIdentifier
                                                             attrs:@{@"start":activityStart,
                                                                     @"end":activityEnd,
                                                                     @"activity_type":@(HKWorkoutActivityTypeRunning)
                                                                     
                                                                     }];
        return @{
                 @"sample":workoutSample,
                 @"pathsToValues":@{
                         @"header.schema_id.name":@"hk-workout",
                         @"header.schema_id.namespace":@"granola",
                         @"body.effective_time_frame.time_interval.start_date_time": [activityStart RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [activityEnd RFC3339String],
                         @"body.activity_name":[OMHHealthKitConstantsMapper stringForHKWorkoutActivityType:HKWorkoutActivityTypeRunning]
                         }
                 };
    });
});

describe(@"HKWorkoutTypeIdentifier with details", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *activityStart = [NSDate date];
        NSDate *activityEnd = [activityStart dateByAddingTimeInterval:3600];
        HKQuantity *energyBurned = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"kcal"] doubleValue:123.3];
        HKQuantity *distance = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"mi"] doubleValue:13.1];
        NSNumber *durationValue = [NSNumber numberWithDouble:360.5];
        
        HKSample *workoutSample = [OMHSampleFactory typeIdentifier:HKWorkoutTypeIdentifier
                                                             attrs:@{
                                                                     @"start":activityStart,
                                                                     @"end":activityEnd,
                                                                     @"activity_type":@(HKWorkoutActivityTypeRunning),
                                                                     @"duration":durationValue,
                                                                     @"energy_burned":energyBurned,
                                                                     @"distance":distance
                                                                     }];
        return @{
                 @"sample":workoutSample,
                 @"pathsToValues":@{
                         @"header.schema_id.name":@"hk-workout",
                         @"header.schema_id.namespace":@"granola",
                         @"body.effective_time_frame.time_interval.start_date_time": [activityStart RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [activityEnd RFC3339String],
                         @"body.activity_name":[OMHHealthKitConstantsMapper stringForHKWorkoutActivityType:HKWorkoutActivityTypeRunning],
                         @"body.duration.value":@360.5,
                         @"body.duration.unit":@"sec",
                         @"body.kcal_burned.value":@([energyBurned doubleValueForUnit:[HKUnit unitFromString:@"kcal"]]),
                         @"body.kcal_burned.unit":@"kcal",
                         @"body.distance.value":@([distance doubleValueForUnit:[HKUnit unitFromString:@"mi"]]),
                         @"body.distance.unit":@"mi"
                         }
                 };
        
    });
});

describe(HKCorrelationTypeIdentifierBloodPressure, ^{
  __block NSNumber* diastolicValue = nil;
  __block NSNumber* systolicValue = nil;
  __block HKSample* diastolicSample = nil;
  __block HKSample* systolicSample = nil;
  __block HKSample* sample = nil;
  __block NSDate* sampledAt = nil;
  __block NSString* json = nil;
  beforeAll(^{
    sampledAt = [NSDate date];
    diastolicValue = [NSNumber numberWithDouble:60];
    systolicValue = [NSNumber numberWithDouble:100];
    diastolicSample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic
                                 attrs:@{ @"start": sampledAt,
                                          @"end": sampledAt,
                                          @"value": diastolicValue }];
    systolicSample =
      [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic
                                 attrs:@{ @"start": sampledAt,
                                          @"end": sampledAt,
                                          @"value": systolicValue }];
  });
  describe(@"-jsonForSample:error:", ^{
    __block NSError* error = nil;
    __block OMHSerializer* instance = nil;
    context(@"with sample lacking either a systolic or diastolic sample", ^{
      beforeAll(^{
        NSSet* objects = [NSSet setWithObjects: diastolicSample, nil];
        sample =
          [OMHSampleFactory typeIdentifier:HKCorrelationTypeIdentifierBloodPressure
                                     attrs:@{ @"start": sampledAt,
                                              @"end": sampledAt,
                                              @"objects": objects }];
        instance = [OMHSerializer new];
        json = [instance jsonForSample:sample error:&error];
      });
      it(@"returns nil", ^{
        expect(json).to.beNil();
      });
      it(@"populates error", ^{
        expect(error).notTo.beNil();
        expect(error.code).to.equal(OMHErrorCodeUnsupportedValues);
        expect(error.localizedDescription).to.contain(@"Diastolic");
      });
    });
  });
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSSet* objects =
      [NSSet setWithObjects: systolicSample, diastolicSample, nil];
    sample =
      [OMHSampleFactory typeIdentifier:HKCorrelationTypeIdentifierBloodPressure
                                 attrs:@{ @"start": sampledAt,
                                          @"end": sampledAt,
                                          @"objects": objects }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"blood-pressure",
        @"header.schema_id.namespace":@"omh",
        @"body.systolic_blood_pressure.value": systolicValue,
        @"body.systolic_blood_pressure.unit": @"mmHg",
        @"body.diastolic_blood_pressure.value": diastolicValue,
        @"body.diastolic_blood_pressure.unit": @"mmHg",
        @"body.effective_time_frame.date_time": [sampledAt RFC3339String]
      }
    };
  });
});
SpecEnd

