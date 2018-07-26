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

#import "OMHSerializer.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "OMHHealthKitConstantsMapper.h"

@interface OMHSerializer()
@property (nonatomic, retain) HKSample* sample;
+ (BOOL)canSerialize:(HKSample*)sample error:(NSError**)error;
+ (NSException*)unimplementedException;
@end


@implementation OMHSerializer

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
 Serializes HealthKit samples into Open mHealth compliant JSON data points.
 @param sample the HealthKit sample to be serialized
 @param error an NSError that is passed by reference and can be checked to identify specific errors
 @return a formatted JSON string containing the sample's data in a format that adheres to the appropriate Open mHealth schema
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
            [NSString stringWithFormat: @"Unsupported HKSample type: %@", sampleTypeIdentifier];
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
        if(categorySample.value == HKCategoryValueSleepAnalysisInBed){
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
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[serializer data]
                                    options:NSJSONWritingPrettyPrinted
                                      error:error];
    if (!jsonData) {
        return nil; // return early if JSON serialization failed
    }
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString*)parseUnitFromQuantity:(HKQuantity*)quantity {
    NSArray *arrayWithSplitUnitAndValue = [quantity.description
                                           componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                                 whitespaceCharacterSet]];
    return arrayWithSplitUnitAndValue[1];
}

- (NSDictionary*) populateTimeFrameProperty:(NSDate*)startDate endDate:(NSDate*)endDate {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSZ";
    
    return  @{
              @"time_interval": @{
                      @"start_date_time": [df stringFromDate:startDate],
                      @"end_date_time": [df stringFromDate:endDate]
                      }
              };
}

+ (NSDictionary*) serializeMetadataArray:(NSDictionary*)metadata {
    if(metadata) {
        NSMutableArray *serializedArray = [NSMutableArray new];
        for (id key in metadata) {
            if ([[metadata valueForKey:key] isKindOfClass:[NSDate class]]){
                NSDate *dateMetadataValue = [metadata valueForKey:key];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSZ";
                [serializedArray addObject:@{@"key":key,@"value":[df stringFromDate:dateMetadataValue]}];
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
 This serializer maps data from HKQuantitySamples to JSON that conforms to the generic, Granola-specific [hk-quantity-sample schema](http://www.openmhealth.org/documentation/#/schema-docs/schema-library/schemas/granola_hk-quantity-sample). 
 
 This serializer is used for all quantity types that are not supported by Open mHealth curated schemas. The [supportedTypeIdentifiersWithOMHSchema]([OMHSerializer supportedTypeIdentifiersWithOMHSchema]) method provides a list of schemas that _are_ supported by Open mHealth curated schemas.
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
    
    if ([[OMHSerializer parseUnitFromQuantity:quantity] isEqualToString:@"%"]) {
        
        // Types that use "%" units are compatible with the "count" unit (in the next condition), so this condition to pre-empts that.
        NSNumber* value = [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit percentUnit]]];
        
        [serializedUnitValues addEntriesFromDictionary:@{
                                                         @"unit_value":@{
                                                                 @"value": @([value floatValue] * 100),
                                                                 @"unit": @"%"
                                                                 }
                                                         }
         ];
    }
    else if ([quantity isCompatibleWithUnit:[HKUnit unitFromString:@"count"]]) {
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
    
    NSString *deviceName = @"";
    if (self.sample.device && self.sample.device.name){
        deviceName = self.sample.device.name;
    }
    
    NSDictionary *partialSerializedDictionary =
    @{
      @"quantity_type":[quantitySample quantityType].description,
      @"effective_time_frame":[self populateTimeFrameProperty:quantitySample.startDate endDate:quantitySample.endDate],
      @"id": self.sample.UUID.UUIDString,
      @"device": deviceName
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
    
    NSString *deviceName = @"";
    if (self.sample.device && self.sample.device.name){
        deviceName = self.sample.device.name;
    }
    
    return @{
             @"effective_time_frame":[self populateTimeFrameProperty:categorySample.startDate endDate:categorySample.endDate],
             @"category_type": [categorySample categoryType].description,
             @"category_value": schemaMappedValue,
             @"id": self.sample.UUID.UUIDString,
             @"device": deviceName
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
        /*  Samples of this type represent the presence of intermenstrual bleeding and as such does not have a categorical value. HealthKit
            specifies that the value field for this type is "HKCategoryValueNotApplicable" which is a nonsensical value, so we use the name 
            of the represented measure as the value. */
        return @"Intermenstrual bleeding";
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierMenstrualFlow]) {
        return [OMHHealthKitConstantsMapper stringForHKMenstrualFlowValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierOvulationTestResult]) {
        return [OMHHealthKitConstantsMapper stringForHKOvulationTestResultValue:(int)categoryValue];
    }
    else if ([categoryType.description isEqualToString:HKCategoryTypeIdentifierSexualActivity]) {
        /*  Samples of this type represent times during which sexual activity occurred. This means that during the time frame of each 
            sample, sexual activity was occurring. As such, this measure does not have a categorical value. HealthKit specifies that the 
            value field for this type is "HKCategoryValueNotApplicable" which is a nonsensical value, so we use the name of the represented 
            measure as the value. */
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
 This serializer maps data from HKCorrelation samples to JSON that conforms to the generic, Granola-specific [hk-correlation schema](http://www.openmhealth.org/documentation/#/schema-docs/schema-library/schemas/granola_hk-correlation).
 
 This serializer is used for all quantity types that are not supported by Open mHealth curated schemas. The [supportedTypeIdentifiersWithOMHSchema]([OMHSerializer supportedTypeIdentifiersWithOMHSchema]) method provides a list of schemas that _are_ supported by Open mHealth curated schemas.
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
    
    return @{@"effective_time_frame":[self populateTimeFrameProperty:correlationSample.startDate endDate:correlationSample.endDate],
             @"correlation_type":correlationSample.correlationType.description,
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
 This serializer maps data from HKWorkout samples to JSON that conforms to the generic, Granola-specific [hk-workout schema](http://www.openmhealth.org/documentation/#/schema-docs/schema-library/schemas/granola_hk-workout).
 
 This serializer is used for all quantity types that are not supported by Open mHealth curated schemas. The [supportedTypeIdentifiersWithOMHSchema]([OMHSerializer supportedTypeIdentifiersWithOMHSchema]) method provides a list of schemas that _are_ supported by Open mHealth curated schemas.
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
                                                         @"effective_time_frame":[self populateTimeFrameProperty:workoutSample.startDate endDate:workoutSample.endDate],
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

