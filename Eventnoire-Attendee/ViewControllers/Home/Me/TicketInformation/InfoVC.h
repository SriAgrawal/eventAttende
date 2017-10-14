//
//  InfoVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModal.h"

@interface InfoVC : UIViewController
@property(nonatomic,retain)EventModal *eventModelData;
@property(nonatomic, assign) NSInteger selectedIndex;

@end
