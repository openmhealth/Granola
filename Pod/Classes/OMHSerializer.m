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

#import "OMHSerializer.h"
#import "NSDate+RFC3339.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "OMHHealthKitConstantsMapper.h"

@interface OMHSerializer()
@property (nonatomic, retain) HKSample* sample;
+ (BOOL)canSerialize:(HKSample*)sample error:(NSError**)error;
+ (NSException*)unimplementedException;
@end


@implementation OMHSerializer

+ (NSArray*)supportedTypeIdentifiersWithOMHSchema {
    static NSArray* OMHSchemaTypeIds = nil;
    if(OMHSchemaTypeIds == nil){
        OMHSchemaTypeIds = @[
                                      HKQuantityTypeIdentifierHeight,
                                      HKQuantityTypeIdentifierBodyMass,
                                      HKQuantityTypeIdentifierStepCount,
                                      HKQuantityTypeIdentifierHeartRate,
                                      HKQuantityTypeIdentifierBloodGlucose,
                                      HKQuantityTypeIdentifierActiveEnergyBurned,
                                      HKQuantityTypeIdentifierBodyMassIndex,
                                      HKQuantityTypeIdentifierOxygenSaturation,
                                      HKCategoryTypeIdentifierSleepAnalysis, //Samples with Asleep value use this serializer, samples with InBed value use generic category serializer
                                      HKCorrelationTypeIdentifierBloodPressure
                                      ];
    
    }
    return OMHSchemaTypeIds;
}

+ (NSArray*)supportedTypeIdentifiers {
    return [[OMHHealthKitConstantsMapper allSupportedTypeIdentifiersToClasses] allKeys];
}

+ (BOOL)canSerialize:(HKSample*)sample error:(NSError**)error {
    @throw [self unimplementedException];
}

- (id)initWithSample:(HKSample*)sample {
    self = [super init];
    if (self) {
        _sample = sample;
    } else {
        return nil;
    }
    return self;
}

/**
 Serializes HealthKit samples into Open mHealth compliant json data points.
 @param sample the HealthKit sample to be serialized
 @param error an NSError that is passed by reference and can be checked to identify specific errors
 @return a formatted json string containing the sample's data in a format that adheres to the appropriate Open mHealth schema
 */
- (NSString*)jsonForSample:(HKSample*)sample error:(NSError**)error {
    NSParameterAssert(sample);
    // first, verify we support the sample type
    NSArray* supportedTypeIdentifiers = [[self class] supportedTypeIdentifiers];
    NSString* sampleTypeIdentifier = sample.sampleType.identifier;
    NSString* serializerClassName;
    if ([supportedTypeIdentifiers includes:sampleTypeIdentifier]){
        serializerClassName = [OMHHealthKitConstantsMapper allSupportedTypeIdentifiersToClasses][sampleTypeIdentifier];
    }
    else{
        if (error) {
            NSString* errorMessage =
            [NSString stringWithFormat: @"Unsupported HKSample type: %@",
             sampleTypeIdentifier];
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeUnsupportedType
                                     userInfo: userInfo];
        }
        return nil;
    }
    // if we support it, select appropriate subclass for sample
    
    //For sleep analysis, the OMH schema does not capture an 'inBed' state, so if that value is set we need to use a generic category serializer
    //otherwise, it defaults to using the OMH schema for the 'asleep' state.
    if ([sampleTypeIdentifier isEqualToString:HKCategoryTypeIdentifierSleepAnalysis]){
        HKCategorySample* categorySample = (HKCategorySample*)sample;
        if(categorySample.value == 0){
            serializerClassName = @"OMHSerializerGenericCategorySample";
        }
    }
    Class serializerClass = NSClassFromString(serializerClassName);
    // subclass verifies it supports sample's values
    if (![serializerClass canSerialize:sample error:error]) {
        return nil;
    }
    // instantiate a serializer
    OMHSerializer* serializer = [[serializerClass alloc] initWithSample:sample];
    NSData* jsonData =
    [NSJSONSerialization dataWithJSONObject:[serializer data]
                                    options:NSJSONWritingPrettyPrinted
                                      error:error];
    if (!jsonData) {
        return nil; // return early if JSON serialization failed
    }
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString*)parseUnitFromQuantity:(HKQuantity*)quantity{
    NSString *quantityDescription = [quantity description];
    NSArray *array = [quantityDescription componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [array objectAtIndex:1];
}

+ (NSDictionary*) populateTimeFrameProperty:(NSDate*)startDate endDate:(NSDate*)endDate{
    if ([startDate isEqualToDate:endDate]){
        return @{
                 @"date_time":[startDate RFC3339String]
                 };
    }
    else{
        return  @{
                  @"time_interval": @{
                          @"start_date_time": [startDate RFC3339String],
                          @"end_date_time": [endDate RFC3339String]
                          }
                  };
    }
}

+ (NSDictionary*) serializeMetadataArray:(NSDictionary*)metadata{
    if(metadata){
        NSMutableArray *serializedArray = [NSMutableArray new];
        for (id key in metadata) {
            if ([[metadata valueForKey:key] isKindOfClass:[NSDate class]]){
                NSDate *dateMetadataValue = [metadata valueForKey:key];
                [serializedArray addObject:@{@"key":key,@"value":[dateMetadataValue RFC3339String]}];
            }
            else{
                [serializedArray addObject:@{@"key":key,@"value":[metadata valueForKey:key]}];
            }
            
        }
        return @{@"metadata":[serializedArray copy]};
    }
    return @{};
}

#pragma mark - Private

- (id)data {
    NSDictionary *serializedBodyDictionaryWithoutMetadata = [self bodyData];
    NSMutableDictionary *serializedBodyDictionaryWithMetadata = [NSMutableDictionary dictionaryWithDictionary:serializedBodyDictionaryWithoutMetadata];
    [serializedBodyDictionaryWithMetadata addEntriesFromDictionary:[OMHSerializer serializeMetadataArray:self.sample.metadata]];
    return @{
             @"header": @{
                     @"id": self.sample.UUID.UUIDString,
                     @"creation_date_time": [self.sample.startDate RFC3339String],
                     @"schema_id": @{
                             @"namespace": [self schemaNamespace],
                             @"name": [self schemaName],
                             @"version": [self schemaVersion]
                             },
                     },
             @"body":serializedBodyDictionaryWithMetadata
             };
    
}

- (NSString*)schemaName {
    @throw [[self class] unimplementedException];
}

- (NSString*)schemaVersion {
    @throw [[self class] unimplementedException];
}

- (id)bodyData {
    @throw [[self class] unimplementedException];
}

- (NSString*)schemaNamespace {
    @throw [[self class] unimplementedException];
}

+ (NSException*)unimplementedException {
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierStepCount type to the properties in the
 body of the Open mHealth step-count schema ( http://www.openmhealth.org/developers/schemas/#step-count ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierStepCount type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and step-count schemas.
 */
@interface OMHSerializerStepCount : OMHSerializer; @end;
@implementation OMHSerializerStepCount
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    HKUnit* unit = [HKUnit unitFromString:@"count"];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"step_count": [NSNumber numberWithDouble:value],
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"step-count";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierHeight type to the properties in the
 body of the Open mHealth body-height schema ( http://www.openmhealth.org/developers/schemas/#body-height ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierHeight type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and body-height schemas.
 */
@interface OMHSerializerHeight : OMHSerializer; @end;
@implementation OMHSerializerHeight
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    NSString* unitString = @"cm";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"body_height": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": unitString
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"body-height";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierBodyMass type to the properties in the
 body of the Open mHealth body-weight schema ( http://www.openmhealth.org/developers/schemas/#body-weight ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierBodyMass type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and body-weight schemas.
 */
@interface OMHSerializerWeight : OMHSerializer; @end;
@implementation OMHSerializerWeight
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    NSString* unitString = @"lb";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"body_weight": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": unitString
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"body-weight";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierHeartRate type to the properties in the
 body of the Open mHealth heart-rate schema ( http://www.openmhealth.org/developers/schemas/#heart-rate ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierHeartRate type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and heart-rate schemas.
 */
@interface OMHSerializerHeartRate : OMHSerializer; @end;
@implementation OMHSerializerHeartRate
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    HKUnit* unit = [HKUnit unitFromString:@"count/min"];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"heart_rate": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": @"beats/min"
                     },
             @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"heart-rate";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierBloodGlucose type to the properties in the
 body of the Open mHealth blood-glucose schema ( http://www.openmhealth.org/developers/schemas/#blood-glucose ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierBloodGlucose type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and blood-glucose schemas.
 */
@interface OMHSerializerBloodGlucose : OMHSerializer; @end;
@implementation OMHSerializerBloodGlucose
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    NSString* unitString = @"mg/dL";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"blood_glucose": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": unitString
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"blood-glucose";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample samples of the HKQuantityTypeIdentifierActiveEnergyBurned type to the properties in the
 body of the Open mHealth calories-burned schema ( http://www.openmhealth.org/developers/schemas/#calories-burned ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierActiveEnergyBurned type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and calories-burned schemas.
 */
@interface OMHSerializerEnergyBurned : OMHSerializer; @end;
@implementation OMHSerializerEnergyBurned
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    NSString* unitString = @"kcal";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    double value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"kcal_burned": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": unitString
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             
             };
}
- (NSString*)schemaName {
    return @"calories-burned";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 
 */
@interface OMHSerializerOxygenSaturation : OMHSerializer; @end;
@implementation OMHSerializerOxygenSaturation
+ (BOOL)canSerialize:(HKQuantitySample*)sample error:(NSError**)error {
    return YES;
}
- (id)bodyData {
    NSString* unitString = @"%";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    float value =
    [[(HKQuantitySample*)self.sample quantity] doubleValueForUnit:unit];
    return @{
             @"oxygen_saturation": @{
                     @"value": [NSNumber numberWithDouble:value],
                     @"unit": unitString
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             
             };
}
- (NSString*)schemaName {
    return @"oxygen-saturation";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKCategory samples of the HKCategoryValueSleepAnalysis type with the value HKCategoryValueSleepAnalysisAsleep
 to the properties in the body of the Open mHealth sleep-duration schema ( http://www.openmhealth.org/developers/schemas/#sleep-duration ). This
 serialization mapper is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKCategoryValueSleepAnalysis
 type sample, which constructs the full json data point that adheres to the Open mHealth data-point and sleep-duration schemas. HKCategoryValueSleepAnalysis
 samples with the value, HKCategoryValueSleepAnalysisInBed, will be mapped using OMHSerializerGenericCategorySample.
 */
@interface OMHSerializerSleepAnalysis : OMHSerializer; @end;
@implementation OMHSerializerSleepAnalysis
+ (BOOL)canSerialize:(HKCategorySample*)sample error:(NSError**)error {
    if (sample.value == HKCategoryValueSleepAnalysisAsleep) return YES;
    if (error) {
        NSString* errorMessage =
        @"HKCategoryValueSleepAnalysis value HKCategoryValueSleepAnalysisInBed uses OMHSerializerGenericCategorySample";
        NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
        *error = [NSError errorWithDomain: OMHErrorDomain
                                     code: OMHErrorCodeUnsupportedValues
                                 userInfo: userInfo];
    }
    return NO;
}
- (id)bodyData {
    id value =
    [NSNumber numberWithFloat:
     [self.sample.endDate timeIntervalSinceDate:self.sample.startDate]];
    return @{
             @"sleep_duration": @{
                     @"value": value,
                     @"unit": @"sec"
                     },
             @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"sleep-duration";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKCorrelation samples of the HKCorrelationTypeIdentifierBloodPressure type to the properties in the
 body of the Open mHealth blood-pressure schema ( http://www.openmhealth.org/developers/schemas/#blood-pressure ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKCorrelationTypeIdentifierBloodPressure type sample,
 which constructs the full json data point that adheres to the Open mHealth data-point and blood-pressure schemas.
 */
@interface OMHSerializerBloodPressure : OMHSerializer; @end;
@implementation OMHSerializerBloodPressure
+ (BOOL)canSerialize:(HKCorrelation*)sample error:(NSError**)error {
    NSSet* samples = sample.objects;
    HKSample* (^firstSampleOfType)(NSString* typeIdentifier) =
    ^HKSample*(NSString* typeIdentifier){
        return [[samples select:^BOOL(HKSample* sample) {
            return [[sample sampleType].identifier isEqual:typeIdentifier];
        }] firstObject];
    };
    HKSample* systolicSample =
    firstSampleOfType(HKQuantityTypeIdentifierBloodPressureSystolic);
    HKSample* diastolicSample =
    firstSampleOfType(HKQuantityTypeIdentifierBloodPressureDiastolic);
    if (systolicSample && diastolicSample) return YES;
    if (error) {
        NSString* errorMessage = @"Missing Diastolic or Systolic sample";
        NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
        *error = [NSError errorWithDomain: OMHErrorDomain
                                     code: OMHErrorCodeUnsupportedValues
                                 userInfo: userInfo];
    }
    return NO;
}
- (id)bodyData {
    NSString* unitString = @"mmHg";
    HKUnit* unit = [HKUnit unitFromString:unitString];
    HKCorrelation* sample = (HKCorrelation*)self.sample;
    double (^valueForFirstSampleOfType)(NSString* typeIdentifier) =
    ^(NSString* typeIdentifier) {
        HKQuantitySample* found =
        [[sample.objects select:^BOOL(HKSample* sample) {
            return [[sample sampleType].identifier isEqual:typeIdentifier];
        }] firstObject];
        return [found.quantity doubleValueForUnit:unit];
    };
    double systolicValue =
    valueForFirstSampleOfType(HKQuantityTypeIdentifierBloodPressureSystolic);
    double diastolicValue =
    valueForFirstSampleOfType(HKQuantityTypeIdentifierBloodPressureDiastolic);
    return @{
             @"systolic_blood_pressure": @{
                     @"unit": unitString,
                     @"value": [NSNumber numberWithDouble: systolicValue]
                     },
             @"diastolic_blood_pressure": @{
                     @"unit": unitString,
                     @"value": [NSNumber numberWithDouble: diastolicValue]
                     },
             @"effective_time_frame": [OMHSerializer populateTimeFrameProperty:self.sample.startDate endDate:self.sample.endDate]
             };
}
- (NSString*)schemaName {
    return @"blood-pressure";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySamples of the HKQuantityTypeIdentifierBodyMassIndex type to the properties in the
 body of the Open mHealth body-mass-index schema ( http://www.openmhealth.org/developers/schemas/#body-mass-index ). This serialization mapper  
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantityTypeIdentifierBodyMassIndex type sample, 
 which constructs the full json data point that adheres to the Open mHealth data-point and body-mass-index schemas.
 */
@interface OMHSerializerBodyMassIndex : OMHSerializer; @end;
@implementation OMHSerializerBodyMassIndex

+ (BOOL)canSerialize:(HKSample *)sample error:(NSError *__autoreleasing *)error {
    if ([sample.sampleType.description isEqualToString:HKQuantityTypeIdentifierBodyMassIndex]){
        return YES;
    }
    return NO;
}
- (id)bodyData {
    HKUnit *unit = [HKUnit unitFromString:@"count"];
    HKQuantitySample *quantitySample = (HKQuantitySample*)self.sample;
    double value = [[quantitySample quantity] doubleValueForUnit:unit];
    
    return @{
             @"body_mass_index": @{
                     @"value":[NSNumber numberWithDouble:value],
                     @"unit":@"kg/m2"
                     },
             @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:quantitySample.startDate endDate:quantitySample.endDate]
             };
    
}
- (NSString*)schemaName {
    return @"body-mass-index";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"omh";
}
@end

/**
 Serializer component to map data from HKQuantitySample to the properties in the body of the Open mHealth hk-quantity-sample schema
 ( https://github.com/openmhealth/schemas/blob/feature/health-kit/schema/granola/hk-quantity-type-1.0.json ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKQuantitySample, which constructs the full
 json data point that adheres to the Open mHealth data-point and hk-quantity-sample schemas.
 */
@interface OMHSerializerGenericQuantitySample : OMHSerializer; @end;
@implementation OMHSerializerGenericQuantitySample

+ (BOOL)canSerialize:(HKSample *)sample error:(NSError *__autoreleasing *)error {
    @try{
        HKQuantitySample *quantitySample = (HKQuantitySample*)sample;
        if([[quantitySample.quantityType description] containsString:@"HKQuantityType"]){
            return YES;
        }
        if (error) {
            NSString* errorMessage =
            @"HKQuantitySamples should have a quantity type that begins with 'HKQuantityType'";
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeIncorrectType
                                     userInfo: userInfo];
        }
        return NO;
    }
    @catch (NSException *exception) {
        if (error) {
            NSString* errorMessage =
            @"OMHSerializerGenericQuantitySample is used for HKQuantitySamples only";
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeUnsupportedValues
                                     userInfo: userInfo];
        }
        return NO;
    }
}
- (id)bodyData {
    HKQuantitySample *quantitySample = (HKQuantitySample*)self.sample;
    HKQuantity *quantity = [quantitySample quantity];
    NSMutableDictionary *serializedUnitValues = [NSMutableDictionary new];
    if ([quantity isCompatibleWithUnit:[HKUnit unitFromString:@"count"]]) {
        [serializedUnitValues addEntriesFromDictionary:@{
                                                         @"count": [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit unitFromString:@"count"]]]
                                                         }
         ];
    }
    else{
        NSString *unitString = [OMHSerializer parseUnitFromQuantity:quantity];
        [serializedUnitValues addEntriesFromDictionary:@{
                                                         @"unit_value":@{
                                                                 @"value": [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit unitFromString:unitString]]],
                                                                 @"unit": unitString
                                                                 
                                                                 }
                                                         }
         ];
    }
    
    NSDictionary *partialSerializedDictionary =
    @{
      @"quantity_type":[[quantitySample quantityType] description] ,
      @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:quantitySample.startDate endDate:quantitySample.endDate]
      } ;
    NSMutableDictionary *fullSerializedDictionary = [partialSerializedDictionary mutableCopy];
    [fullSerializedDictionary addEntriesFromDictionary:serializedUnitValues];
    return fullSerializedDictionary;
}
- (NSString*)schemaName {
    return @"hk-quantity-sample";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"granola";
}
@end

/**
 Serializer component to map data from HKCategorySamples to the properties in the body of the Open mHealth hk-category-sample schema
 ( https://github.com/openmhealth/schemas/blob/feature/health-kit/schema/granola/hk-category-sample-1.0.json ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKCategorySample, which constructs the full
 json data point that adheres to the Open mHealth data-point and hk-category-sample schemas.
 */
@interface OMHSerializerGenericCategorySample : OMHSerializer; @end;
@implementation OMHSerializerGenericCategorySample

+ (BOOL)canSerialize:(HKSample *)sample error:(NSError *__autoreleasing *)error {
    BOOL canSerialize = YES;
    @try{
        HKCategorySample *categorySample = (HKCategorySample*) sample;
        NSArray* categoryTypes = [[OMHHealthKitConstantsMapper allSupportedCategoryTypeIdentifiersToClasses] allKeys];
        if(![categoryTypes containsObject:categorySample.categoryType.description]){
            if (error) {
                NSString* errorMessage = @"The category type is not currently supported.";
                NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
                *error = [NSError errorWithDomain: OMHErrorDomain
                                             code: OMHErrorCodeUnsupportedType
                                         userInfo: userInfo];
            }
            canSerialize = NO;
        }
        
        return canSerialize;
    }
    @catch(NSException *exception){
        if (error) {
            NSString* errorMessage =
            @"OMHSerializerGenericCategorySample is used for HKCategorySamples only";
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeIncorrectType
                                     userInfo: userInfo];
        }
        return NO;
    }
}

- (id)bodyData {
    HKCategorySample *categorySample = (HKCategorySample*) self.sample;
    
    //Error checking for correct types is done in the canSerialize method.
    NSString *schemaMappedValue = [self getCategoryValueForTypeWithValue:categorySample.categoryType categoryValue:categorySample.value];
    
    return @{
             @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:categorySample.startDate endDate:categorySample.endDate],
             @"category_type": [[categorySample categoryType] description],
             @"category_value": schemaMappedValue
             };
}

- (NSString*)getCategoryValueForTypeWithValue: (HKCategoryType*) categoryType categoryValue:(NSInteger)categoryValue {
    
    if ( [categoryType.description isEqualToString:HKCategoryTypeIdentifierAppleStandHour.description] ) {
        return [OMHHealthKitConstantsMapper stringForHKAppleStandHourValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierSleepAnalysis.description]) {
        return [OMHHealthKitConstantsMapper stringForHKSleepAnalysisValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierCervicalMucusQuality.description]) {
        return [OMHHealthKitConstantsMapper stringForHKCervicalMucusQualityValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierIntermenstrualBleeding]) {
        // Samples of this type represent the presence of intermenstrual bleeding and as such does not have a categorical value. HealthKit specifies that the value field for this type is "HKCategoryValueNotApplicable" which is a nonsensical value, so we use the name of the represented measure as the value.
        return @"Intermenstrual bleeding";
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierMenstrualFlow]) {
        return [OMHHealthKitConstantsMapper stringForHKMenstrualFlowQualityValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierOvulationTestResult]) {
        return [OMHHealthKitConstantsMapper stringForHKOvulationTestResultValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierSexualActivity]) {
        // Samples of this type represent times during which sexual activity occurred. This means that during the time frame of each sample, sexual activity was occurring. As such, this measure does not have a categorical value. HealthKit specifies that the value field for this type is "HKCategoryValueNotApplicable" which is a nonsensical value, so we use the name of the represented measure as the value.
        return @"Sexual activity";
    }
    else{
        NSException *e = [NSException
                          exceptionWithName:@"InvalidHKCategoryType"
                          reason:@"Incorrect category type parameter for method."
                          userInfo:nil];
        @throw e;
    }
    
}

- (NSString*)schemaName {
    return @"hk-category-sample";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"granola";
}
@end

/**
 Serializer component to map data from HKCorrelation to the properties in the body of the Open mHealth hk-correlation schema
 ( https://github.com/openmhealth/schemas/blob/feature/health-kit/schema/granola/hk-correlation-1.0.json ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKCorrelation sample, which constructs the full
 json data point that adheres to the Open mHealth data-point and hk-correlation schemas.
 */
@interface OMHSerializerGenericCorrelation : OMHSerializer; @end;
@implementation OMHSerializerGenericCorrelation

+ (BOOL)canSerialize:(HKSample *)sample error:(NSError *__autoreleasing *)error {
    @try {
        HKCorrelation *correlationSample = (HKCorrelation*)sample;
        if(![correlationSample.correlationType.description isEqualToString:HKCorrelationTypeIdentifierBloodPressure] &&
           ![correlationSample.correlationType.description isEqualToString:HKCorrelationTypeIdentifierFood]){
            
            if (error) {
                NSString* errorMessage =
                [NSString stringWithFormat:@"%@ is not a supported correlation type in HealthKit",correlationSample.correlationType.description];
                NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
                *error = [NSError errorWithDomain: OMHErrorDomain
                                             code: OMHErrorCodeUnsupportedValues
                                         userInfo: userInfo];
            }
            
            return NO;
        }
        
    }
    @catch (NSException *exception){
        if (error) {
            NSString* errorMessage =
            @"OMHSerializerGenericCorrelation is used for HKCorrelation samples only";
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeIncorrectType
                                     userInfo: userInfo];
        }
        return NO;
    }
    return YES;
    
}
- (id)bodyData {
    HKCorrelation *correlationSample = (HKCorrelation*)self.sample;
    
    NSMutableArray *quantitySampleArray = [NSMutableArray new];
    NSMutableArray *categorySampleArray = [NSMutableArray new];
    for (NSObject *sample in correlationSample.objects) {
        if ([sample isKindOfClass:[HKQuantitySample class]]){
            //create serialized with the sample input, then call body
            OMHSerializerGenericQuantitySample *quantitySampleSerializer = [OMHSerializerGenericQuantitySample new];
            quantitySampleSerializer = [quantitySampleSerializer initWithSample:(HKQuantitySample*)sample];
            NSError *error = nil;
            if([OMHSerializerGenericQuantitySample canSerialize:(HKSample*)sample error:&error]){
                NSDictionary *serializedQuantitySample = (NSDictionary*)[quantitySampleSerializer bodyData];
                [quantitySampleArray addObject:serializedQuantitySample];
            }
            else{
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        else if ([sample isKindOfClass:[HKCategorySample class]]){
            OMHSerializerGenericCategorySample *categorySampleSerializer = [OMHSerializerGenericCategorySample new];
            categorySampleSerializer = [categorySampleSerializer initWithSample:(HKCategorySample*)sample];
            NSError *error = nil;
            if([OMHSerializerGenericCategorySample canSerialize:(HKSample*)sample error:&error]){
                NSDictionary *serializedCategorySample = (NSDictionary*)[categorySampleSerializer bodyData];
                [quantitySampleArray addObject:serializedCategorySample];
            }
            else{
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        else {
            NSException *e = [NSException
                              exceptionWithName:@"CorrelationContainsInvalidSample"
                              reason:@"HKCorrelation can only contain samples of type HKQuantitySample or HKCategorySample"
                              userInfo:nil];
            @throw e;
        }
    }
    
    return @{@"effective_time_frame":[OMHSerializer populateTimeFrameProperty:correlationSample.startDate endDate:correlationSample.endDate],
             @"correlation_type":[correlationSample.correlationType description],
             @"quantity_samples":quantitySampleArray,
             @"category_samples":categorySampleArray
             };
}
- (NSString*)schemaName {
    return @"hk-correlation";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"granola";
}
@end

/**
 Serializer component to map data from HKWorkout to the properties in the body of the Open mHealth hk-workout schema
 ( https://github.com/openmhealth/schemas/blob/feature/health-kit/schema/granola/hk-workout-1.0.json ). This serialization mapper
 is instantiated during [OMHSerializer jsonForSample:(*HKSample) error:(HKError)] using a HKWorkout sample, which constructs the full
 json data point that adheres to the Open mHealth data-point and hk-workout schemas.
 */
@interface OMHSerializerGenericWorkout : OMHSerializer; @end
@implementation OMHSerializerGenericWorkout

+ (BOOL)canSerialize:(HKSample *)sample error:(NSError *__autoreleasing *)error {
    if([sample isKindOfClass:[HKWorkout class]]){
        return YES;
    }
    else{
        if (error) {
            NSString* errorMessage =
            @"OMHSerializerGenericWorkout is used for HKWorkout samples only";
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
            *error = [NSError errorWithDomain: OMHErrorDomain
                                         code: OMHErrorCodeIncorrectType
                                     userInfo: userInfo];
        }
        return NO;
    }
    
}

- (id)bodyData {
    HKWorkout *workoutSample = (HKWorkout*)self.sample;
    
    NSMutableDictionary *fullSerializedDictionary = [NSMutableDictionary new];
    if(workoutSample.totalDistance){
        NSString *unitString = [OMHSerializer parseUnitFromQuantity:workoutSample.totalDistance];
        [fullSerializedDictionary setObject:@{@"value":[NSNumber numberWithDouble:[workoutSample.totalDistance doubleValueForUnit:[HKUnit unitFromString:unitString]]],@"unit":unitString} forKey:@"distance"];
    }
    if(workoutSample.totalEnergyBurned){
        [fullSerializedDictionary setObject:@{@"value":[NSNumber numberWithDouble:[workoutSample.totalEnergyBurned doubleValueForUnit:[HKUnit unitFromString:@"kcal"]]],@"unit":@"kcal"} forKey:@"kcal_burned"];
    }
    if(workoutSample.duration){
        [fullSerializedDictionary setObject:@{@"value":[NSNumber numberWithDouble:workoutSample.duration],@"unit":@"sec"} forKey:@"duration"];
    }
    
    [fullSerializedDictionary addEntriesFromDictionary:@{
                                                         @"effective_time_frame":[OMHSerializer populateTimeFrameProperty:workoutSample.startDate endDate:workoutSample.endDate],
                                                         @"activity_name":[OMHHealthKitConstantsMapper stringForHKWorkoutActivityType:workoutSample.workoutActivityType]
                                                         
                                                         }];
    return fullSerializedDictionary;
}

- (NSString*)schemaName {
    return @"hk-workout";
}
- (NSString*)schemaVersion {
    return @"1.0";
}
- (NSString*)schemaNamespace{
    return @"granola";
}
@end

