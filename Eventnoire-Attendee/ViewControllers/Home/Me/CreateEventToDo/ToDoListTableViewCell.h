//
//  ToDoListTableViewCell.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;

@end
