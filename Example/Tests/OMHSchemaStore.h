#import <Foundation/Foundation.h>

@interface OMHSchemaStore : NSObject
+ (BOOL)validateObject:(id)object
   againstSchemaAtPath:(NSString*)path
             withError:(NSError**)validationError;
+ (NSArray*) schemaPartialPaths;

@end

