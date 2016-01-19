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

#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)

+ (NSDateFormatter*)RFC3339Formatter:(NSTimeZone*)timeZone {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    formatter.timeZone = timeZone;
    formatter.locale = locale;
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSXXX";
    
    return formatter;
}

- (NSString *)RFC3339String {
    return [[[self class] RFC3339Formatter:[NSTimeZone defaultTimeZone]] stringFromDate:self];
}

- (NSString *)RFC3339String:(NSTimeZone*)timeZone {
    return [[[self class] RFC3339Formatter:timeZone] stringFromDate:self];
}

+ (NSDate*)fromRFC3339String:(NSString*)dateString timeZone:(NSTimeZone*)timeZone {
    return [[self RFC3339Formatter:timeZone] dateFromString:dateString];
}

+ (NSDate*)fromRFC3339String:(NSString*)dateString {
    return [[self RFC3339Formatter:[NSTimeZone defaultTimeZone]] dateFromString:dateString];
}

/**
 * NSDateFormatter has a strange behavior in that it only operates at the millisecond level and truncates number information after a certain
 * point (see http://stackoverflow.com/questions/23684727/nsdateformatter-milliseconds-bug). This leads to strange behavior when creating 
 * dates using the nanoseconds property and using the RFC3339DateFormatter to transform between the string representation and the date 
 * representation. We found nanosecond differences in comparing some dates created with the fromRFC3339String method and what was expected. 
 * In exploring this, we found that transforming dates created with the fromRFC3339String method back into strings and compare them allowed
 * the comparison to be done at the millisecond level and used the correct rounding to address the issue. 
 *
 * We recommend using this method when comparing a date created with the fromRFC3339String to another date.
 */
- (BOOL)isEqualToRFC3339Date:(NSDate *)otherDate {
    NSString* otherDateString = [otherDate RFC3339String];
    return [otherDateString isEqualToString:[self RFC3339String]];
}

@end

