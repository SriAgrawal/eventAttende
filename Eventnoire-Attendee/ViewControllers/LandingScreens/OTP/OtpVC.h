//
//  OtpVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 28/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneNumberVerificationProcessComplete <NSObject>

-(void)dismissAfterCompletePhoneVerification;

@end
@interface OtpVC : UIViewController

@property (strong, nonatomic) NSString *phoneNumber;
@property (assign, nonatomic) BOOL isBackButtonRequired;

@property (weak, nonatomic) id<PhoneNumberVerificationProcessComplete> backDelegate;
@end
