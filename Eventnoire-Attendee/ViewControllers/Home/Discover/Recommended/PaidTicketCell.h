//
//  PaidTicketCell.h
//  Eventnoire-Attendee
//
//  Created by Abhishek Agarwal on 17/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventnoireButton.h"

@interface PaidTicketCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ticketName;
@property (weak, nonatomic) IBOutlet EventnoireButton *bookedButton;
@property (weak, nonatomic) IBOutlet UILabel *ticketPriceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *dropDownImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowDownWidth;
@end
