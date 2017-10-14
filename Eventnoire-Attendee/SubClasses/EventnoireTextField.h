//  EventnoireTextField.h
//  Eventnoire-Attendee
//  Created by Aiman Akhtar on 24/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import <UIKit/UIKit.h>

@interface EventnoireTextField : UITextField

@property (nonatomic, setter=setPaddingValue:) IBInspectable NSInteger paddingValue;
@property (nonatomic, strong) IBInspectable UIImage *paddingIcon;
@property (strong, nonatomic) NSIndexPath *indexPath; // use if cell for getting easily the cell & txtfield

- (void)placeHolderText:(NSString *)text;
- (void)placeHolderTextWithColor:(NSString *)text Color:(UIColor *)color;
- (void)setPlaceholderImage:(UIImage *)iconImage;
- (void)error:(BOOL)status;

@property (assign, nonatomic) BOOL active;

- (void)removeUnderLine;

@end
