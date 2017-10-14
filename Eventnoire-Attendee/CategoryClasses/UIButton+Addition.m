//
//  UIButton+Addition.m
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 20/09/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "UIButton+Addition.h"
#import "Macro.h"

@implementation UIButton (Addition)

- (void)disable:(BOOL)status {
    
    if (status) {
        [self setBackgroundColor:[UIColor darkGrayColor]];
        [self setUserInteractionEnabled:NO];
    } else {
        [self setBackgroundColor:AppColor];
        [self setUserInteractionEnabled:YES];
    }
}

@end
