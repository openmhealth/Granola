#import <Foundation/Foundation.h>
@import HealthKit;

@interface HKObject (Private)

// source:
// https://github.com/nst/iOS-Runtime-Headers/blob/e578efc846bd46a2d24a4fdd033cdc582323ccec/Frameworks/HealthKit.framework/HKObject.h#L55
- (BOOL)validateForSaving:(id*)arg1;

@end
