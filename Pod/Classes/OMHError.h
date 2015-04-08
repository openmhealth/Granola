#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const OMHErrorDomain;

typedef NS_ENUM(NSInteger, OMHErrorCode) {
  OMHErrorCodeUnsupportedType = 1000,
  OMHErrorCodeUnsupportedValues = 1001,
};

