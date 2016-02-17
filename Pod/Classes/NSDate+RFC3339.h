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
 */
@interface NSDate (RFC3339)

/**
 Generates an RFC3339 formatted string representation of the object. This method uses the default timezone in generating the RFC3339 timestamp.
 
 @return An RFC3339 formatted string representation of the `NSDate` object.
 */
- (NSString *)RFC3339String;

/**
 Generates an RFC3339 formatted string representation of the object. This method uses the default timezone in generating the RFC3339 timestamp.
 
 @param timeZone The timezone to use in rendering the RFC3339 timestamp.
 
 @return An RFC3339 formatted string representation of the `NSDate` object.
 */
- (NSString *)RFC3339String:(NSTimeZone*)timeZone;

/**
 Static method to create an `NSDate` object from an RFC3339 formatted timestamp.
 
 @param dateString The RFC3339 formatted string that you want to represent as an `NSDate` object.
 
 @return An `NSDate` that refers to the same _moment in time_ that the input string represented.
 */
+ (NSDate*)fromRFC3339String:(NSString*)dateString;

/**
 Compares this object with another `NSDate` object that was created using the `NSDate+RFC3339` extension.
 
 `NSDateFormatter` has a strange behavior in that it only operates at the millisecond level and truncates number information after a certain point (see http://stackoverflow.com/questions/23684727/nsdateformatter-milliseconds-bug). This leads to strange behavior when creating dates using the nanoseconds property and using the RFC3339DateFormatter to transform between the string representation and the date representation. We found nanosecond differences in comparing some dates created with the `fromRFC3339String` method and what was expected.
 
 In exploring this, we found that transforming dates created with the `fromRFC3339String` method back into strings and compare them allowed the comparison to be done at the millisecond level and used the correct rounding to address the issue.
 
 We recommend using this method when comparing a date created with the `fromRFC3339String` to another date.
 
 @param otherDate An `NSDate` that was created using the `NSDate+RFC3339` extension.
 
 @return Whether some other `NSDate` object refers to the same point in time as this one.

 */
- (BOOL)isEqualToRFC3339Date:(NSDate *)otherDate;

@end

