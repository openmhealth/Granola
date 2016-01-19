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

#import "OMHSampleFactory.h"
#import "HKObject+Private.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#include <stdlib.h>

@implementation OMHSampleFactory

+ (HKSample*)typeIdentifier:(NSString*)sampleTypeIdentifier
                      attrs:(NSDictionary*)attrs {
    id (^or)(id this, id that) = ^(id this, id that) {
        return (this) ? this : that;
    };
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* defaultStart = [NSDate date];
    NSDate* defaultEnd = [calendar dateByAddingUnit:NSCalendarUnitSecond
                                              value:30
                                             toDate:defaultStart
                                            options:kNilOptions];
    NSDate* start = or(attrs[@"start"], defaultStart);
    NSDate* end = or(attrs[@"end"], defaultEnd);
    NSDictionary *metadata = nil;
    if(attrs[@"metadata"]){
        metadata = attrs[@"metadata"];
    }
    HKSample* sample = nil;
    if ([sampleTypeIdentifier hasPrefix:@"HKCategoryTypeIdentifier"]) {
        HKCategoryType* type =
        [HKObjectType categoryTypeForIdentifier:sampleTypeIdentifier];
        NSNumber *defaultValue = [NSNumber numberWithInt:0];
        
        // Apple starts their category enums at different values, for some reproductive health enums, it starts at 1 instead of 0
        if ([type.description isEqualToString:HKCategoryTypeIdentifierCervicalMucusQuality] || [type.description isEqualToString:HKCategoryTypeIdentifierOvulationTestResult] || [type.description isEqualToString:HKCategoryTypeIdentifierMenstrualFlow]){
            
            defaultValue = [NSNumber numberWithInt:1];
        }
        
        NSNumber *value = or(attrs[@"value"], defaultValue);
        
        if ([type.description isEqualToString:HKCategoryTypeIdentifierMenstrualFlow]) {
            
            // Menstrual flow category samples require an HKMetadataKeyMenstrualCycleStart entry. Without it, HealthKit will throw an exception.
            NSMutableDictionary *menstrualStartMetadata = [NSMutableDictionary dictionaryWithDictionary: @{ HKMetadataKeyMenstrualCycleStart : @true}];
            
            if (metadata !=nil){
                [menstrualStartMetadata addEntriesFromDictionary:metadata];
            }

            metadata = menstrualStartMetadata;
        }
        
        sample =
        [HKCategorySample categorySampleWithType:type
                                           value:[value integerValue]
                                       startDate:start
                                         endDate:end
                                        metadata:metadata];
    }
    else if (sampleTypeIdentifier == HKCorrelationTypeIdentifierBloodPressure) {
        NSSet* defaultSamples = [NSSet setWithArray:[@[
                                                       HKQuantityTypeIdentifierBloodPressureSystolic,
                                                       HKQuantityTypeIdentifierBloodPressureDiastolic
                                                       ] map:^(NSString* identifier) {
                                                           NSDate* sampledAt = [NSDate date];
                                                           return [OMHSampleFactory typeIdentifier:identifier
                                                                                             attrs:@{  @"start": sampledAt,
                                                                                                       @"end": sampledAt }];
                                                       }]];
        NSSet* objects = or(attrs[@"objects"], defaultSamples);
        HKCorrelationType *bloodPressureType =
        [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
        NSDictionary *metadata = nil;
        
        sample =
        (HKSample*)[HKCorrelation correlationWithType:bloodPressureType
                                            startDate:start
                                              endDate:end
                                              objects:objects
                                             metadata:metadata];
    }
    else if (sampleTypeIdentifier == HKCorrelationTypeIdentifierFood){
        NSSet *nutritionContentSamples = nil;
        if(attrs[@"objects"]){
            nutritionContentSamples = attrs[@"objects"];
        }
        else{
            HKQuantitySample *defaultCarbQuantitySample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates] quantity:[HKQuantity quantityWithUnit:[HKUnit unitFromString:@"g"] doubleValue:29.3] startDate:start endDate:end metadata:nil];
            HKQuantitySample *defaultCalorieQuantitySample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed] quantity:[HKQuantity quantityWithUnit:[HKUnit unitFromString:@"kcal"] doubleValue:105] startDate:start endDate:end metadata:nil];
            nutritionContentSamples = [NSSet setWithArray:@[defaultCarbQuantitySample,defaultCalorieQuantitySample]];
        }
        NSDictionary *metadata = nil;
        
        sample = (HKSample*)[HKCorrelation correlationWithType:[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood]
                                                     startDate:start
                                                       endDate:end
                                                       objects:nutritionContentSamples
                                                      metadata:metadata];
    }
    else if (sampleTypeIdentifier == HKWorkoutTypeIdentifier){
        //If we pass attributes into the sample factory, then they should be used in creating the sample
        if([attrs count]>0){
            
            NSTimeInterval duration = 100;
            int activityType = HKWorkoutActivityTypeCycling;
            if(attrs[@"activity_type"]){
                NSString *activityTypeStr = (NSString*)attrs[@"activity_type"];
                activityType = [activityTypeStr intValue];
            }
            
            //If one of these three keys has been set in the attributes that were passed to the factory, then we want to create a more complex workout sample
            if([attrs hasKey:@"duration"] || [attrs hasKey:@"energy_burned"] || [attrs hasKey:@"distance"]){
                if(attrs[@"duration"]){
                    NSString *timeIntervalStr = (NSString*)attrs[@"duration"];
                    duration = [timeIntervalStr doubleValue];
                }
                
                NSDictionary *metadata = nil;
                
                HKQuantity *defaultEnergyBurned = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"kcal"] doubleValue:120.1];
                HKQuantity *defaultDistance = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"km"] doubleValue:5.2];
                sample = (HKSample*)[HKWorkout workoutWithActivityType:activityType startDate:or(attrs[@"start"],defaultStart) endDate:or(attrs[@"end"],defaultEnd) duration:duration totalEnergyBurned:or(attrs[@"energy_burned"],defaultEnergyBurned) totalDistance:or(attrs[@"distance"],defaultDistance) metadata:metadata];
            }
            //If we do not have keys in the attribute dictionary for the more complex pieces of workout data, then we can create a simple workout sample
            else{
                sample = (HKSample*)[HKWorkout workoutWithActivityType:activityType startDate:or(attrs[@"start"],defaultStart) endDate:or(attrs[@"end"],defaultEnd)];
            }
            
        }
        //If no attributes are passed into the sample factory, then we can create a simple workout with start and end date set to now
        else{
            sample = (HKSample*)[HKWorkout workoutWithActivityType:HKWorkoutActivityTypeCycling startDate:[NSDate date] endDate:[NSDate date]];
        }
        
    }
    else if ([@[ HKQuantityTypeIdentifierHeight,
                 HKQuantityTypeIdentifierBodyMass,
                 HKQuantityTypeIdentifierHeartRate,
                 HKQuantityTypeIdentifierStepCount,
                 HKQuantityTypeIdentifierNikeFuel,
                 HKQuantityTypeIdentifierBloodGlucose,
                 HKQuantityTypeIdentifierBasalEnergyBurned,
                 HKQuantityTypeIdentifierActiveEnergyBurned,
                 HKQuantityTypeIdentifierBloodPressureSystolic,
                 HKQuantityTypeIdentifierBloodPressureDiastolic,
                 HKQuantityTypeIdentifierBodyMassIndex,
                 HKQuantityTypeIdentifierDietaryBiotin,
                 HKQuantityTypeIdentifierDietaryWater,
                 HKQuantityTypeIdentifierInhalerUsage,
                 HKQuantityTypeIdentifierDietaryCarbohydrates,
                 HKQuantityTypeIdentifierDietaryEnergyConsumed,
                 HKQuantityTypeIdentifierUVExposure,
                 HKQuantityTypeIdentifierOxygenSaturation,
                 HKQuantityTypeIdentifierBodyFatPercentage,
                 HKQuantityTypeIdentifierRespiratoryRate,
                 HKQuantityTypeIdentifierBodyTemperature
                 ] includes:sampleTypeIdentifier]) {
        
        NSString* defaultUnitString = nil;
        if (sampleTypeIdentifier == HKQuantityTypeIdentifierHeight) {
            defaultUnitString = @"cm";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierBodyMass) {
            defaultUnitString = @"lb";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierHeartRate || sampleTypeIdentifier == HKQuantityTypeIdentifierRespiratoryRate) {
            defaultUnitString = @"count/min";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierBloodGlucose) {
            defaultUnitString = @"mg/dL";
        } else if ([sampleTypeIdentifier containsString:@"EnergyBurned"]) {
            defaultUnitString = @"kcal";
        } else if ([sampleTypeIdentifier containsString:@"HKQuantityTypeIdentifierBloodPressure"]) {
            defaultUnitString = @"mmHg";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierDietaryBiotin) {
            defaultUnitString = @"mcg";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierDietaryWater) {
            defaultUnitString = @"L";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierOxygenSaturation || sampleTypeIdentifier == HKQuantityTypeIdentifierBodyFatPercentage) {
            defaultUnitString = @"%";
        } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierBodyTemperature) {
            defaultUnitString = @"degC";
        } else {
            defaultUnitString = @"count";
        };
        NSString* unitString = or(attrs[@"unitString"], defaultUnitString);
        
        NSNumber* defaultValue =
        [NSNumber numberWithInteger:arc4random_uniform(74)];
        NSNumber* value = or(attrs[@"value"], defaultValue);
        
        HKUnit* unit = [HKUnit unitFromString:unitString];
        HKQuantityType* quantityType =
        [HKObjectType quantityTypeForIdentifier:sampleTypeIdentifier];
        HKQuantity* quantity = [HKQuantity quantityWithUnit:unit
                                                doubleValue:value.doubleValue];
        NSDictionary *metadata = nil;
        if(attrs[@"metadata"]){
            metadata = attrs[@"metadata"];
        }
        
        sample =
        [HKQuantitySample quantitySampleWithType:quantityType
                                        quantity:quantity
                                       startDate:start
                                         endDate:end
                                        metadata:metadata];
    }
    // validate sample object using HK private API, exposed via category,
    // see HKObject+Private.h
    // NOTE: throws _HKObjectValidationFailureException if invalid
    
    [sample validateForSaving:nil];
    return sample;
}

+ (HKSample*)typeIdentifier:(NSString*)typeIdentifier {
    return [self typeIdentifier:typeIdentifier attrs:@{}];
}

@end

