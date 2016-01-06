/*
 * Copyright 2015 Open mHealth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    [[OMHSchemaStore schemaPartialPaths]
     each:^(NSString* partialPath) {
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

- (NSURL*)schemaURIForPartialPath:(NSString*)fname {
    NSArray* components = [fname componentsSeparatedByString:@"/"];
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

+ (NSArray*)schemaPartialPaths{
    static NSArray* schemaPartialPaths = nil;
    
    if (schemaPartialPaths == nil)
    {
        schemaPartialPaths = @[
                               @"omh/schema-id",
                               @"omh/date-time",
                               @"omh/unit-value",
                               @"omh/duration-unit-value",
                               @"omh/part-of-day",
                               @"omh/time-interval",
                               @"omh/time-frame",
                               @"omh/header",
                               @"omh/data-point",
                               @"omh/step-count",
                               @"omh/length-unit-value",
                               @"omh/mass-unit-value",
                               @"omh/descriptive-statistic",
                               @"omh/body-height",
                               @"omh/body-weight",
                               @"omh/activity-name",
                               @"omh/area-unit-value",
                               @"omh/temporal-relationship-to-sleep",
                               @"omh/blood-specimen-type",
                               @"omh/temporal-relationship-to-meal",
                               @"omh/blood-glucose",
                               @"omh/position-during-measurement",
                               @"omh/systolic-blood-pressure",
                               @"omh/diastolic-blood-pressure",
                               @"omh/blood-pressure",
                               @"omh/temporal-relationship-to-physical-activity",
                               @"omh/heart-rate",
                               @"omh/body-mass-index",
                               @"omh/sleep-duration",
                               @"omh/physical-activity",
                               @"omh/kcal-unit-value",
                               @"omh/calories-burned",
                               @"omh/body-fat-percentage",
                               @"omh/oxygen-saturation",
                               @"granola/hk-metadata",
                               @"granola/hk-quantity-type",
                               @"granola/hk-quantity-sample",
                               @"granola/hk-category-type",
                               @"granola/hk-category-sample",
                               @"granola/hk-correlation-type",
                               @"granola/hk-correlation",
                               @"granola/hk-workout"];
    }
    
    return schemaPartialPaths;
}



@end

