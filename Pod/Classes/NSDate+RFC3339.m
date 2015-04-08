#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)

- (NSString *)RFC3339String {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:locale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z"];
  return [dateFormatter stringFromDate:self];
}

@end
