#import <HealthKitIO/OMHSerializer.h>
#import <VVJSONSchemaValidation/VVJSONSchema.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <HealthKitIO/OMHError.h>
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
    @[ @"HKObject type", @"HealthKitIO" ],
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
        [[OMHSerializer supportedTypeIdentifiers] includes:typeName];
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
    OMHSerializer* instance = [OMHSerializer forSample:sample error:nil];
    NSString* json = [instance jsonOrError:nil];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
  };

SpecBegin(OMHSerializer)
describe(@"OMHSerializer", ^{
  //beforeAll(^{ logTypeSupportTableString(); });

  NSArray* supportedTypeIdentifiers = [OMHSerializer supportedTypeIdentifiers];
  NSString* supportedTypeIdentifier =  [supportedTypeIdentifiers firstObject];
  NSString* unsupportedTypeIdentifier = HKQuantityTypeIdentifierNikeFuel;

  describe(@"+supportedTypeIdentifiers ", ^{
    __block NSArray* subject;
    beforeEach(^{
      subject = supportedTypeIdentifiers;
    });
    it(@"includes supported types", ^{
      expect(subject).to.contain(supportedTypeIdentifier);
    });
    it(@"excludes unsupported types", ^{
      expect(subject).notTo.contain(unsupportedTypeIdentifier);
    });
  });

  describe(@"+forSample:error:", ^{
    __block NSError* error = nil;
    __block HKSample* sample;
    __block OMHSerializer* instance;
    it(@"without sample raises exception", ^{
      expect(^{
        [OMHSerializer forSample:nil error:nil];
      }).to.raise(NSInternalInconsistencyException);
    });
    context(@"with sample of unsupported type", ^{
      beforeEach(^{
        sample = [OMHSampleFactory typeIdentifier:unsupportedTypeIdentifier];
        instance = [OMHSerializer forSample:sample error:&error];
      });
      it(@"returns nil", ^{
        expect(instance).to.beNil();
      });
      it(@"populates error", ^{
        expect(error).notTo.beNil();
        expect(error.code).to.equal(OMHErrorCodeUnsupportedType);
        expect(error.localizedDescription).to.contain(unsupportedTypeIdentifier);
      });
    });
    [supportedTypeIdentifiers each:^(NSString* typeIdentifier){
      context([NSString stringWithFormat:
      @"with sample of supported type %@", typeIdentifier], ^{
        it(@"and supported values returns instance", ^{
          sample = [OMHSampleFactory typeIdentifier:typeIdentifier];
          instance = [OMHSerializer forSample:sample error:&error];
          expect(instance).to.beKindOf([OMHSerializer class]);
        });
      });
    }];
  });

});
SpecEnd

SharedExamplesBegin(AnySerializerForSupportedSample)
sharedExamplesFor(@"AnySerializerForSupportedSample", ^(NSDictionary* data) {
  describe(@"-jsonOrError:", ^{
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
                              againstSchemaAtPath:@"generic/data-point"
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
        @"header.schema_id.namespace": @"omh",
        @"header.schema_id.version": @"1.0",
      }];
      [allKeysValues each:^(id keyPath, id keyPathValue){
        expect([object valueForKeyPath:keyPath]).to.equal(keyPathValue);
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
    NSDictionary* pathsToValues = @{
      @"header.schema_id.name": @"step-count",
      @"body.step_count": value,
      @"body.effective_time_frame.start_date_time": [sample.startDate RFC3339String],
      @"body.effective_time_frame.end_date_time": [sample.endDate RFC3339String]
      };
    return @{
      @"sample": sample,
      @"pathsToValues": pathsToValues
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
        @"body.body_height.value": value,
        @"body.body_height.unit": unitString,
        @"body.effective_time_frame.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.end_date_time": [sample.endDate RFC3339String]
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
        @"body.body_weight.value": value,
        @"body.body_weight.unit": unitString,
        @"body.effective_time_frame.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.end_date_time": [sample.endDate RFC3339String]
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
        @"body.blood_glucose.value": value,
        @"body.blood_glucose.unit": unitString,
        @"body.effective_time_frame.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.end_date_time": [sample.endDate RFC3339String]
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
        @"body.kcal_burned.value": value,
        @"body.kcal_burned.unit": unitString,
        @"body.effective_time_frame.start_date_time": [sample.startDate RFC3339String],
        @"body.effective_time_frame.end_date_time": [sample.endDate RFC3339String]
      }
    };
  });
});

describe(HKCategoryTypeIdentifierSleepAnalysis, ^{
  NSString* identifier = HKCategoryTypeIdentifierSleepAnalysis;
  itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
    NSDate* start = [NSDate date];
    NSInteger secs = [@1800 integerValue];
    NSDate* end =
      [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitSecond
                                               value:secs
                                              toDate:start
                                             options:kNilOptions];
    HKSample* sample =
      [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierSleepAnalysis
                                 attrs:@{ @"start": start, @"end": end }];
    return @{
      @"sample": sample,
      @"pathsToValues": @{
        @"header.schema_id.name": @"sleep-duration",
        @"body.sleep_duration.value": [NSNumber numberWithInteger:secs],
        @"body.sleep_duration.unit": @"sec",
        @"body.effective_time_frame.start_date_time": [start RFC3339String],
        @"body.effective_time_frame.end_date_time": [end RFC3339String],
      }
    };
  });
  describe(@"+forSample:error:", ^{
    __block NSError* error = nil;
    __block HKSample* sample;
    __block OMHSerializer* instance;
    context(@"if sample's value unsupported", ^{
      beforeEach(^{
        HKCategoryType* type =
          [HKObjectType categoryTypeForIdentifier:identifier];
        sample =
          [HKCategorySample categorySampleWithType:type
                                             value:HKCategoryValueSleepAnalysisInBed
                                         startDate:[NSDate date]
                                           endDate:[NSDate date]];
        instance = [OMHSerializer forSample:sample error:&error];
      });
      it(@"returns nil", ^{
        OMHSerializer* instance = [OMHSerializer forSample:sample error:nil];
        expect(instance).to.beNil();
      });
      it(@"populates error", ^{
        expect(error).notTo.beNil();
        expect(error.code).to.equal(OMHErrorCodeUnsupportedValues);
        expect(error.localizedDescription).to.contain(@"HKCategoryValueSleepAnalysis");
      });
    });
  });
});

describe(HKCorrelationTypeIdentifierBloodPressure, ^{
  __block NSNumber* diastolicValue = nil;
  __block NSNumber* systolicValue = nil;
  __block HKSample* diastolicSample = nil;
  __block HKSample* systolicSample = nil;
  __block HKSample* sample = nil;
  __block NSDate* sampledAt = nil;
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
  describe(@"+forSample:error:", ^{
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
        instance = [OMHSerializer forSample:sample error:&error];
      });
      it(@"returns nil", ^{
        expect(instance).to.beNil();
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
        @"body.systolic_blood_pressure.value": systolicValue,
        @"body.systolic_blood_pressure.unit": @"mmHg",
        @"body.diastolic_blood_pressure.value": diastolicValue,
        @"body.diastolic_blood_pressure.unit": @"mmHg",
        @"body.effective_time_frame.time_interval.start_date_time": [sampledAt RFC3339String],
        @"body.effective_time_frame.time_interval.end_date_time": [sampledAt RFC3339String],
      }
    };
  });
});

SpecEnd

