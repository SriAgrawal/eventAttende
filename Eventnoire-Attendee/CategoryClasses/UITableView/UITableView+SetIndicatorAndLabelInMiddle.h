//
//  UITableView+SetIndicatorAndLabelInMiddle.h
//  VendorApp
//
//  Created by Abhishek Agarwal on 04/03/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SetIndicatorAndLabelInMiddle)

//Show Indicator In Middle of Table View
-(void)startIndicatorInMiddleOfView;

//Remove Indicator
-(void)stopIndicator;

//Add Text In Middle of Table View
-(void)setTextInMiddleOfView:(NSString *)responseMessage;

@end
