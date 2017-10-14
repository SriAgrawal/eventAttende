//
//  NotificationModel.m
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 04/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "Header.h"

@implementation NotificationModel

+(NotificationModel*) notificationDetails:(NSDictionary*)dict{
    NotificationModel *objInfo = [[NotificationModel alloc] init];
    objInfo.notificationIDString  = [dict objectForKeyNotNull:pNotificationId expectedObj:@""];
    objInfo.notificationSenderIDString  = [dict objectForKeyNotNull:pSenderId expectedObj:@""];
    objInfo.notificationReceiverIDString  = [dict objectForKeyNotNull:pReceiverId expectedObj:@""];
    objInfo.notificationMessageString  = [dict objectForKeyNotNull:pNotificationMessage expectedObj:@""];
    objInfo.notificationTypeString  = [dict objectForKeyNotNull:pNotificationType expectedObj:@""];
    
    return objInfo;

}

@end
