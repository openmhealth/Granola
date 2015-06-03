//
//  OMHHealthKitEnumMaps.h
//  Pods
//
//  Created by Christopher Schaefbauer on 5/28/15.
//
//

@interface OMHHealthKitConstantsMapper : NSObject

+ (NSString*) stringForHKWorkoutActivityType:(int) enumValue;
+ (NSString*) stringForHKSleepAnalysisValue:(int) enumValue;
+ (NSDictionary*) dictionaryForTypeIdentifiersToClasses;
@end

