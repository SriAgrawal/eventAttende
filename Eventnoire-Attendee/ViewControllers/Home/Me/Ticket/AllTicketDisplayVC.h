//
//  AllTicketDisplayVC.h
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 18/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModal.h"

@interface AllTicketDisplayVC : UIViewController
@property (nonatomic,assign) BOOL isFromPayment;
@property(nonatomic,retain)EventModal *eventModelData;

@end
