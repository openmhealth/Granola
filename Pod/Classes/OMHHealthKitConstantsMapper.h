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

/**
 Provides mappings between HealthKit domain constants and Open mHealth representations. This includes mappings from sample values that are represented by constants in HealthKit (e.g., workout activities and category values) and mappings from HealthKit sample types to the appropriate JSON serializer.
 */
@interface OMHHealthKitConstantsMapper : NSObject

/**
 Translates `HKWorkoutActivityType` constants into more semantically meaningful string representations.
 
 Used in generating values for workout types in serializing `HKWorkout` objects to JSON.

 @param enumValue The numeric value from the `HKWorkoutActivityType` enum.
 
 @return A string representation of the constant.
 
 @see [HKWorkoutActivityType](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKWorkoutActivityType)
 @see [HKWorkout](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKWorkout_Class/index.html)
 */
+ (NSString*) stringForHKWorkoutActivityType:(int) enumValue;

/**
 Translates `HKCategoryValueSleepAnalysis` constants into more semantically meaningful string representations.
 
 Used in generating values for sleep analysis in serializing samples of `HKCategoryValueSleepAnalysis` type, with the value _inBed_, into JSON.
 
 @param enumValue The numeric value from the `HKCategoryValueSleepAnalysis` enum.
 
 @return A string representation of the constant.
 
 @see [HKCategoryValueSleepAnalysis](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueSleepAnalysis)
 @see [HKCategorySample](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKCategorySample_Class/index.html)
 */
+ (NSString*) stringForHKSleepAnalysisValue:(int) enumValue;

/**
 Translates `HKCategoryValueAppleStandHour` constants into more semantically meaningful string representations.
 
 @param enumValue The numeric value from the `HKCategoryValueAppleStandHour` enum.
 
 @return A string representation of the constant.
 
 @see [HKCategoryValueAppleStandHour](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueAppleStandHour)
 @see [HKCategorySample](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKCategorySample_Class/index.html)
 */
+ (NSString*) stringForHKAppleStandHourValue:(int) enumValue;

 /**
 Translates `HKCategoryValueCervicalMucusQuality` constants into more semantically meaningful string representations.
 
 @param enumValue The numeric value from the `HKCategoryValueCervicalMucusQuality` enum.
 
 @return A string representation of the constant.
 
 @see [HKCategoryValueCervicalMucusQuality](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueCervicalMucusQuality)
 @see [HKCategorySample](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKCategorySample_Class/index.html)
 */
+ (NSString*) stringForHKCervicalMucusQualityValue:(int) enumValue;


/**
 Translates `HKCategoryValueMenstrualFlow` constants into more semantically meaningful string representations.
 
 @param enumValue The numeric value from the `HKCategoryValueMenstrualFlow` enum.
 
 @return A string representation of the constant.
 
 @see [HKCategoryValueMenstrualFlow](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueMenstrualFlow)
 @see [HKCategorySample](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKCategorySample_Class/index.html)
 */
+ (NSString*) stringForHKMenstrualFlowValue:(int) enumValue;

/**
 Translates `HKCategoryValueOvulationTestResult` constant values into more semantically meaningful string representations.
 
 @param enumValue The constant value from the `HKCategoryValueOvulationTestResult` enum.
 
 @return A string representation of the constant.
 
 @see [HKCategoryValueOvulationTestResult](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueOvulationTestResult)
 @see [HKCategorySample](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HKCategorySample_Class/index.html)
 */
+ (NSString*) stringForHKOvulationTestResultValue:(int) enumValue;

/**
 Describes the mappings between all HealthKit type identifiers suppported by Granola and the specific serializer class used by Granola to serialize samples of that type into JSON. The type identifiers are keys in the dictionary with their corresponding serializer class name as the value.
 
 This dictionary is an aggregation of all the type-specific dictionaries returned by allSupportedCategoryTypeIdentifiersToClasses, allSupportedCorrelationTypeIdentifiersToClass, and allSupportedQuantityTypeIdentifiersToClass, along with the HKWorkout type identifier and its associated serializer class.
 
 @return A dictionary containing tuples of the HealthKit types supported by Granola with the name of the serializer class they use.
 
 @see allSupportedCategoryTypeIdentifiersToClasses
 @see allSupportedCorrelationTypeIdentifiersToClass
 @see allSupportedQuantityTypeIdentifiersToClass
 */
+ (NSDictionary*) allSupportedTypeIdentifiersToClasses;

/**
 Describes the mappings between HealthKit category type identifiers suppported by Granola and the specific serializer class used by Granola to serialize samples of that type into JSON. The type identifiers are keys in the dictionary with their corresponding serializer class name as the value.
 
 @return A dictionary containing tuples of the HealthKit category types supported by Granola with the name of the serializer class they use.
 */
+ (NSDictionary*) allSupportedCategoryTypeIdentifiersToClasses;

/**
 Describes the mappings between HealthKit correlation type identifiers suppported by Granola and the specific serializer class used by Granola to serialize samples of that type into JSON. The type identifiers are keys in the dictionary with their corresponding serializer class name as the value.
 
 @return A dictionary containing tuples of the HealthKit correlation types supported by Granola with the name of the serializer class they use.
 */
+ (NSDictionary*) allSupportedCorrelationTypeIdentifiersToClass;

/**
 Describes the mappings between HealthKit quantity type identifiers suppported by Granola and the specific serializer class used by Granola to serialize samples of that type into JSON. The type identifiers are keys in the dictionary with their corresponding serializer class name as the value.
 
 @return A dictionary containing tuples of the HealthKit quantity types supported by Granola with the name of the serializer class they use.
 */
+ (NSDictionary*) allSupportedQuantityTypeIdentifiersToClass;

@end

