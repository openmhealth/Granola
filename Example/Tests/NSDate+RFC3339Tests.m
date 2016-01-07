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


#import <Foundation/Foundation.h>
#import "NSDate+RFC3339.h"

SpecBegin(NSDate)
describe(@"NSDate RFC3339 Formatter", ^{
    __block NSString* offsetString;
    __block NSInteger offsetHours;
    __block NSCalendar* calendar;
    __block NSDateComponents* dateBuilder;
    
    beforeAll(^{
        long offsetint = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        offsetString = [NSString stringWithFormat:@"%ld",offsetint];
        calendar = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        offsetHours = 6*60*60; // +06:00 offset
        dateBuilder = [[NSDateComponents alloc] init];
        
        dateBuilder.year = 2015;
        dateBuilder.day = 28;
        dateBuilder.month = 6;
        dateBuilder.hour = 8;
        dateBuilder.minute = 6;
        dateBuilder.second = 9;
        dateBuilder.nanosecond = 100*1000000;
        
    });
    
    it(@"should create timestamps with 'Z' offset when time zone information not provided",^{
        
        NSString* expectedDateString = @"2015-06-28T02:06:09.100Z";
        
        dateBuilder.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:offsetHours];
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339String];
        expect(testDateString).to.equal(expectedDateString);
    });
    
    it(@"should create timestamps with correct offset when date is created in UTC and time zone information is provided",^{
        
        NSString* expectedDateString = @"2015-06-28T14:06:09.100+06:00";
        
        dateBuilder.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339String:[NSTimeZone timeZoneForSecondsFromGMT:offsetHours]];
        expect(testDateString).to.equal(expectedDateString);
    });
    
    it(@"should create timestamps with correct offset when date is created in offset from UTC and time zone information provided",^{
        
        NSString* expectedDateString = @"2015-06-28T08:06:09.100+06:00";
        
        NSTimeZone* timezone = [NSTimeZone timeZoneForSecondsFromGMT:offsetHours];
        
        dateBuilder.timeZone = timezone;
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339String:timezone];
        expect(testDateString).to.equal(expectedDateString);
    });
    
});
SpecEnd

