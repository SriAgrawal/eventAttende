//
//  UIViewController+Addition.h
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Addition)

- (void)moveUIComponentWithValue:(CGFloat)value forLayoutConstraint:(NSLayoutConstraint *)layoutConstraint forDuration:(CGFloat)duration;
- (UIToolbar *)getToolBarForNumberPad;
- (UIToolbar *)getToolBarForNumberPad:(id)controller andTitle:(NSString *)titleDoneOrNext type:(UITextField *)textfield;
@end
