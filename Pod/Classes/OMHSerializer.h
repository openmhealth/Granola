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

#import <Foundation/Foundation.h>
@import HealthKit;
#import "OMHError.h"

/**
 Translates HealthKit samples of varying types into JSON representations that conform with Open mHealth schemas.
 */
@interface OMHSerializer : NSObject

/**
 Returns a list of the HealthKit type identifiers that can be serialized to Open mHealth curated schemas. These are schemas that are not specific to Granola and are consistent with data points generated across the Open mHealth ecosystem.
 
 @return A list of the HealthKit type identifiers serializable to Open mHealth curated schemas.
 */
+ (NSArray*)supportedTypeIdentifiersWithOMHSchema;

/**
 Lists all of the HealthKit type identifiers that are supported by Granola, regardless of whether they use Open mHealth curated schemas or Granola-based generic schemas.
 
 @return A list of all HealthKit type identifiers that are supported by Granola.
 */
+ (NSArray*)supportedTypeIdentifiers;

/**
 Serializes HealthKit samples into Open mHealth compliant JSON data points.
 @param sample The HealthKit sample to be serialized.
 @param error An NSError that is passed by reference and can be checked to identify specific errors.
 @return A formatted JSON string containing the sample's data in a format that adheres to the appropriate Open mHealth schema.
 */
- (NSString*)jsonForSample:(HKSample*)sample error:(NSError**)error;

@end

