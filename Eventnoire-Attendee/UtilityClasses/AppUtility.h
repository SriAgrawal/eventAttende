//
//  AppUtility.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIKit.h>

@interface AppUtility : NSObject
+ (void)delay:(double)delayInSeconds :(void(^)(void))callback;

+ (NSDate *)getDateFromString:(NSString *)dateStr;
+ (NSString *)getStringFromDate:(NSDate *)date;
+ (NSString *)getStringFromTime:(NSDate *)date;
+ (NSString*)timestamp2date:(NSString*)timestamp;
+ (NSString*)timestampToDateAndTime:(NSString*)timestamp;
+ (NSString*)timestampToTime:(NSString*)timestamp;
+ (NSString *)getStringFromFullTime:(NSDate *)date;

+ (NSString*)convertDateToStringWith:(NSString *)timeStr;

+ (NSDate *)convertTimeStampToNsDate:(NSString *)timeStamp;
+(long long)getTimeStampForDate:(NSString *)strDate;
+(long long)getTimeStampForDateTime:(NSString *)strDate;

+(long long)getTimeStampForDateString:(NSString *)strDate ;

+(NSString*)setFormatter:(NSString*)dateTimeStr;

+(CLLocationCoordinate2D)geoCodeUsingAddress:(NSString *)address;
+(NSString*)convertDateToString:(NSInteger)timeStamp andDateFormat:(NSString *)dateFormatter;
void showHud(NSString *headerText,NSString *footerText,UIView *view);
UIToolbar* toolBarForNumberPad(id controller, NSString *titleDoneOrNext);

+(NSInteger)getHeightFromText:(NSString *)text;

@end
