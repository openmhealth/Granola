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
    
    beforeAll(^{
        long offsetint = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        offsetString = [NSString stringWithFormat:@"%ld",offsetint];
    });
    
    it(@"-Generates the correct timestamp with time-numoffset",^{
        
        NSString* expectedDateString = @"2015-06-28T05:06:09.100-06:00"; // The offset here must be changed to your local timezone for the test to pass
        
        NSDateComponents* dateBuilder = [[NSDateComponents alloc] init];
        [dateBuilder setYear:2015];
        [dateBuilder setDay:28];
        [dateBuilder setMonth:06];
        [dateBuilder setHour:05];
        [dateBuilder setMinute:06];
        [dateBuilder setSecond:9];
        [dateBuilder setNanosecond:100*1000000];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate* date = [gregorian dateFromComponents:dateBuilder];
        NSString* testDateString = [date RFC3339String];
        expect(testDateString).to.equal(expectedDateString);
        
    });
    
    
});
SpecEnd

