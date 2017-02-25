/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "OCKCareSchedule.h"
#import "OCKCareSchedule_Internal.h"
#import "NSDateComponents+CarePlanInternal.h"
#import "OCKHelpers.h"


@implementation OCKCareSchedule {
    NSCalendar *_calendar;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

+ (instancetype)dailyScheduleWithStartTime:(NSDateComponents *)startTime
                                     times:(NSArray<NSDateComponents *> *)times {
    return [[OCKCareDailySchedule alloc] initWithStartTime:startTime
                                               daysToSkip:0
                                                     times:times
                                                   endTime:nil];
}

+ (instancetype)weeklyScheduleWithStartTime:(NSDateComponents *)startTime
                             timesOnEachDay:(NSArray<NSArray <NSDateComponents *> *> *)timesFromSundayToSaturday {
    return [[OCKCareWeeklySchedule alloc] initWithStartTime:startTime
                                                weeksToSkip:0
                                             timesOnEachDay:timesFromSundayToSaturday
                                                    endTime:nil];
}

+ (instancetype)dailyScheduleWithStartTime:(NSDateComponents *)startTime
                                     times:(NSArray <NSDateComponents *>*)times
                                daysToSkip:(NSUInteger)daysToSkip
                                   endTime:(nullable NSDateComponents *)endTime {
    return [[OCKCareDailySchedule alloc] initWithStartTime:startTime daysToSkip:daysToSkip times:times endTime:endTime];
}

+ (instancetype)weeklyScheduleWithStartTime:(NSDateComponents *)startTime
                             timesOnEachDay:(NSArray<NSArray <NSDateComponents *> *> *)timesFromSundayToSaturday
                                weeksToSkip:(NSUInteger)weeksToSkip
                                    endTime:(nullable NSDateComponents *)endTime {
    return [[OCKCareWeeklySchedule alloc] initWithStartTime:startTime
                                                weeksToSkip:weeksToSkip
                                             timesOnEachDay:timesFromSundayToSaturday
                                                    endTime:endTime];
}

- (instancetype)initWithStartTime:(NSDateComponents *)startTime
                          endTime:(NSDateComponents *)endTime
                            times:(NSArray<NSArray<NSDateComponents *> *> *)times
                  timeUnitsToSkip:(NSUInteger)timeUnitsToSkip {
    
    OCKThrowInvalidArgumentExceptionIfNil(startTime);
    if (endTime) {
        NSDate *startDate = [[self UTC_calendar] dateFromComponents:startTime];
        NSDate *endDate = [[self UTC_calendar] dateFromComponents:endTime];
        NSAssert([endDate timeIntervalSinceDate:startDate] >= 0, @"startDate should be earlier than endDate.");
    }
    
    self = [super init];
    if (self) {
        _startTime = [startTime copy];
        _endTime = [endTime copy];
        _times = [times copy];
        _timeUnitsToSkip = timeUnitsToSkip;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        OCK_DECODE_OBJ_CLASS(coder, startTime, NSDateComponents);
        OCK_DECODE_OBJ_CLASS(coder, endTime, NSDateComponents);
        OCK_DECODE_OBJ_ARRAY(coder, times, NSArray);
        OCK_DECODE_INTEGER(coder, timeUnitsToSkip);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    OCK_ENCODE_OBJ(coder, startTime);
    OCK_ENCODE_OBJ(coder, endTime);
    OCK_ENCODE_OBJ(coder, times);
    OCK_ENCODE_INTEGER(coder, timeUnitsToSkip);
}

- (BOOL)isEqual:(id)object {
    BOOL isClassMatch = ([self class] == [object class]);
    
    __typeof(self) castObject = object;
    return (isClassMatch &&
            OCKEqualObjects(self.startTime, castObject.startTime) &&
            OCKEqualObjects(self.endTime, castObject.endTime) &&
            OCKEqualObjects(self.times, castObject.times) &&
            (self.timeUnitsToSkip == castObject.timeUnitsToSkip));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    OCKCareSchedule *schedule = [[[self class] alloc] initWithStartTime:self.startTime endTime:self.endTime times:self.times timeUnitsToSkip:self.timeUnitsToSkip];
    return schedule;
}

- (BOOL)isDateInRange:(NSDateComponents *)day {
    NSDateComponents *validatedStartTime = [_startTime validatedDateComponents];
    NSDateComponents *validatedEndTime = [_endTime validatedDateComponents];
    return (([day isLaterThan:validatedStartTime] || [day isEqualToDate:validatedStartTime]) &&
            (_endTime == nil || [day isEarlierThan:validatedEndTime] || [day isEqualToDate:validatedEndTime]));
}

- (NSCalendar *)UTC_calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    return _calendar;
}

- (NSUInteger)numberOfEventsOnDate:(NSDateComponents *)day {
    OCKThrowMethodUnavailableException();
}

- (NSUInteger)numberOfDaySinceStart:(NSDateComponents *)day {
    
    NSCalendar *calendar = [self UTC_calendar];
    NSInteger startDate = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                             inUnit:NSCalendarUnitEra
                                            forDate:[_startTime UTC_dateWithGregorianCalendar]];
    
    NSInteger endDate = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                           inUnit:NSCalendarUnitEra
                                          forDate:[day UTC_dateWithGregorianCalendar]];

    NSUInteger daysSinceStart = endDate - startDate;
    return daysSinceStart;
}

-(void)setEndTime:(NSDateComponents *)endTime {
    NSAssert(![_startTime isLaterThan:endTime], @"startTime should be earlier than endTime. %@ %@", _startTime, endTime);
    _endTime = endTime;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", [super description], _startTime, _endTime];
}

- (OCKCareScheduleType)type {
    return OCKCareScheduleTypeOther;
}

@end


@implementation OCKCareDailySchedule

- (OCKCareScheduleType)type {
    return OCKCareScheduleTypeDaily;
}

- (instancetype)initWithStartTime:(NSDateComponents *)startTime
                       daysToSkip:(NSUInteger)daysToSkip
                            times:(NSArray<NSDateComponents *> *)times
                          endTime:(nullable NSDateComponents *)endTime {
    self = [self initWithStartTime:startTime endTime:endTime times: @[times] timeUnitsToSkip:daysToSkip];
    return self;
}

- (NSUInteger)numberOfEventsOnDate:(NSDateComponents *)day {
    NSUInteger occurrences = 0;
    if ([self isDateInRange:day]) {
        NSUInteger occurrencesPerDay = self.times.firstObject.count;
        NSUInteger daysSinceStart = [self numberOfDaySinceStart:day];
        occurrences = ((daysSinceStart % (self.timeUnitsToSkip + 1)) == 0) ? occurrencesPerDay : 0;
        if ([[self.startTime validatedDateComponents] isEqualToDate:day]) {
            NSMutableArray<NSDateComponents *> *filteredTimes = [self.times.firstObject mutableCopy];
            for (NSDateComponents *time in filteredTimes) {
                NSDate *doseTimeDate = [[self UTC_calendar] dateFromComponents:[[self.startTime validatedDateComponents] combineWith:time]];
                NSDate *startDate = [[self UTC_calendar] dateFromComponents:self.startTime];
                if ([doseTimeDate timeIntervalSinceDate:startDate] < 0) {
                    [filteredTimes removeObject:time];
                }
            }
            occurrences = filteredTimes.count;
        } else if ([[self.endTime validatedDateComponents] isEqualToDate:day]) {
            NSMutableArray<NSDateComponents *> *filteredTimes = [self.times.firstObject mutableCopy];
            for (NSDateComponents *time in filteredTimes) {
                NSDate *doseTimeDate = [[self UTC_calendar] dateFromComponents:[[self.endTime validatedDateComponents] combineWith:time]];
                NSDate *endDate = [[self UTC_calendar] dateFromComponents:self.endTime];
                if ([endDate timeIntervalSinceDate:doseTimeDate] < 0) {
                    [filteredTimes removeObject:time];
                }
            }
            occurrences = filteredTimes.count;
        } else {
            occurrences = self.times.count;
        }
    }
    return occurrences;
}

@end


@implementation OCKCareWeeklySchedule

- (OCKCareScheduleType)type {
    return OCKCareScheduleTypeWeekly;
}

- (instancetype)initWithStartTime:(NSDateComponents *)startTime
                      weeksToSkip:(NSUInteger)weeksToSkip
                   timesOnEachDay:(NSArray<NSArray <NSDateComponents *> *> *)timesFromSundayToSaturday
                          endTime:(nullable NSDateComponents *)endTime {
    
    OCKThrowInvalidArgumentExceptionIfNil(timesFromSundayToSaturday);
    NSParameterAssert(timesFromSundayToSaturday.count == 7);
    
    self = [self initWithStartTime:startTime endTime:endTime times:timesFromSundayToSaturday timeUnitsToSkip:weeksToSkip];
    return self;
}

- (NSUInteger)numberOfEventsOnDate:(NSDateComponents *)day {
    NSUInteger occurrences = 0;
    if ([self isDateInRange:day]) {
        NSCalendar *calendar = [self UTC_calendar];
        
        NSInteger startWeek = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear
                                                 inUnit:NSCalendarUnitEra
                                                forDate:[self.startTime UTC_dateWithGregorianCalendar]];
        
        NSInteger endWeek = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear
                                               inUnit:NSCalendarUnitEra
                                              forDate:[day UTC_dateWithGregorianCalendar]];
       
        NSUInteger weeksSinceStart = endWeek - startWeek;
        NSUInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:[day UTC_dateWithGregorianCalendar]];
        
        if ([[self.startTime validatedDateComponents] isEqualToDate:day]) {
            NSMutableArray<NSDateComponents *> *filteredTimes = [self.times[weekday-1] mutableCopy];
            for (NSDateComponents *time in filteredTimes) {
                NSDate *doseTimeDate = [[self UTC_calendar] dateFromComponents:[[self.startTime validatedDateComponents] combineWith:time]];
                NSDate *startDate = [[self UTC_calendar] dateFromComponents:self.startTime];
                if ([doseTimeDate timeIntervalSinceDate:startDate] < 0) {
                    [filteredTimes removeObject:time];
                }
            }
            occurrences = filteredTimes.count;
        } else if ([[self.endTime validatedDateComponents] isEqualToDate:day]) {
            NSMutableArray<NSDateComponents *> *filteredTimes = [self.times[weekday-1] mutableCopy];
            for (NSDateComponents *time in filteredTimes) {
                NSDate *doseTimeDate = [[self UTC_calendar] dateFromComponents:[[self.endTime validatedDateComponents] combineWith:time]];
                NSDate *endDate = [[self UTC_calendar] dateFromComponents:self.endTime];
                if ([endDate timeIntervalSinceDate:doseTimeDate] < 0) {
                    [filteredTimes removeObject:time];
                }
            }
            occurrences = filteredTimes.count;
        } else {
            occurrences = ((weeksSinceStart % (self.timeUnitsToSkip + 1)) == 0) ? self.times[weekday-1].count : 0;
        }
    }
    return occurrences;
}

@end
