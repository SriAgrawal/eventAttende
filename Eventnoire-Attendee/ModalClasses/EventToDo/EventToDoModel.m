//
//  EventToDoModel.m
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 04/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "Header.h"

@implementation EventToDoModel

+(EventToDoModel*) eventToDoDetails:(NSDictionary*)dict{
    EventToDoModel *objInfo = [[EventToDoModel alloc] init];
    objInfo.eventNameString  = [dict objectForKeyNotNull:pEventName expectedObj:@""];
    objInfo.eventIDString  = [dict objectForKeyNotNull:pEventId expectedObj:@""];
    objInfo.eventLocationString  = [dict objectForKeyNotNull:pEventLocation expectedObj:@""];
    objInfo.eventDateString  = [dict objectForKeyNotNull:pEventDate expectedObj:@""];
    objInfo.eventTimeString  = [dict objectForKeyNotNull:pEventTime expectedObj:@""];
    objInfo.eventDetailString  = [dict objectForKeyNotNull:pEventDetail expectedObj:@""];
    objInfo.createdTimeString  = [dict objectForKeyNotNull:pCreatedTime expectedObj:@""];

    
    return objInfo;

}

+(EventToDoModel*) eventListForUser:(NSDictionary*)dict{
    EventToDoModel *objInfo = [[EventToDoModel alloc] init];
    objInfo.eventNameString  = [dict objectForKeyNotNull:pEventTitle expectedObj:@""];
    objInfo.eventIDString  = [dict objectForKeyNotNull:pEventId expectedObj:@""];
    return objInfo;

    
}

@end
