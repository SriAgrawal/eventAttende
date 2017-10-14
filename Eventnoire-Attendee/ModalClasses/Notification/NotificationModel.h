//
//  NotificationModel.h
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 04/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationModel : NSObject
@property (strong, nonatomic) NSString   *notificationIDString;
@property (strong, nonatomic) NSString   *notificationSenderIDString;
@property (strong, nonatomic) NSString   *notificationReceiverIDString;
@property (strong, nonatomic) NSString   *notificationMessageString;
@property (strong, nonatomic) NSString   *notificationTypeString;

+(NotificationModel*) notificationDetails:(NSDictionary*)dict;


@end

