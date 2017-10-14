//
//  FacebookLogin.h
//  UrgencyApp
//
//  Created by Raj Kumar Sharma on 16/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface FacebookLogin : NSObject 

+ (FacebookLogin *)sharedManager;

// facebook login
- (void)getFacebookInfoWithCompletionHandler:(UIViewController *)controller completionBlock:(void (^)(NSDictionary *infoDict, NSError *error))handler;

- (void)logOutFromFacebook;

@end
