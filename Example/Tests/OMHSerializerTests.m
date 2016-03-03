/*
 * Copyright 2016 Open mHealth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
                                   HKCategoryTypeIdentifierAppleStandHour,
                                   HKQuantityTypeIdentifierStepCount,
                                   HKQuantityTypeIdentifierDistanceWalkingRunning,
                                   HKQuantityTypeIdentifierDistanceCycling,
                                   HKQuantityTypeIdentifierActiveEnergyBurned,
                                   HKQuantityTypeIdentifierFlightsClimbed,
                                   HKQuantityTypeIdentifierNikeFuel,
                                   ],
                           @"Vital Signs Identifiers": @[
                                   HKQuantityTypeIdentifierHeartRate,
                                   HKQuantityTypeIdentifierBasalBodyTemperature,
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
                                   HKQuantityTypeIdentifierDietaryWater,
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
                                   ],
                           @"Sexual and Reproductive Health Identifier": @[
                                   HKCategoryTypeIdentifierCervicalMucusQuality,
                                   HKCategoryTypeIdentifierIntermenstrualBleeding,
                                   HKCategoryTypeIdentifierMenstrualFlow,
                                   HKCategoryTypeIdentifierOvulationTestResult,
                                   HKCategoryTypeIdentifierSexualActivity
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
            [[OMHSerializer supportedTypeIdentifiersWithOMHSchema] includes:typeName];
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
    
    NSArray* typeIdentifiersWithOMHSchema = [OMHSerializer supportedTypeIdentifiersWithOMHSchema];
    NSString* supportedTypeIdentifier =  [typeIdentifiersWithOMHSchema firstObject];
    
    NSArray* additionalTypeIdentifiersToTest = [NSMutableArray arrayWithArray:@[
                                                                                HKQuantityTypeIdentifierDietaryBiotin,
                                                                                HKQuantityTypeIdentifierDietaryWater,
                                                                                HKQuantityTypeIdentifierInhalerUsage,
                                                                                HKQuantityTypeIdentifierUVExposure,
                                                                                HKCategoryTypeIdentifierAppleStandHour,
                                                                                HKCategoryTypeIdentifierCervicalMucusQuality,
                                                                                HKCategoryTypeIdentifierIntermenstrualBleeding,
                                                                                HKCategoryTypeIdentifierMenstrualFlow,
                                                                                HKCategoryTypeIdentifierOvulationTestResult,
                                                                                HKCategoryTypeIdentifierSexualActivity,
                                                                                HKQuantityTypeIdentifierBasalBodyTemperature,
                                                                                HKQuantityTypeIdentifierBodyTemperature,
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
                                    againstSchemaAtPath:@"omh/data-point-1.x"
                                              withError:&validationError];
            expect(valid).to.beTruthy();
        });
        it(@"validates against body schema", ^{
            NSError* validationError = nil;
            NSString* majorSchemaNumber = [[pathsToValues valueForKey:@"header.schema_id.version"] componentsSeparatedByString:@"."].firstObject;
            BOOL valid = [OMHSchemaStore validateObject:[object valueForKeyPath:@"body"]
                                    againstSchemaAtPath:[NSString stringWithFormat:@"%@/%@-%@.x",[pathsToValues valueForKeyPath:@"header.schema_id.namespace"],[pathsToValues valueForKeyPath:@"header.schema_id.name"],majorSchemaNumber]
                                              withError:&validationError];
            expect(valid).to.beTruthy();
        });
        it(@"contains correct data", ^{
            NSMutableDictionary* allKeysValues =
            [NSMutableDictionary dictionaryWithDictionary:pathsToValues];
            // shared header keys
            [allKeysValues addEntriesFromDictionary:@{
                                                      @"header.id": sample.UUID.UUIDString,
                                                      @"header.creation_date_time": [sample.startDate RFC3339String]
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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

describe(@"HKQuantityTypeIdentifierBloodGlucose with date as metadata", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSString* unitString = @"mg/dL";
        NSNumber* value = [NSNumber numberWithDouble:120];
        NSString* expectedMetadataDateString = @"2015-06-28T05:06:09.100-06:00";
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        NSDate *metadataDate = [formatter dateFromString:expectedMetadataDateString];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodGlucose
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"metadata":@{
                                                    @"HKMetaDataKeyDateCreated":metadataDate
                                                    }
                                            }];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"blood-glucose",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.blood_glucose.value": value,
                         @"body.blood_glucose.unit": unitString,
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String],
                         @"body.metadata.key":@[@"HKMetaDataKeyDateCreated"],   //Because metadata value validation iterates over an array,
                                                                                //these values must be in array form
                         @"body.metadata.value":@[[metadataDate RFC3339String]]
                         
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                                                                      HKMetadataKeyReferenceRangeLowerLimit:referenceLowValue
                                                                      }
                                                              }];
        return @{
                 @"sample":sample,
                 @"pathsToValues":@{
                         @"header.schema_id.name":@"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.quantity_type":[HKQuantityTypeIdentifierDietaryBiotin description],
                         @"body.unit_value.value":value,
                         @"body.unit_value.unit":unitString,
                         @"body.effective_time_frame.time_interval.start_date_time":[start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time":[end RFC3339String],
                         @"body.metadata.key":@[HKMetadataKeyWasTakenInLab.description, HKMetadataKeyReferenceRangeLowerLimit.description],
                         @"body.metadata.value":@[@YES, referenceLowValue]
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
                         @"header.schema_id.version": @"1.0",
                         @"body.quantity_type":[HKQuantityTypeIdentifierInhalerUsage description],
                         @"body.count":value,
                         @"body.effective_time_frame.date_time":[start RFC3339String]
                         }
                 };
    });
});

describe(@"Generic quantity sample with percent unit", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = start;
        NSNumber *value = [NSNumber numberWithDouble:.127];
        NSString *unitString = @"%";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.quantity_type":[HKQuantityTypeIdentifierBloodAlcoholContent description],
                         @"body.unit_value.value":@12.7,
                         @"body.unit_value.unit":@"%",
                         @"body.effective_time_frame.date_time":[start RFC3339String]
                         }
                 };
    });
});

describe(HKCorrelationTypeIdentifierFood,^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
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
                         @"header.schema_id.version": @"1.0",
                         @"body.effective_time_frame.time_interval.start_date_time": [correlationStart RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [correlationEnd RFC3339String],
                         @"body.correlation_type": [HKCorrelationTypeIdentifierFood description],
                         @"body.quantity_samples.effective_time_frame.date_time": @[[sampleDate RFC3339String],[sampleDate RFC3339String]],
                         @"body.quantity_samples.unit_value.value": @[carbValue,calorieValue],
                         @"body.quantity_samples.unit_value.unit": @[carbUnitString,calorieUnitString],
                         @"body.quantity_samples.quantity_type": @[[HKQuantityTypeIdentifierDietaryCarbohydrates description],
                                                                   [HKQuantityTypeIdentifierDietaryEnergyConsumed description]]
                         
                         
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
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
                         @"header.schema_id.version": @"1.0",
                         @"body.systolic_blood_pressure.value": systolicValue,
                         @"body.systolic_blood_pressure.unit": @"mmHg",
                         @"body.diastolic_blood_pressure.value": diastolicValue,
                         @"body.diastolic_blood_pressure.unit": @"mmHg",
                         @"body.effective_time_frame.date_time": [sampledAt RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierDietaryWater with datetime", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSNumber *value = [NSNumber numberWithFloat:24.3];
        NSString *unitString = @"L";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryWater
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":start}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.quantity_type":[HKQuantityTypeIdentifierDietaryWater description],
                         @"body.unit_value.value":value,
                         @"body.unit_value.unit":unitString,
                         @"body.effective_time_frame.date_time":[start RFC3339String],
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierUVExposure with time interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:7];
        NSString *unitString = @"count";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierUVExposure
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-quantity-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.quantity_type":[HKQuantityTypeIdentifierUVExposure description],
                         @"body.count":value,
                         @"body.effective_time_frame.time_interval.start_date_time":[start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time":[end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierAppleStandHour Stood", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierAppleStandHour
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueAppleStandHourStood)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Standing",
                         @"body.category_type": HKCategoryTypeIdentifierAppleStandHour,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierAppleStandHour Idle", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierAppleStandHour
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueAppleStandHourIdle)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Idle",
                         @"body.category_type": HKCategoryTypeIdentifierAppleStandHour,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierCervicalMucusQuality Egg White", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierCervicalMucusQuality
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueCervicalMucusQualityEggWhite)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Egg white",
                         @"body.category_type": HKCategoryTypeIdentifierCervicalMucusQuality,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierIntermenstrualBleeding", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueNotApplicable)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Intermenstrual bleeding",
                         @"body.category_type": HKCategoryTypeIdentifierIntermenstrualBleeding,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierMenstrualFlow medium", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierMenstrualFlow
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueMenstrualFlowMedium)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Medium",
                         @"body.category_type": HKCategoryTypeIdentifierMenstrualFlow,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String],
                         @"body.metadata.key": @[HKMetadataKeyMenstrualCycleStart],
                         @"body.metadata.value": @[@true]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierOvulationTestResult negative", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierOvulationTestResult
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueOvulationTestResultNegative)}];
        
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Negative",
                         @"body.category_type": HKCategoryTypeIdentifierOvulationTestResult,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKCategoryTypeIdentifierSexualActivity", ^{
    
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSDate* start = [NSDate date];
        NSDate* end = [start dateByAddingTimeInterval:60*18];
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKCategoryTypeIdentifierSexualActivity
                                   attrs:@{ @"start": start, @"end": end, @"value":@(HKCategoryValueNotApplicable)}];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"hk-category-sample",
                         @"header.schema_id.namespace":@"granola",
                         @"header.schema_id.version": @"1.0",
                         @"body.category_value": @"Sexual activity",
                         @"body.category_type": HKCategoryTypeIdentifierSexualActivity,
                         @"body.effective_time_frame.time_interval.start_date_time": [start RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [end RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierOxygenSaturation with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSNumber *value = [NSNumber numberWithDouble:.961];
        NSString *unitString = @"%";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierOxygenSaturation
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":start}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"oxygen-saturation",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.oxygen_saturation.value":@96.1,
                         @"body.oxygen_saturation.unit":unitString,
                         @"body.effective_time_frame.date_time":[start RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierBasalEnergyBurned with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:453.5];
        NSString *unitString = @"kcal";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"calories-burned",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.kcal_burned.value": value,
                         @"body.kcal_burned.unit": unitString,
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierBodyFatPercentage with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber  numberWithDouble:.232];
        NSString *unitString = @"%";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyFatPercentage
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"body-fat-percentage",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.body_fat_percentage.value": @23.2,
                         @"body.body_fat_percentage.unit": unitString,
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierRespiratoryRate with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:23.2];
        NSString *unitString = @"count/min";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierRespiratoryRate
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"respiratory-rate",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.respiratory_rate.value": value,
                         @"body.respiratory_rate.unit": @"breaths/min",
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierRespiratoryRate with time_interval", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:23.2];
        NSString *unitString = @"count/min";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierRespiratoryRate
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end}];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"respiratory-rate",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.respiratory_rate.value": value,
                         @"body.respiratory_rate.unit": @"breaths/min",
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierRespiratoryRate with time_interval with metadata", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample",^{
        NSDate *start = [NSDate date];
        NSDate *end = [start dateByAddingTimeInterval:3600];
        NSNumber *value = [NSNumber numberWithFloat:23.2];
        NSString *unitString = @"count/min";
        HKSample *sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierRespiratoryRate
                                                      attrs:@{@"value":value,
                                                              @"unitString":unitString,
                                                              @"start":start,
                                                              @"end":end,
                                                              @"metadata":@{
                                                                      HKMetadataKeyWasUserEntered:@YES
                                                                      }
                                                              }];
        return @{
                 @"sample":sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"respiratory-rate",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"1.0",
                         @"body.respiratory_rate.value": value,
                         @"body.respiratory_rate.unit": @"breaths/min",
                         @"body.effective_time_frame.time_interval.start_date_time": [sample.startDate RFC3339String],
                         @"body.effective_time_frame.time_interval.end_date_time": [sample.endDate RFC3339String],
                         @"body.metadata.key":@[HKMetadataKeyWasUserEntered],
                         @"body.metadata.value":@[@YES]
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierBodyTemperature with date_time with no location", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSNumber* value = [NSNumber numberWithDouble:37.1];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degC";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt }];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"body-temperature",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"2.0",
                         @"body.body_temperature.value": [NSNumber numberWithFloat:37.1],
                         @"body.body_temperature.unit": @"C",
                         @"body.effective_time_frame.date_time": [sampledAt RFC3339String],
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierBodyTemperature temperature units serialization", ^{
   
    it(@"Should have correct unit value for degrees celcius", ^{
        
        NSNumber* value = [NSNumber numberWithFloat:38.1];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degC";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt,
                                            }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        expect([jsonObject valueForKeyPath:@"body.body_temperature.unit"]).to.equal(@"C");
        expect([jsonObject valueForKeyPath:@"body.body_temperature.value"]).to.equal([NSNumber numberWithFloat:38.1]);
    });
    
    it(@"Should have correct unit value for degrees fahrenheit", ^{
        
        NSNumber* value = [NSNumber numberWithFloat:99.8];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degF";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt,
                                            }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        expect([jsonObject valueForKeyPath:@"body.body_temperature.unit"]).to.equal(@"C");
        expect([jsonObject valueForKeyPath:@"body.body_temperature.value"]).to.equal([NSNumber numberWithFloat:((99.8 + 459.67) / 1.8) - 273.15]);
    });
    
    it(@"Should have correct unit value for degrees kelvin", ^{
        
        NSNumber* value = [NSNumber numberWithDouble:310.8];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"K";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt,
                                            }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        expect([jsonObject valueForKeyPath:@"body.body_temperature.unit"]).to.equal(@"C");
        expect([jsonObject valueForKeyPath:@"body.body_temperature.value"]).to.equal([NSNumber numberWithFloat:((310.8 * 1.0) - 273.15)]);
    });
    
});

describe(@"HKQuantityTypeIdentifierBodyTemperature measurement location serialization", ^{
    
    id (^createBodyTemperatureSampleWithLocation)(int temperatureLocationId) = ^(int temperatureLocationId) {
        
        NSNumber* value = [NSNumber numberWithDouble:100.1];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degF";
        if(temperatureLocationId>=0){
            return [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                              attrs:@{ @"value": value,
                                                       @"unitString": unitString,
                                                       @"start": sampledAt,
                                                       @"end": sampledAt,
                                                       @"metadata":@{
                                                               HKMetadataKeyBodyTemperatureSensorLocation:[NSNumber numberWithInt:
                                                                                                           temperatureLocationId]
                                                               }
                                                       }];
        }
        else{
            return [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBodyTemperature
                                              attrs:@{ @"value": value,
                                                       @"unitString": unitString,
                                                       @"start": sampledAt,
                                                       @"end": sampledAt
                                                       }];
        }
        
    };
    
    it(@"Should not serialize the location as an OMH schema property when value is not compatible", ^{
        
        id jsonObject = deserializedJsonForSample(createBodyTemperatureSampleWithLocation(HKBodyTemperatureSensorLocationGastroIntestinal));
        
        NSString* location = [jsonObject valueForKeyPath:@"body.measurement_location"];
        
        expect(location).to.beNil();
    });
    
    it(@"Should serialize the measurement location as an OMH schema property when value is compatible", ^{
        
        id jsonObject = deserializedJsonForSample(createBodyTemperatureSampleWithLocation(HKBodyTemperatureSensorLocationMouth));
        
        NSString* location = [jsonObject valueForKeyPath:@"body.measurement_location"];
        
        expect(location).notTo.beNil();
        expect(location).to.equal(@"oral");
    });
    
    it(@"Should not serialize the location as an OMH schema property when value is absent", ^{
       
        id jsonObject = deserializedJsonForSample(createBodyTemperatureSampleWithLocation(-1));
        
        NSString* location = [jsonObject valueForKeyPath:@"body.measurement_location"];
        
        expect(location).to.beNil();
        
    });
});

describe(@"HKQuantityTypeIdentifierBasalBodyTemperature serialization", ^{
    itShouldBehaveLike(@"AnySerializerForSupportedSample", ^{
        NSNumber* value = [NSNumber numberWithDouble:36.9];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degC";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBasalBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt }];
        return @{
                 @"sample": sample,
                 @"pathsToValues": @{
                         @"header.schema_id.name": @"body-temperature",
                         @"header.schema_id.namespace":@"omh",
                         @"header.schema_id.version": @"2.0",
                         @"body.body_temperature.value": [NSNumber numberWithFloat:36.9],
                         @"body.body_temperature.unit": @"C",
                         @"body.effective_time_frame.date_time": [sampledAt RFC3339String],
                         }
                 };
    });
});

describe(@"HKQuantityTypeIdentifierBasalBodyTemperature serialization", ^{
    it(@"Should be a basic body temperature when not self-reported", ^{
        NSNumber* value = [NSNumber numberWithDouble:37.1];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degC";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBasalBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        NSError* validationError = nil;
        BOOL valid = [OMHSchemaStore validateObject:[jsonObject valueForKeyPath:@"body"]
                                againstSchemaAtPath:[NSString stringWithFormat:@"omh/body-temperature-2.x"]
                                          withError:&validationError];
        expect(valid).to.beTruthy();

        expect([jsonObject valueForKeyPath:@"header.schema_id.name"]).to.equal(@"body-temperature");
        expect([jsonObject valueForKeyPath:@"body.measurement_location"]).to.beNil();
        expect([jsonObject valueForKeyPath:@"body.temporal_relationship_to_sleep"]).to.beNil();
    });
    
    it(@"Should be a body temperature taken at waking when self-reported", ^{
        NSNumber* value = [NSNumber numberWithDouble:37.1];
        NSDate* sampledAt = [NSDate date];
        NSString* unitString = @"degC";
        
        HKSample* sample =
        [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierBasalBodyTemperature
                                   attrs:@{ @"value": value,
                                            @"unitString": unitString,
                                            @"start": sampledAt,
                                            @"end": sampledAt,
                                            @"metadata": @{
                                                    HKMetadataKeyWasUserEntered:@true
                                                    }
                                            }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        NSError* validationError = nil;
        BOOL valid = [OMHSchemaStore validateObject:[jsonObject valueForKeyPath:@"body"]
                                againstSchemaAtPath:[NSString stringWithFormat:@"omh/body-temperature-2.x"]
                                          withError:&validationError];
        expect(valid).to.beTruthy();

        expect([jsonObject valueForKeyPath:@"header.schema_id.name"]).to.equal(@"body-temperature");
        expect([jsonObject valueForKeyPath:@"body.measurement_location"]).to.beNil();
        expect([jsonObject valueForKeyPath:@"body.temporal_relationship_to_sleep"]).notTo.beNil();
        expect([jsonObject valueForKeyPath:@"body.temporal_relationship_to_sleep"]).to.equal(@"on waking");
        
    });
});


describe(@"Sample with HKMetadataKeyTimeZone metadata", ^{
    it(@"Should use the time zone value associated with the HKMetadataKeyTimeZone key",^{
        NSCalendar* calendar = [[NSCalendar alloc]
                                    initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents* dateBuilder = [NSDateComponents new];
        
        dateBuilder.year = 2015;
        dateBuilder.day = 28;
        dateBuilder.month = 6;
        dateBuilder.hour = 8;
        dateBuilder.minute = 6;
        dateBuilder.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSDate* start = [calendar dateFromComponents:dateBuilder];
        
        dateBuilder.hour = 9;
        
        NSDate* end = [calendar dateFromComponents:dateBuilder];
        
        HKSample* sample = [OMHSampleFactory typeIdentifier:HKQuantityTypeIdentifierDietaryBiotin
                                                      attrs:@{@"start":start,
                                                              @"end":end,
                                                              @"metadata":@{
                                                                      HKMetadataKeyTimeZone:@"Asia/Kuwait"
                                                                      }
                                                              }];
        
        id jsonObject = deserializedJsonForSample(sample);
        
        expect([jsonObject
                valueForKeyPath:@"body.effective_time_frame.time_interval.start_date_time"]).to.contain(@"2015-06-28T11:06:00.000+03:00");
        expect([jsonObject
                valueForKeyPath:@"body.effective_time_frame.time_interval.end_date_time"]).to.contain(@"2015-06-28T12:06:00.000+03:00");
    });
});

SpecEnd

