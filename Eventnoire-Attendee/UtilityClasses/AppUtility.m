//
//  AppUtility.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "AppUtility.h"
#import "Macro.h"

@implementation AppUtility
+ (void)delay:(double)delayInSeconds :(void(^)(void))callback {
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        if(callback){
            callback();
        }
    });
}

//Show hud
void showHud(NSString *headerText,NSString *footerText,UIView *view){
    
//    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.label.text = headerText;
//    hud.detailsLabel.text = footerText;
}

+ (NSDate *)getDateFromString:(NSString *)dateStr {
    
    if ([dateStr length]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // new line added
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        return [dateFormatter dateFromString: dateStr];
        
    }
    return [NSDate date];
}

+ (NSDate *)convertTimeStampToNsDate:(NSString *)timeStamp {
    
    double doubleTimeStamp = [timeStamp doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)doubleTimeStamp/1000];
}

+(NSString*)timestamp2date:(NSString*)timestamp{
    NSString * timeStampString =timestamp;
    //[timeStampString stringByAppendingString:@"000"];   //convert to ms
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"dd/MM/yy"];
    return [_formatter stringFromDate:date];
}

+(NSString*)timestampToDateAndTime:(NSString*)timestamp{
    NSString * timeStampString =timestamp;
    //[timeStampString stringByAppendingString:@"000"];   //convert to ms
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"'HH':'mm' aa', dd/MM/yy"];
    return [_formatter stringFromDate:date];
}


+(NSString*)setFormatter:(NSString*)dateTimeStr {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM dd,yyyy hh:mm a"];
    
    NSDate *date = [format dateFromString:dateTimeStr];
    
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSString *createdDateStr = [formatDate stringFromDate:date];
    return createdDateStr;
}

+ (NSString *)getStringFromDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // new line added
    [formatter setDateFormat:@"dd/MM/yy"];
    
    return [formatter stringFromDate:date];
    
}

+ (NSString *)getStringFromTime:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // new line added
    [formatter setDateFormat:@"HH:mm"];
    
    return [formatter stringFromDate:date];
    
}

+ (NSString *)getStringFromFullTime:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // new line added
    [formatter setDateFormat:@"hh:mm aa"]; // modified
    
    return [formatter stringFromDate:date];
    
}

+(NSString*)timestampToTime:(NSString*)timestamp{
    
    NSString * timeStampString =timestamp;
    //[timeStampString stringByAppendingString:@"000"];   //convert to ms
    
    NSTimeInterval _interval=[timeStampString doubleValue];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"HH:mm aa"];
    
    return [_formatter stringFromDate:date];
}

+(NSString*)convertDateToStringWith:(NSString *)timeStr{
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *timeDate;
    if (timeStr) {
        timeDate = [dateFormat dateFromString:timeStr];
    } else {
        timeDate = [NSDate date];
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    NSString *timeString = [timeFormatter stringFromDate:timeDate];
    
    return timeString;
}

+(long long)getTimeStampForDate:(NSString *)strDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [formatter dateFromString:strDate];
    long long milliseconds = (long long)([date timeIntervalSince1970] * 1000.0);
    return milliseconds;
}

+(long long)getTimeStampForDateTime:(NSString *)strDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH':'mm' aa', dd/MM/yy"];
    NSDate *date = [formatter dateFromString:strDate];
    long long milliseconds = (long long)([date timeIntervalSince1970] * 1000.0);
    return milliseconds;
}

+(long long)getTimeStampForDateString:(NSString *)strDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [formatter dateFromString:strDate];
    long long milliseconds = (long long)([date timeIntervalSince1970] * 1000.0);
    return milliseconds;
}

+ (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address{
    
    double latitude = 0, longitude = 0;
    
    // [NSUSERDEFAULTS setValue:address forKey:@"strLocation"];
    
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    if (result) {
        
        NSScanner *scanner = [NSScanner scannerWithString:result];
        
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            
            [scanner scanDouble:&latitude];
            
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                
                [scanner scanDouble:&longitude];
                
            }
        }
    }
    
    CLLocationCoordinate2D center;
    
    center.latitude = latitude;
    
    center.longitude = longitude;
    
    return center;
    
}

UIToolbar* toolBarForNumberPad(id controller, NSString *titleDoneOrNext) {
    //NSString *doneOrNext;
    
    UIToolbar *numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, windowWidth, 50)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:titleDoneOrNext style:UIBarButtonItemStyleDone target:controller action:@selector(doneWithNumberPad:)];
    doneBtn.tintColor = AppColor;
    
    UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    [numberToolbar setItems: [NSArray arrayWithObjects:flexibleSpace,doneBtn, nil] animated:NO];
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender {
    
}

+(NSString*)convertDateToString:(NSInteger)timeStamp andDateFormat:(NSString *)dateFormatter {
    
    NSDate *comingDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *comingDateFormatter = [[NSDateFormatter alloc] init];
    [comingDateFormatter setDateFormat:dateFormatter];
    [comingDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *comingDateString = [comingDateFormatter stringFromDate:comingDate];
    
    return comingDateString;
}

+(NSInteger)getHeightFromText:(NSString *)text {
	CGRect textRect = [text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, NSIntegerMax)
																			 options:NSStringDrawingUsesLineFragmentOrigin
																		attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:16]}
																			 context:nil];
	return textRect.size.height;
}

@end
