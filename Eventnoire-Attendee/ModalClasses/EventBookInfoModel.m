//
//  EventBookInfoModel.m
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 16/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "NSDictionary+NullChecker.h"
#import "EventBookInfoModel.h"
#import "AppUtility.h"
#import "Macro.h"

@implementation EventBookInfoModel
+(EventBookInfoModel*) ticketsDetails:(NSDictionary*)dict{
    
    EventBookInfoModel *objModel = [[EventBookInfoModel alloc]init];
    objModel.firstNameTicketOwner  = [dict objectForKeyNotNull:pFirst_name expectedObj:@""];
    objModel.lastNameTicketOwner  = [dict objectForKeyNotNull:pLast_name expectedObj:@""];
    objModel.QrCodeUrl  = [dict objectForKeyNotNull:pQr_code_url expectedObj:@""];
    
    return objModel;
}


+(EventBookInfoModel*) eventDetails:(NSDictionary*)dict{
    
    EventBookInfoModel *objModel = [[EventBookInfoModel alloc]init];
    objModel.eventVenueName  = [dict objectForKeyNotNull:pVenueName expectedObj:@""];
    objModel.eventName  = [dict objectForKeyNotNull:pTitle expectedObj:@""];
    objModel.eventStartDate  = [dict objectForKeyNotNull:pStartDate expectedObj:@""];
    objModel.eventEndDate  = [dict objectForKeyNotNull:pEndDate expectedObj:@""];
    objModel.eventDescription  = [dict objectForKeyNotNull:pDes expectedObj:@""];
    objModel.eventDistance  = [NSString stringWithFormat:@"%.2f",[[dict objectForKeyNotNull:pDistance expectedObj:@"0"] floatValue]];
    objModel.eventLatitude  = [dict objectForKeyNotNull:pLatitude expectedObj:@""];
    objModel.eventLongitude  = [dict objectForKeyNotNull:pLongitude expectedObj:@""];
    objModel.eventImage  = [dict objectForKeyNotNull:pImageURL expectedObj:@""];

    
    objModel.eventStartDateModified = [AppUtility convertDateToString:[objModel.eventStartDate integerValue] andDateFormat:@"EEE MMMM dd"];
    objModel.eventStartTimeModified = [AppUtility convertDateToString:[objModel.eventStartDate integerValue] andDateFormat:@"hh:mm a"];
    objModel.eventEndDateModified = [AppUtility convertDateToString:[objModel.eventEndDate integerValue] andDateFormat:@"EEE MMMM dd"];
    objModel.eventEndTimeModified = [AppUtility convertDateToString:[objModel.eventEndDate integerValue] andDateFormat:@"hh:mm a"];
    
	NSInteger textHeight = [AppUtility getHeightFromText: objModel.eventDescription];
	
	if (textHeight > 75) {
		objModel.isMoreNeeded = YES;
	}else
		objModel.isMoreNeeded = NO;
	
    return objModel;

}










@end
