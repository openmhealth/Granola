#import <Foundation/Foundation.h>
@import HealthKit;
#import "OMHError.h"

@interface OMHSerializer : NSObject

+ (NSArray*)supportedTypeIdentifiers;

+ (id)forSample:(HKSample*)sample error:(NSError**)error;
- (id)initWithSample:(HKSample*)sample;

- (NSString*)jsonOrError:(NSError**)serializationError;

@end

