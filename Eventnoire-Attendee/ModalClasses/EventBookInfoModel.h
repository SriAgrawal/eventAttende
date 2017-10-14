//  EventBookInfoModel.h
//  Eventnoire-Attendee
//  Created by Ashish Kumar Gupta on 16/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.


#import <Foundation/Foundation.h>

@interface EventBookInfoModel : NSObject

// Ticket info

@property(nonatomic,retain)NSString *firstNameTicketOwner;
@property(nonatomic,retain)NSString *lastNameTicketOwner;
@property(nonatomic,retain)NSString *QrCodeUrl;

// Event info
@property(nonatomic,retain)NSString *eventVenueName;
@property(nonatomic,retain)NSString *eventName;
@property(nonatomic,retain)NSString *eventStartDate;

@property(nonatomic,retain)NSString *eventEndDate;

@property(nonatomic,retain)NSString *eventDescription;

@property(nonatomic,retain)NSString *eventDistance;
@property(nonatomic,retain)NSString *eventLatitude;
@property(nonatomic,retain)NSString *eventLongitude;
@property(nonatomic,retain)NSString *eventImage;


@property(nonatomic,retain)NSString *eventStartDateModified;
@property(nonatomic,retain)NSString *eventStartTimeModified;
@property(nonatomic,retain)NSString *eventEndDateModified;
@property(nonatomic,retain)NSString *eventEndTimeModified;

@property(nonatomic,assign) BOOL isMoreNeeded;



+(EventBookInfoModel*) ticketsDetails:(NSDictionary*)dict;
+(EventBookInfoModel*) eventDetails:(NSDictionary*)dict;

@end


