/*
 * Copyright 2016 Open mHealth
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
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* schemaURI =
    [bundle URLForResource:components.lastObject
             withExtension:@"json"
              subdirectory:dirname];
    NSAssert(schemaURI, @"No schema %@ in %@", components.lastObject, dirname);
    return schemaURI;
}

+ (NSArray*)schemaPartialPaths{
    static NSArray* schemaPartialPaths = nil;
    
    if (schemaPartialPaths == nil)
    {
        schemaPartialPaths = @[
                               @"omh/schema-id-1.x",
                               @"omh/date-time-1.x",
                               @"omh/unit-value-1.x",
                               @"omh/duration-unit-value-1.x",
                               @"omh/part-of-day-1.x",
                               @"omh/time-interval-1.x",
                               @"omh/time-frame-1.x",
                               @"omh/header-1.x",
                               @"omh/data-point-1.x",
                               @"omh/step-count-1.x",
                               @"omh/length-unit-value-1.x",
                               @"omh/mass-unit-value-1.x",
                               @"omh/temperature-unit-value-1.x",
                               @"omh/descriptive-statistic-1.x",
                               @"omh/body-height-1.x",
                               @"omh/body-weight-1.x",
                               @"omh/activity-name-1.x",
                               @"omh/area-unit-value-1.x",
                               @"omh/temporal-relationship-to-sleep-1.x",
                               @"omh/blood-specimen-type-1.x",
                               @"omh/temporal-relationship-to-meal-1.x",
                               @"omh/blood-glucose-1.x",
                               @"omh/position-during-measurement-1.x",
                               @"omh/systolic-blood-pressure-1.x",
                               @"omh/diastolic-blood-pressure-1.x",
                               @"omh/blood-pressure-1.x",
                               @"omh/temporal-relationship-to-physical-activity-1.x",
                               @"omh/heart-rate-1.x",
                               @"omh/body-mass-index-1.x",
                               @"omh/sleep-duration-1.x",
                               @"omh/physical-activity-1.x",
                               @"omh/kcal-unit-value-1.x",
                               @"omh/calories-burned-1.x",
                               @"omh/body-fat-percentage-1.x",
                               @"omh/oxygen-saturation-1.x",
                               @"omh/respiratory-rate-1.x",
                               @"omh/body-temperature-2.x",
                               @"granola/hk-metadata-1.x",
                               @"granola/hk-quantity-type-1.x",
                               @"granola/hk-quantity-sample-1.x",
                               @"granola/hk-category-type-1.x",
                               @"granola/hk-category-sample-1.x",
                               @"granola/hk-correlation-type-1.x",
                               @"granola/hk-correlation-1.x",
                               @"granola/hk-workout-1.x"];
    }
    
    return schemaPartialPaths;
}



@end

