//
//  EventToDoModel.h
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 04/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventToDoModel : NSObject

@property (strong, nonatomic) NSString   *eventNameString;
@property (strong, nonatomic) NSString   *eventIDString;
@property (strong, nonatomic) NSString   *eventLocationString;
@property (strong, nonatomic) NSString   *eventDateString;
@property (strong, nonatomic) NSString   *eventTimeString;
@property (strong, nonatomic) NSString   *eventDetailString;
@property (strong, nonatomic) NSString   *createdTimeString;

+(EventToDoModel*) eventToDoDetails:(NSDictionary*)dict;
+(EventToDoModel*) eventListForUser:(NSDictionary*)dict;


@end


