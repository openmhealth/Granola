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

- (NSString *)RFC3339StringAtTimeZone:(NSTimeZone*)timeZone {
    return [[[self class] RFC3339Formatter:timeZone] stringFromDate:self];
}

+ (NSDate*)fromRFC3339String:(NSString*)dateString {
    return [[self RFC3339Formatter:[NSTimeZone defaultTimeZone]] dateFromString:dateString];
}

@end

