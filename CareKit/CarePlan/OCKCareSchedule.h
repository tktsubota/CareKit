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


#import "OCKDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 Defines the schedule types.
 Daily and weekly are predefined types.
 You can subclass the OCKCareScheduleclass to support other types of schedules. These will have the type OCKCareScheduleTypeOther.
 */
OCK_ENUM_AVAILABLE
typedef NS_ENUM(NSInteger, OCKCareScheduleType) {
    /** Same occurrence rate on each day. */
    OCKCareScheduleTypeDaily,
    /** Different occurrence rate on each day in week. */
    OCKCareScheduleTypeWeekly,
    /** Other type */
    OCKCareScheduleTypeOther
};


/**
 An OCKCareSchedule class instance defines start and end dates, and the reccurrence pattern for an activity.
 OCKCareSchedule works only with the Gregorian calendar.
 You must convert date components that use another calendar to the Gregorian calendar before sending to OCKCareSchedule.
 
 Subclass `OCKCareSchedule` to support other type of schedules.
 A subclass must implement numberOfEventsOnDate: and conform to the NSSecureCoding and NSCopying protocols.
 */
OCK_CLASS_AVAILABLE
@interface OCKCareSchedule : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

/**
 Defines a schedule that has the same times for doses each day.
 
 You can set the end date later by using the CarePlanStore API.
 
 @param startTime           Start time for a schedule, using the Gregorian calendar.
 @param times               Times for doses each day.
 
 @return    An OCKCareSchedule instance.
 */
+ (instancetype)dailyScheduleWithStartTime:(NSDateComponents *)startTime
                                     times:(NSArray<NSDateComponents *> *)times;

/**
 Defines a schedule that repeats every week.
 
 Each weekday can have a different set of dose times.
 You can set the end date later by using the CarePlanStore API.
 
 @param startTime                       Start time for a schedule, using the Gregorian calendar.
 @param timesFromSundayToSaturday       Times for dose from Sunday through Saturday.
 
 @return    An OCKCareSchedule instance.
 */
+ (instancetype)weeklyScheduleWithStartTime:(NSDateComponents *)startTime
                             timesOnEachDay:(NSArray<NSArray<NSDateComponents *> *> *)timesFromSundayToSaturday;

/**
 Defines a schedule that has the same times for doses every day.
 
 @param startTime           Start time for a schedule, using the Gregorian calendar.
 @param times               Times for doses each day.
 @param daysToSkip          Number of days between two active days during this period for which the schedule has no occurrence. 
                            (That is, number of skipped days.)
                            First day of a schedule is recognized as an active day.
 @param endTime             End time for a schedule, using the Gregorian calendar.
 
 @return    An OCKCareSchedule instance.
 */
+ (instancetype)dailyScheduleWithStartTime:(NSDateComponents *)startTime
                                     times:(NSArray<NSDateComponents *> *)times
                                daysToSkip:(NSUInteger)daysToSkip
                                   endTime:(nullable NSDateComponents *)endTime;

/**
 Defines a schedule that repeats every week.
 
 Each weekday can have a different number of occurrences.
 
 @param startTime                       Start time for a schedule, using the Gregorian calendar.
 @param timesOnEachDay                  Times for doses from Sunday to Saturday.
 @param weeksToSkip                     Number of weeks between two active weeks during this period for which the schedule has no occurrence.
                                        (That is, number of skipped weeks.)
 @param endTime                         End time for a schedule, using the Gregorian calendar.
 
 @return    An OCKCareSchedule instance.
 */
+ (instancetype)weeklyScheduleWithStartTime:(NSDateComponents *)startTime
                             timesOnEachDay:(NSArray<NSArray<NSDateComponents *> *> *)timesFromSundayToSaturday
                                weeksToSkip:(NSUInteger)weeksToSkip
                                    endTime:(nullable NSDateComponents *)endTime;

/**
 Type of schedule.
 */
@property (nonatomic, readonly) OCKCareScheduleType type;

/**
 Start time of schedule.
 
 Gregorian calendar representation of a date.
 Date components in another calendar must be converted to the Gregorian calendar before using in an OCKCareSchedule object.
 */
@property (nonatomic, readonly) NSDateComponents *startTime;

/**
 End time of schedule.
 
 Gregorian calendar representation of a date.
 Date components in another calendar must be converted to the Gregorian calendar before using in an OCKCareSchedule object.
 */
@property (nonatomic, readonly, nullable) NSDateComponents *endTime;

/**
 Times for events for each day in a schedule.
 
 Daily schedule has only array of dates.
 Weekly schedule has 7 arrays of dates mapping from Sunday to Saturday.
 */
@property (nonatomic, copy, readonly) NSArray<NSArray<NSDateComponents *> *> *times;

/**
 Number of inactive time units between two active time units.
 During this period, schedule has no occurrence.
 
 For daily schedule, first day of a schedule is recognized as an active day.
 For weekly schedule, first week of a schedule is recognized as an active week.
 */
@property (nonatomic, readonly) NSUInteger timeUnitsToSkip;

/**
 Save any additional objects that comply with the NSCoding protocol.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id<NSCoding>> *userInfo;


/**
 How many events (occurrences) on a date.
 
 @param date        Gregorian calendar representation of a date.
                    Only Era/Year/Month/Day attributes are observed.
 
 @return    The number of events on the specified date.
 */
- (NSUInteger)numberOfEventsOnDate:(NSDateComponents *)date;

@end

NS_ASSUME_NONNULL_END
