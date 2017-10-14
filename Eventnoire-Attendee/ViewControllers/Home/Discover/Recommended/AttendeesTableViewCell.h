//
//  AttendeesTableViewCell.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendeesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *detailTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectPrefix;

@end
