//
//  CountryCell.h
//  VendorApp
//
//  Created by Abhishek Agarwal on 07/04/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *flagImage;

@property (weak, nonatomic) IBOutlet UILabel *countryName;

@end
