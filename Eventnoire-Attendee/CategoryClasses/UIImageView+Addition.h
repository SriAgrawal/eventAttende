//
//  UIImageView+Addition.h
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Addition)

@property (assign, nonatomic) IBInspectable UIColor *iconColor;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size;

- (void)color:(UIColor *)color;

@end
