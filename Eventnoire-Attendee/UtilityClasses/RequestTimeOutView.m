//
//  RequestTimeOutView.h
//  Openia
//
//  Created by Sunil Verma on 11/03/16.
//  Copyright © 2016 Mobiloitte Inc. All rights reserved.
//

#import "RequestTimeOutView.h"

static BOOL isTimeOutViewShown;
static NSUInteger kTimeOutViewTag =33411;

NSString *messageText =@"You receive a \"Request timed out\" error message, Please try again. If you facing this problem continuously please contact to our support.";

@implementation RequestTimeOutView


+ (BOOL)isShown
{
    return isTimeOutViewShown;
}

+ (void)show
{
    [RequestTimeOutView showWithMessage:messageText forTime:0];
}

+ (void)showWithMessage:(NSString *)message forTime:(NSInteger)timeInterval;
{
    [RequestTimeOutView showWithMessage:message forTime:timeInterval textAlignment:NSTextAlignmentCenter];
}

+ (void)showWithMessage:(NSString *)message forTime:(NSInteger)timeInterval textAlignment:(NSTextAlignment)textAlignment
{
  
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIView *timeOutView = [keyWindow viewWithTag:kTimeOutViewTag];
    
    if (!timeOutView) {
    
        isTimeOutViewShown = NO;
    }
    
    if (!isTimeOutViewShown) {
    
        isTimeOutViewShown = YES;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
        containerView.tag = kTimeOutViewTag;
        
        [keyWindow addSubview:containerView];
        UILabel *noNetworkLbl = [[UILabel alloc]init];
        
        NSString *text = messageText;
        if (message) {
            text = message;
        }
        
        [noNetworkLbl setText:text];
        
        [noNetworkLbl setTextAlignment:textAlignment];
        noNetworkLbl.lineBreakMode = NSLineBreakByWordWrapping;
        [noNetworkLbl setFont:[UIFont italicSystemFontOfSize:14]];
        [noNetworkLbl setNumberOfLines:0];
        [noNetworkLbl setTextColor:[UIColor blackColor]];
        [containerView addSubview:noNetworkLbl];
        
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = noNetworkLbl.lineBreakMode;
        
        NSDictionary *attributes = @{NSFontAttributeName :noNetworkLbl.font,
                                     NSParagraphStyleAttributeName: paragraph};
        
        CGRect textSize =
        [text boundingRectWithSize:CGSizeMake(290.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        
        containerView.frame = CGRectMake(0, 0, 300, textSize.size.height + 10);
        
        noNetworkLbl.frame = CGRectMake(5, 5, CGRectGetWidth(containerView.frame) -10, CGRectGetHeight(containerView.frame)-10);
        
        containerView.center = keyWindow.center;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        
        [containerView addGestureRecognizer:tapGesture];
        
        containerView.layer.cornerRadius = 8.0f;
        containerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(3, 3);
        containerView.layer.shadowRadius = 3;
        containerView.layer.shadowOpacity = 0.8f;
        
        [keyWindow bringSubviewToFront:containerView];
        [containerView setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]];
        if (timeInterval > 0) {
            [self performSelector:@selector(hide) withObject:nil afterDelay:timeInterval];
        }
    }
}


+(void)tapAction:(id)sender
{
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    isTimeOutViewShown = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        UIView *timeOutView = [keyWindow viewWithTag:kTimeOutViewTag];
        if (timeOutView) {
            
            [timeOutView setAlpha:0.0];

        }
        
    }completion:^(BOOL finished) {
        
        UIView *timeOutView = [keyWindow viewWithTag:kTimeOutViewTag];

        if (timeOutView) {
            
            [[keyWindow viewWithTag:kTimeOutViewTag] removeFromSuperview];
        }
    }];
}


+ (void)hide
{
    isTimeOutViewShown = NO;
    
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *timeOutView = [keyWindow viewWithTag:kTimeOutViewTag];

    if (timeOutView) {
        [RequestTimeOutView tapAction:nil];
    }
}


@end
