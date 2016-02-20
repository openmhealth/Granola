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
#import "NSDate+RFC3339.h"

SpecBegin(NSDate)

__block NSInteger offsetHours;
__block NSCalendar* calendar;
__block NSDateComponents* dateBuilder;
__block float offsetNumber;
__block float hour;

beforeAll(^{
    offsetNumber = [[NSTimeZone defaultTimeZone] secondsFromGMT] / 3600;
    
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    hour = 60*60;
    offsetHours = 6*hour; // +06:00 offset
    dateBuilder = [NSDateComponents new];
    
    dateBuilder.year = 2015;
    dateBuilder.day = 28;
    dateBuilder.month = 6;
    dateBuilder.hour = 8;
    dateBuilder.minute = 6;
    dateBuilder.second = 9;
    dateBuilder.nanosecond = 100000000;
    
});

describe(@"NSDate RFC3339 Formatter RFC3339String", ^{
    
    it(@"should create timestamps with default time zone when time zone is not provided",^{
        
        NSString* expectedDateString = @"2015-06-28T09:06:09.100+06:00";
        
        dateBuilder.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(offsetHours-(1*hour))];
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offsetHours]];
        
        NSString* testDateString = [date RFC3339String];
        expect(testDateString).to.equal(expectedDateString);
    });
    
    it(@"should create timestamps with correct offset when date is created in UTC and time zone is provided",^{
        
        NSString* expectedDateString = @"2015-06-28T14:06:09.100+06:00";
        
        dateBuilder.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339StringAtTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offsetHours]];
        expect(testDateString).to.equal(expectedDateString);
    });
    
    it(@"should create timestamps with correct offset when date is created in offset from UTC and time zone provided",^{
        
        NSString* expectedDateString = @"2015-06-28T08:06:09.100+06:00";
        
        NSTimeZone* timezone = [NSTimeZone timeZoneForSecondsFromGMT:offsetHours];
        
        dateBuilder.timeZone = timezone;
        
        NSDate* date = [calendar dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339StringAtTimeZone:timezone];
        expect(testDateString).to.equal(expectedDateString);
    });
    
    it(@"should create timestamps with correct fractional offset when date is created in offset from UTC and fractional time zone provided",
       ^{
           NSString* expectedDateString = @"2015-06-28T13:36:09.100+05:30";
           
           dateBuilder.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
           
           // +05:30 with not DST
           NSTimeZone* timezone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
           
           NSDate* date = [calendar dateFromComponents:dateBuilder];
           NSString* testDateString = [date RFC3339StringAtTimeZone:timezone];
           expect(testDateString).to.equal(expectedDateString);
       }
    );
    
});

describe(@"NSDate RFC3339 Formatter fromRFC3339String", ^{
    
    it(@"should create correct date when at second level precision", ^{
       
        NSString* testDateString = @"2016-02-19T05:35:10.000Z";

        NSDate* expectedDate = [NSDate dateWithTimeIntervalSince1970:[@1455860110 doubleValue]];
        
        NSDate* testDate = [NSDate fromRFC3339String:testDateString];
        
        expect(testDate).to.equal(expectedDate);
    });
    
    it(@"should create correct date at millisecond level precision", ^{
        
        NSString* testDateString = @"2016-02-19T05:35:10.282Z";
        
        NSDate* expectedDate = [NSDate dateWithTimeIntervalSince1970:[@1455860110.282 doubleValue]];
        
        NSDate* testDate = [NSDate fromRFC3339String:testDateString];
        
        expect(testDate).to.equal(expectedDate);
    });
    
    it(@"should create correct date when string contains non-UTC offset", ^{
        
        NSString* testDateString = @"2016-02-19T12:35:10.282+07:00";
        
        NSDate* expectedDate = [NSDate dateWithTimeIntervalSince1970:[@1455860110.282 doubleValue]];
        
        NSDate* testDate = [NSDate fromRFC3339String:testDateString];
        
        expect(testDate).to.equal(expectedDate);
    });
});

SpecEnd

