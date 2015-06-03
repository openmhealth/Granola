#import <Foundation/Foundation.h>
@import HealthKit;
#import "OMHError.h"

@interface OMHSerializer : NSObject

+ (NSArray*)typeIdentifiersWithOMHSchema;

- (NSString*)jsonForSample:(HKSample*)sample error:(NSError**)error;

@end

