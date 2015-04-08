#import <Foundation/Foundation.h>
@import HealthKit;

@interface OMHSampleFactory : NSObject
+ (HKSample*)typeIdentifier:(NSString*)typeIdentifier attrs:(NSDictionary*)attrs;
+ (HKSample*)typeIdentifier:(NSString*)typeIdentifier;
@end

