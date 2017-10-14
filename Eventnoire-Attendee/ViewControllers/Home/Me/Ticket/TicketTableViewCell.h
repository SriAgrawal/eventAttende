//
//  TicketTableViewCell.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventscheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTicketLabel;

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@end
