//
//  EventModal.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 31/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "NSDictionary+NullChecker.h"
#import "EventModal.h"
#import "Macro.h"

@implementation EventModal

+(EventModal*) parseEventDetail:(NSDictionary*)eventDetail {
    EventModal *eventModal = [EventModal new];
    
    eventModal.eventID = [eventDetail objectForKeyNotNull:pID expectedObj:[NSString string]];
    
    eventModal.eventName = [eventDetail objectForKeyNotNull:pTitle expectedObj:[NSString string]];
    eventModal.eventVenueName = [eventDetail objectForKeyNotNull:pVenueName expectedObj:[NSString string]];
    eventModal.eventDescription = [eventDetail objectForKeyNotNull:pDescription expectedObj:[NSString string]];
    eventModal.eventStartDateTimeStamp = [eventDetail objectForKeyNotNull:pStartDate expectedObj:[NSString string]];
    eventModal.eventEndDateTimeStamp = [eventDetail objectForKeyNotNull:pEndDate expectedObj:[NSString string]];
    
    //Getting date component
    [eventModal gettingDateComponentFromDate];
    
    eventModal.eventImagePathURL = [eventDetail objectForKeyNotNull:pImageURL expectedObj:[NSString string]];
 eventModal.eventTotalTickets = [eventDetail objectForKeyNotNull:pNo_of_ticket expectedObj:[NSString string]];
    eventModal.eventAddress1 = [eventDetail objectForKeyNotNull:pAddress expectedObj:[NSString string]];
    eventModal.eventAddress2 = [eventDetail objectForKeyNotNull:pAddress2 expectedObj:[NSString string]];
    eventModal.eventCity = [eventDetail objectForKeyNotNull:pCity expectedObj:[NSString string]];
    eventModal.eventState = [eventDetail objectForKeyNotNull:pState expectedObj:[NSString string]];
    eventModal.eventZipCode = [eventDetail objectForKeyNotNull:pZipCode expectedObj:[NSString string]];
    eventModal.eventCountryCode = [eventDetail objectForKeyNotNull:pCountryCode expectedObj:[NSString string]];
    
    eventModal.eventLatitutde = [eventDetail objectForKeyNotNull:pLatitude expectedObj:[NSString string]];
    eventModal.eventLongitude = [eventDetail objectForKeyNotNull:pLongitude expectedObj:[NSString string]];
    
    eventModal.eventDistanceType = [eventDetail objectForKeyNotNull:pDistanceIn expectedObj:[NSString string]];
    eventModal.eventDistance = [NSString stringWithFormat:@"%.2f %@",[[eventDetail objectForKeyNotNull:pDistance expectedObj:[NSString string]] floatValue],eventModal.eventDistanceType];

    eventModal.eventCategory = [eventDetail objectForKeyNotNull:pCategoryName expectedObj:[NSString string]];
    eventModal.eventSubCategory = [eventDetail objectForKeyNotNull:pEventType expectedObj:[NSString string]];

    eventModal.eventTicketType = [eventDetail objectForKeyNotNull:pTicketType expectedObj:[NSString string]];
    eventModal.eventTicketCountry = [eventDetail objectForKeyNotNull:pCountryName expectedObj:[NSString string]];
    eventModal.eventTicketCurrency = [eventDetail objectForKeyNotNull:pAmountCurrency expectedObj:[NSString string]];
    eventModal.eventTicketAmount = [eventDetail objectForKeyNotNull:pTicketAmount expectedObj:[NSString string]];
    
    eventModal.isBookmarked = [[eventDetail objectForKeyNotNull:pIsBookmarked expectedObj:[NSString string]] boolValue];
    eventModal.isFavourite = [[eventDetail objectForKeyNotNull:pIsFavourite expectedObj:[NSString string]] boolValue];

    eventModal.eventShareLink = [eventDetail objectForKeyNotNull:pShareEvent expectedObj:[NSString string]];

    eventModal.ticketInfoArray = [NSMutableArray array];
    
    NSArray *ticketArray = [eventDetail objectForKeyNotNull:pTicketInfo expectedObj:[NSArray array]];

    for (NSDictionary *ticketDict in ticketArray)
        [eventModal.ticketInfoArray addObject:[TicketModal parseTicketDetail:ticketDict]];
    
    return eventModal;
}

-(void)gettingDateComponentFromDate {
 
     
    
    NSDate * startDate = [NSDate dateWithTimeIntervalSince1970:[self.eventStartDateTimeStamp integerValue]];
    NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:[self.eventEndDateTimeStamp integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    self.eventStartDay = [dateFormatter stringFromDate:startDate];
    self.eventEndDay = [dateFormatter stringFromDate:endDate];
    
    [dateFormatter setDateFormat:@"dd"];

     NSString *eventStartDate = [dateFormatter stringFromDate:startDate];
     NSString *eventEndDate = [dateFormatter stringFromDate:endDate];

    if ([eventStartDate isEqualToString:eventEndDate]) {
        self.eventDateRange = [NSString stringWithFormat:@"%@",eventEndDate];
    }else
        self.eventDateRange = [NSString stringWithFormat:@"%@ - %@",eventStartDate,eventEndDate];

    [dateFormatter setDateFormat:@"MMM"];

    self.eventStartMonth = [dateFormatter stringFromDate:startDate];
    self.eventEndMonth = [dateFormatter stringFromDate:endDate];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    self.eventStartTime = [dateFormatter stringFromDate:startDate];
    self.eventEndTime = [dateFormatter stringFromDate:endDate];
    
    [dateFormatter setDateFormat:@"dd MMM yyyy"];

    self.eventStartDateString = [dateFormatter stringFromDate:startDate];
    self.eventEndDateString = [dateFormatter stringFromDate:endDate];
}

-(NSArray *)generateTicketInfo {
    NSMutableArray *ticketInfoArray = [NSMutableArray array];
    
    for (TicketModal *ticketInfo in self.ticketInfoArray) {
        NSMutableDictionary *ticketDict = [NSMutableDictionary dictionary];
        
        [ticketDict setValue:ticketInfo.ticketID forKey:pID];
        [ticketDict setValue:ticketInfo.ticketName forKey:pName];
        [ticketDict setValue:ticketInfo.ticketTotalSeat forKey:pTotalSeats];
        [ticketDict setValue:ticketInfo.ticketRemainingSeats forKey:pRemainingSeats];
        
        [ticketDict setValue:ticketInfo.ticketAmount forKey:pAmount];
        [ticketDict setValue:ticketInfo.ticketStatus forKey:pStatus];
        [ticketDict setValue:ticketInfo.bookSeats forKey:pTicketQuantity];
        [ticketDict setValue:ticketInfo.ticketType forKey:pType];

        [ticketInfoArray addObject:ticketDict];
    }
    
    return [ticketInfoArray mutableCopy];
}

@end

@implementation TicketModal

+(TicketModal*) parseTicketDetail:(NSDictionary*)ticketDetail {
    TicketModal *ticketModal = [TicketModal new];
    
    ticketModal.ticketID = [ticketDetail objectForKeyNotNull:pID expectedObj:[NSString string]];
    ticketModal.ticketName = [ticketDetail objectForKeyNotNull:pName expectedObj:[NSString string]];
    ticketModal.ticketTotalSeat = [ticketDetail objectForKeyNotNull:pTotalSeats expectedObj:[NSString string]];
    ticketModal.ticketRemainingSeats = [ticketDetail objectForKeyNotNull:pRemainingSeats expectedObj:[NSString string]];
    ticketModal.ticketAmount = [ticketDetail objectForKeyNotNull:pAmount expectedObj:[NSString string]];
    ticketModal.ticketStatus = [ticketDetail objectForKeyNotNull:pStatus expectedObj:[NSString string]];
    ticketModal.ticketType = [ticketDetail objectForKeyNotNull:pType expectedObj:[NSString string]];
    ticketModal.tQuantity = [ticketDetail objectForKeyNotNull:pTicketQuantity expectedObj:[NSString string]];
    ticketModal.bookSeats = @"0";
    
    return ticketModal;
}

@end
