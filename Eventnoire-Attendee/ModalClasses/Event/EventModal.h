//  EventModal.h
//  Eventnoire-Attendee
//  Created by Aiman Akhtar on 31/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import <Foundation/Foundation.h>

@interface EventModal : NSObject

@property (strong, nonatomic) NSString   *eventID;
@property (strong, nonatomic) NSString   *eventName;
@property (strong, nonatomic) NSString   *eventVenueName;
@property (strong, nonatomic) NSString   *eventDescription;

@property (strong, nonatomic) NSString   *eventStartDateTimeStamp;
@property (strong, nonatomic) NSString   *eventEndDateTimeStamp;
@property (strong, nonatomic) NSString   *eventEndDateString;
@property (strong, nonatomic) NSString   *eventStartDateString;

@property (strong, nonatomic) NSString   *eventStartMonth;
@property (strong, nonatomic) NSString   *eventEndMonth;
@property (strong, nonatomic) NSString   *eventDateRange;
@property (strong, nonatomic) NSString   *eventStartDay;
@property (strong, nonatomic) NSString   *eventEndDay;
@property (strong, nonatomic) NSString   *eventStartTime;
@property (strong, nonatomic) NSString   *eventEndTime;

@property (strong, nonatomic) NSString   *eventImagePathURL;

@property (strong, nonatomic) NSString   *eventAddress1;
@property (strong, nonatomic) NSString   *eventAddress2;
@property (strong, nonatomic) NSString   *eventCity;
@property (strong, nonatomic) NSString   *eventState;
@property (strong, nonatomic) NSString   *eventZipCode;
@property (strong, nonatomic) NSString   *eventCountryCode;

@property (strong, nonatomic) NSString   *eventLatitutde;
@property (strong, nonatomic) NSString   *eventLongitude;
@property (strong, nonatomic) NSString   *eventDistance;
@property (strong, nonatomic) NSString   *eventDistanceType;

@property (strong, nonatomic) NSString   *eventCategory;
@property (strong, nonatomic) NSString   *eventSubCategory;

@property (strong, nonatomic) NSString   *eventTicketType;
@property (strong, nonatomic) NSString   *eventTicketAmount;
@property (strong, nonatomic) NSString   *eventTicketCountry;
@property (strong, nonatomic) NSString   *eventTicketCurrency;
@property (strong, nonatomic) NSString   *eventTotalTickets;


@property (assign, nonatomic) BOOL   isBookmarked;
@property (assign, nonatomic) BOOL   isFavourite;

@property (strong, nonatomic) NSString   *eventShareLink;

@property (strong, nonatomic) NSMutableArray *ticketInfoArray;

@property (strong, nonatomic) NSString   *attendeePrefix;
@property (strong, nonatomic) NSString   *jobTitle;
@property (strong, nonatomic) NSString   *organizationOrCompanyName;

+(EventModal*) parseEventDetail:(NSDictionary*)eventDetail;
-(NSArray *)generateTicketInfo;

@end

@interface TicketModal : NSObject

@property (strong , nonatomic) NSString *ticketID;
@property (strong , nonatomic) NSString *ticketName;
@property (strong , nonatomic) NSString *ticketTotalSeat;
@property (strong , nonatomic) NSString *ticketRemainingSeats;
@property (strong , nonatomic) NSString *ticketAmount;
@property (strong , nonatomic) NSString *ticketType;
@property (strong , nonatomic) NSString *tQuantity;

@property (strong , nonatomic) NSString *ticketStatus;
@property (strong , nonatomic) NSString *bookSeats;

+(TicketModal*) parseTicketDetail:(NSDictionary*)ticketDetail;

@end
