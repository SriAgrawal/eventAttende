//
//  ReccomendedTableViewCell.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 30/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "ReccomendedTableViewCell.h"

@implementation ReccomendedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.categoryLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.subTypeLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
