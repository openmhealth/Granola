#import <Foundation/Foundation.h>

@interface NSDate (RFC3339)

- (NSString *)RFC3339String;

+ (NSDate*)fromRFC3339String:(NSString*)dateString;

@end

