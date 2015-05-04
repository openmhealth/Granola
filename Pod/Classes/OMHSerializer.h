#import <Foundation/Foundation.h>
@import HealthKit;
#import "OMHError.h"

@interface OMHSerializer : NSObject

+ (NSArray*)supportedTypeIdentifiers;

- (NSString*)jsonForSample:(HKSample*)sample error:(NSError**)error;

@end

