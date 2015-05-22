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

  HKSample* sample = nil;
  if (sampleTypeIdentifier == HKCategoryTypeIdentifierSleepAnalysis) {
    HKCategoryType* type =
      [HKObjectType categoryTypeForIdentifier:sampleTypeIdentifier];
    sample =
    [HKCategorySample categorySampleWithType:type
                                       value:HKCategoryValueSleepAnalysisAsleep
                                   startDate:start
                                     endDate:end];
  } else
  if (sampleTypeIdentifier == HKCorrelationTypeIdentifierBloodPressure) {
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
    sample =
      (HKSample*)[HKCorrelation correlationWithType:bloodPressureType
                                          startDate:start
                                            endDate:end
                                            objects:objects];
  } else
  if ([@[ HKQuantityTypeIdentifierHeight,
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
          HKQuantityTypeIdentifierInhalerUsage
        ] includes:sampleTypeIdentifier]) {

    NSString* defaultUnitString = nil;
    if (sampleTypeIdentifier == HKQuantityTypeIdentifierHeight) {
      defaultUnitString = @"cm";
    } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierBodyMass) {
      defaultUnitString = @"lb";
    } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierHeartRate) {
      defaultUnitString = @"count/min";
    } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierBloodGlucose) {
      defaultUnitString = @"mg/dL";
    } else if ([sampleTypeIdentifier containsString:@"EnergyBurned"]) {
      defaultUnitString = @"kcal";
    } else if ([sampleTypeIdentifier containsString:@"HKQuantityTypeIdentifierBloodPressure"]) {
      defaultUnitString = @"mmHg";
    } else if (sampleTypeIdentifier == HKQuantityTypeIdentifierDietaryBiotin) {
     defaultUnitString = @"mcg";
    }
    else {
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
    sample =
      [HKQuantitySample quantitySampleWithType:quantityType
                                      quantity:quantity
                                     startDate:start
                                       endDate:end];
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

