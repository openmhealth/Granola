#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)

+ (NSDateFormatter*)RFC3339Formatter {
  static NSDateFormatter* formatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    formatter = [[NSDateFormatter alloc] init];
    NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z"];
  });
  return formatter;
}

- (NSString *)RFC3339String {
  return [[[self class] RFC3339Formatter] stringFromDate:self];
}

+ (NSDate*)fromRFC3339String:(NSString*)dateString {
  return [[self RFC3339Formatter] dateFromString:dateString];
}

@end

