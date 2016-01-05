/*
 * Copyright 2015 Open mHealth
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

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "OMHHealthKitConstantsMapper.h"

@implementation OMHHealthKitConstantsMapper
+ (NSString*)stringForHKWorkoutActivityType:(int) enumValue{
    switch( enumValue ){
        case HKWorkoutActivityTypeAmericanFootball:
            return @"HKWorkoutActivityTypeAmericanFootball";
        case HKWorkoutActivityTypeArchery:
            return @"HKWorkoutActivityTypeArchery";
        case HKWorkoutActivityTypeAustralianFootball:
            return @"HKWorkoutActivityTypeAustralianFootball";
        case HKWorkoutActivityTypeBadminton:
            return @"HKWorkoutActivityTypeBadminton";
        case HKWorkoutActivityTypeBaseball:
            return @"HKWorkoutActivityTypeBaseball";
        case HKWorkoutActivityTypeBasketball:
            return @"HKWorkoutActivityTypeBasketball";
        case HKWorkoutActivityTypeBowling:
            return @"HKWorkoutActivityTypeBowling";
        case HKWorkoutActivityTypeBoxing:
            return @"HKWorkoutActivityTypeBoxing";
        case HKWorkoutActivityTypeClimbing:
            return @"HKWorkoutActivityTypeClimbing";
        case HKWorkoutActivityTypeCricket:
            return @"HKWorkoutActivityTypeCricket";
        case HKWorkoutActivityTypeCrossTraining:
            return @"HKWorkoutActivityTypeCrossTraining";
        case HKWorkoutActivityTypeCurling:
            return @"HKWorkoutActivityTypeCurling";
        case HKWorkoutActivityTypeCycling:
            return @"HKWorkoutActivityTypeCycling";
        case HKWorkoutActivityTypeDance:
            return @"HKWorkoutActivityTypeDance";
        case HKWorkoutActivityTypeDanceInspiredTraining:
            return @"HKWorkoutActivityTypeDanceInspiredTraining";
        case HKWorkoutActivityTypeElliptical:
            return @"HKWorkoutActivityTypeElliptical";
        case HKWorkoutActivityTypeEquestrianSports:
            return @"HKWorkoutActivityTypeEquestrianSports";
        case HKWorkoutActivityTypeFencing:
            return @"HKWorkoutActivityTypeFencing";
        case HKWorkoutActivityTypeFishing:
            return @"HKWorkoutActivityTypeFishing";
        case HKWorkoutActivityTypeFunctionalStrengthTraining:
            return @"HKWorkoutActivityTypeFunctionalStrengthTraining";
        case HKWorkoutActivityTypeGolf:
            return @"HKWorkoutActivityTypeGolf";
        case HKWorkoutActivityTypeGymnastics:
            return @"HKWorkoutActivityTypeGymnastics";
        case HKWorkoutActivityTypeHandball:
            return @"HKWorkoutActivityTypeHandball";
        case HKWorkoutActivityTypeHiking:
            return @"HKWorkoutActivityTypeHiking";
        case HKWorkoutActivityTypeHockey:
            return @"HKWorkoutActivityTypeHockey";
        case HKWorkoutActivityTypeHunting:
            return @"HKWorkoutActivityTypeHunting";
        case HKWorkoutActivityTypeLacrosse:
            return @"HKWorkoutActivityTypeLacrosse";
        case HKWorkoutActivityTypeMartialArts:
            return @"HKWorkoutActivityTypeMartialArts";
        case HKWorkoutActivityTypeMindAndBody:
            return @"HKWorkoutActivityTypeMindAndBody";
        case HKWorkoutActivityTypeMixedMetabolicCardioTraining:
            return @"HKWorkoutActivityTypeMixedMetabolicCardioTraining";
        case HKWorkoutActivityTypePaddleSports:
            return @"HKWorkoutActivityTypePaddleSports";
        case HKWorkoutActivityTypePlay:
            return @"HKWorkoutActivityTypePlay";
        case HKWorkoutActivityTypePreparationAndRecovery:
            return @"HKWorkoutActivityTypePreparationAndRecovery";
        case HKWorkoutActivityTypeRacquetball:
            return @"HKWorkoutActivityTypeRacquetball";
        case HKWorkoutActivityTypeRowing:
            return @"HKWorkoutActivityTypeRowing";
        case HKWorkoutActivityTypeRugby:
            return @"HKWorkoutActivityTypeRugby";
        case HKWorkoutActivityTypeRunning:
            return @"HKWorkoutActivityTypeRunning";
        case HKWorkoutActivityTypeSailing:
            return @"HKWorkoutActivityTypeSailing";
        case HKWorkoutActivityTypeSkatingSports:
            return @"HKWorkoutActivityTypeSkatingSports";
        case HKWorkoutActivityTypeSnowSports:
            return @"HKWorkoutActivityTypeSnowSports";
        case HKWorkoutActivityTypeSoccer:
            return @"HKWorkoutActivityTypeSoccer";
        case HKWorkoutActivityTypeSoftball:
            return @"HKWorkoutActivityTypeSoftball";
        case HKWorkoutActivityTypeSquash:
            return @"HKWorkoutActivityTypeSquash";
        case HKWorkoutActivityTypeStairClimbing:
            return @"HKWorkoutActivityTypeStairClimbing";
        case HKWorkoutActivityTypeSurfingSports:
            return @"HKWorkoutActivityTypeSurfingSports";
        case HKWorkoutActivityTypeSwimming:
            return @"HKWorkoutActivityTypeSwimming";
        case HKWorkoutActivityTypeTableTennis:
            return @"HKWorkoutActivityTypeTableTennis";
        case HKWorkoutActivityTypeTennis:
            return @"HKWorkoutActivityTypeTennis";
        case HKWorkoutActivityTypeTrackAndField:
            return @"HKWorkoutActivityTypeTrackAndField";
        case HKWorkoutActivityTypeTraditionalStrengthTraining:
            return @"HKWorkoutActivityTypeTraditionalStrengthTraining";
        case HKWorkoutActivityTypeVolleyball:
            return @"HKWorkoutActivityTypeVolleyball";
        case HKWorkoutActivityTypeWalking:
            return @"HKWorkoutActivityTypeWalking";
        case HKWorkoutActivityTypeWaterFitness:
            return @"HKWorkoutActivityTypeWaterFitness";
        case HKWorkoutActivityTypeWaterPolo:
            return @"HKWorkoutActivityTypeWaterPolo";
        case HKWorkoutActivityTypeWaterSports:
            return @"HKWorkoutActivityTypeWaterSports";
        case HKWorkoutActivityTypeWrestling:
            return @"HKWorkoutActivityTypeWrestling";
        case HKWorkoutActivityTypeYoga:
            return @"HKWorkoutActivityTypeYoga";
        case HKWorkoutActivityTypeOther:
            return @"HKWorkoutActivityTypeOther";
        default:
            return @"";
    }
}

+ (NSString*) stringForHKSleepAnalysisValue:(int) enumValue{
    switch (enumValue){
        case HKCategoryValueSleepAnalysisInBed:
            return @"InBed";
            break;
        case HKCategoryValueSleepAnalysisAsleep:
            return @"Asleep";
            break;
        default:{
            NSException *e = [NSException
                              exceptionWithName:@"KCategoryValueSleepAnalysisInvalidValue"
                              reason:@"KCategoryValueSleepAnalysis can only have a HKCategoryValueSleepAnalysisInBed or HKCategoryValueSleepAnalysisAsleep value"
                              userInfo:nil];
            @throw e;
        }
            
    }
}

+  (NSDictionary*)allSupportedTypeIdentifiersToClasses {
    static NSDictionary* allTypeIdsToClasses = nil;
    if (allTypeIdsToClasses == nil) {
        allTypeIdsToClasses = @{
                                HKQuantityTypeIdentifierActiveEnergyBurned: @"OMHSerializerEnergyBurned",
                                HKQuantityTypeIdentifierBasalBodyTemperature: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBasalEnergyBurned: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBloodAlcoholContent: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBloodGlucose : @"OMHSerializerBloodGlucose",
                                HKQuantityTypeIdentifierBloodPressureDiastolic: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBloodPressureSystolic: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBodyFatPercentage: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierBodyMass : @"OMHSerializerWeight",
                                HKQuantityTypeIdentifierBodyMassIndex: @"OMHSerializerBodyMassIndex",
                                HKQuantityTypeIdentifierBodyTemperature: @"OMHSerializerBodyMassIndex",
                                HKQuantityTypeIdentifierDietaryBiotin: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryCaffeine: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryCalcium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryCarbohydrates: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryChloride: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryCholesterol: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryChromium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryCopper: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryEnergyConsumed: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFatMonounsaturated: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFatPolyunsaturated: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFatSaturated: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFatTotal: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFiber: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryFolate: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryIodine: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryIron: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryMagnesium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryManganese: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryMolybdenum: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryNiacin: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryPantothenicAcid: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryPhosphorus: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryPotassium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryProtein: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryRiboflavin: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietarySelenium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietarySodium: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietarySugar: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryThiamin: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminA: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminB12: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminB6: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminC: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminD: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminE: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryVitaminK: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryWater: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDietaryZinc: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDistanceCycling: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierDistanceWalkingRunning: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierElectrodermalActivity: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierFlightsClimbed: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierForcedExpiratoryVolume1: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierForcedVitalCapacity: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierHeight : @"OMHSerializerHeight",
                                HKQuantityTypeIdentifierHeartRate : @"OMHSerializerHeartRate",
                                HKQuantityTypeIdentifierInhalerUsage: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierLeanBodyMass: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierNikeFuel: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierNumberOfTimesFallen: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierOxygenSaturation: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierPeakExpiratoryFlowRate: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierPeripheralPerfusionIndex: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierRespiratoryRate: @"OMHSerializerGenericQuantitySample",
                                HKQuantityTypeIdentifierStepCount : @"OMHSerializerStepCount",
                                HKQuantityTypeIdentifierUVExposure: @"OMHSerializerGenericQuantitySample",
                                HKCategoryTypeIdentifierSleepAnalysis : @"OMHSerializerSleepAnalysis", //Samples with Asleep value use this serializer, samples with InBed value use generic category serializer
                                HKCorrelationTypeIdentifierBloodPressure: @"OMHSerializerBloodPressure",
                                HKCorrelationTypeIdentifierFood: @"OMHSerializerGenericCorrelation",
                                HKWorkoutTypeIdentifier: @"OMHSerializerGenericWorkout"
                                };
    }
    return allTypeIdsToClasses;
        
}


@end

