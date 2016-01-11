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

@interface OMHSerializer : NSObject

+ (NSArray*)supportedTypeIdentifiersWithOMHSchema;

+ (NSArray*)supportedTypeIdentifiers;


/**
 Serializes HealthKit samples into Open mHealth compliant json data points.
 @param sample the HealthKit sample to be serialized
 @param error an NSError that is passed by reference and can be checked to identify specific errors
 @return a formatted json string containing the sample's data in a format that adheres to the appropriate Open mHealth schema
 */
- (NSString*)jsonForSample:(HKSample*)sample error:(NSError**)error;

@end

