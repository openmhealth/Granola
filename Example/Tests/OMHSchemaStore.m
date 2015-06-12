#import "OMHSchemaStore.h"
#import <VVJSONSchemaValidation/VVJSONSchema.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface OMHSchemaStore()
@property (nonatomic, retain) VVMutableJSONSchemaStorage* storage;
@end

@implementation OMHSchemaStore

+ (BOOL)validateObject:(id)object
   againstSchemaAtPath:(NSString*)path
             withError:(NSError**)validationError {
  VVJSONSchema* schema = [[self sharedStore] schemaForPartialPath:path];
  return [schema validateObject:object withError:validationError];
}

#pragma mark - Private

+ (id)sharedStore {
  static OMHSchemaStore *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
    if (shared) [shared loadSchemas];
  });
  return shared;
}

- (void)loadSchemas {
  _storage = [VVMutableJSONSchemaStorage storage];
  [@[
     @"omh/schema-id",
     @"omh/date-time",
     @"omh/unit-value",
     @"omh/duration-unit-value",
     @"omh/part-of-day",
     @"omh/time-interval",
     @"omh/time-frame",
     @"omh/header",
     @"omh/data-point",
     @"omh/step-count"
  ] each:^(NSString* partialPath) {
    NSURL* schemaURI = [self schemaURIForPartialPath:partialPath];
    // add schema at URI
    NSError *error = nil;
    VVJSONSchema* schema =
      [VVJSONSchema schemaWithData:[NSData dataWithContentsOfURL:schemaURI]
                           baseURI:schemaURI
                  referenceStorage:_storage
                             error:&error];
    NSAssert(schema,
        @"Failed to create schema: %@, error: %@", schemaURI, error);
    NSAssert([_storage addSchema:schema],
        @"Failed to add schema to storage: %@", schemaURI);
  }];
}

- (VVJSONSchema*)schemaForPartialPath:(NSString*)path {
  NSURL* schemaURI = [self schemaURIForPartialPath:path];
  return [_storage schemaForURI:schemaURI];
}

- (NSURL*)schemaURIForPartialPath:(NSString*)path {
  NSArray* components = [path componentsSeparatedByString:@"/"];
  NSString* dirname =
    [NSString stringWithFormat:@"schema/%@", components.firstObject];
  NSString* filename =
    [NSString stringWithFormat:@"%@-1.x", components.lastObject];
  NSBundle* bundle = [NSBundle bundleForClass:[self class]];
  NSURL* schemaURI =
    [bundle URLForResource:filename
             withExtension:@"json"
              subdirectory:dirname];
  NSAssert(schemaURI, @"No schema %@ in %@", filename, dirname);
  return schemaURI;
}

@end

