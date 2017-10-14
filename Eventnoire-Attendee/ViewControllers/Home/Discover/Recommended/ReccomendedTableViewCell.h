//
//  ReccomendedTableViewCell.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 30/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventnoireButton.h"

@interface ReccomendedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@property (weak, nonatomic) IBOutlet EventnoireButton *shareButton;
@property (weak, nonatomic) IBOutlet EventnoireButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet EventnoireButton *favoriteButton;

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
