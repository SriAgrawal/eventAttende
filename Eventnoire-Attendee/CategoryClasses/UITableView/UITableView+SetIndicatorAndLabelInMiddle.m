//
//  UITableView+SetIndicatorAndLabelInMiddle.m
//  VendorApp
//
//  Created by Abhishek Agarwal on 04/03/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import "UITableView+SetIndicatorAndLabelInMiddle.h"

static NSInteger indicatorTag = 1000001;

@implementation UITableView (SetIndicatorAndLabelInMiddle)

-(void)startIndicatorInMiddleOfView {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.tag = indicatorTag;

    dispatch_async(dispatch_get_main_queue(), ^{
        spinner.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [spinner startAnimating];
    });
    
    [self addSubview:spinner];
}

-(void)setTextInMiddleOfView:(NSString *)responseMessage {
    
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,  self.bounds.size.height)];
    [noDataLabel setFont:[UIFont fontWithName:@"OpenSans" size:14.0]];
    noDataLabel.text             = responseMessage;
    noDataLabel.numberOfLines = 4;
    noDataLabel.textColor        = [UIColor darkGrayColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.backgroundView = noDataLabel;
}

-(void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self viewWithTag:indicatorTag];
        [spinner stopAnimating];
        
        [spinner removeFromSuperview];
    });
}

@end

