//
//  DatePickerSheetView.h
//  VPW
//
//  Created by Sunil Verma on 9/30/14.
//  Copyright (c) 2014 Halosys. All rights reserved.
//

#import "AppDelegate.h"

typedef void(^PickerPickDateBlock)(NSDate  *date);

@interface DatePickerSheetView : UIView


+(void)showDateOfBirth:(NSDate *)date AndTimeZone:(NSString *)timeZone datePickerType:(UIDatePickerMode)type WithReturnDate :(PickerPickDateBlock)block;
//+(void)showDatePickerWithDate:(NSDate *)date isDOB:(NSString *)dob AndTimeZone:(NSString *)timeZone WithReturnDate :(PickerPickDateBlock)block;
+(void)showDatePickerWithDate:(NSDate *)date AndTimeZone:(NSString *)timeZone datePickerType:(UIDatePickerMode)type WithReturnDate :(PickerPickDateBlock)block;
+(void)showDatePickerWithDateWithMyCustomMethodWithBool:(BOOL)isValid   withDate:(NSDate *)date AndTimeZone:(NSString *)timeZone datePickerType:(UIDatePickerMode)type WithReturnDate :(PickerPickDateBlock)block;
+(void)showDatePickerWithDate:(NSDate *)date AndTimeZone:(NSString *)timeZone datePickerType:(UIDatePickerMode)type selectedDate:(NSDate *)selectedDate WithReturnDate :(PickerPickDateBlock)block ;
@end
