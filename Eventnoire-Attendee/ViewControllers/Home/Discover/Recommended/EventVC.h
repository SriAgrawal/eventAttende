//
//  EventVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 31/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventModal;

typedef enum : NSUInteger {
    History,
    Interest,
    Saved,
    General
} EventViewType;

@interface EventVC : UIViewController

@property (strong, nonatomic) EventModal *eventDetailModal;

@property (assign) EventViewType eventViewType;

@end
