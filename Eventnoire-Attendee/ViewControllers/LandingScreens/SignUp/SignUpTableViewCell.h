//
//  SignUpTableViewCell.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 27/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventnoireTextField.h"

@interface SignUpTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EventnoireTextField *signUpTextField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectCountryBtn;

@end
