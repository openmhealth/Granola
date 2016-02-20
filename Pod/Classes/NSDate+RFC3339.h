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

/**
 Extension for the `NSDate` class to provide support for RFC3339 formatting.
 
 @warning Due to the limited precision of the `NSDate` class, we can only support millsecond-level precision for RFC3339 timestamps. In translating an `NSDate` to an RFC3339 string or vice versa, values with greater than millisecond-level precision may lose fidelity and have values that deviate from the expected value by a number of microseconds or nanoseconds.
 */
@interface NSDate (RFC3339)

/**
 Generates an RFC3339 formatted string representation of the object. This method uses the default timezone in generating the RFC3339 timestamp.
 
 @return An RFC3339 formatted string representation of the `NSDate` object.
 */
- (NSString *)RFC3339String;

/**
 Generates an RFC3339 formatted string representation of the object. This method uses the `timeZone` parameter as the offset for the RFC3339 timestamp.
 
 @param timeZone The timezone to use in rendering the RFC3339 timestamp.
 
 @return An RFC3339 formatted string representation of the `NSDate` object.
 */
- (NSString *)RFC3339StringAtTimeZone:(NSTimeZone*)timeZone;

/**
 Static method to create an `NSDate` object from an RFC3339 formatted timestamp.
 
 @param dateString The RFC3339 formatted string that you want to represent as an `NSDate` object.
 
 @return An `NSDate` that refers to the same _moment in time_ that the input string represented.
 */
+ (NSDate*)fromRFC3339String:(NSString*)dateString;

@end

