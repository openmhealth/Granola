//
//  OMHWorkoutEnumMap.m
//  Pods
//
//  Created by Christopher Schaefbauer on 5/28/15.
//
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "OMHWorkoutEnumMap.h"

@implementation OMHWorkoutEnumMap
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
@end

