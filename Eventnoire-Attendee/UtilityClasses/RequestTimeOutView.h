//
//  RequestTimeOutView.h
//  Openia
//
//  Created by Sunil Verma on 11/03/16.
//  Copyright © 2016 Mobiloitte Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestTimeOutView : UIView
+ (BOOL)isShown;

+ (void)show;
+ (void)showWithMessage:(NSString *)message forTime:(NSInteger)timeInterval;
+ (void)showWithMessage:(NSString *)message forTime:(NSInteger)timeInterval textAlignment:(NSTextAlignment)textAlignment;

+ (void)hide;
@end
