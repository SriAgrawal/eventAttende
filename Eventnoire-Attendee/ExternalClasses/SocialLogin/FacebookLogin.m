//
//  FacebookLogin.m
//  UrgencyApp
//
//  Created by Raj Kumar Sharma on 16/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "FacebookLogin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation FacebookLogin

+ (FacebookLogin *)sharedManager {
    
    static FacebookLogin *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[FacebookLogin alloc] init];
    });
    return _sharedManager;
}

#pragma mark - Facebook methods

// This method will handle ALL the session state changes in the app

- (void)getFacebookInfoWithCompletionHandler:(UIViewController *)controller completionBlock:(void (^)(NSDictionary *infoDict, NSError *error))handler {
    
    [self callFacebookLoginWithCompletionBlock:controller completionBlock:^(NSDictionary *infoDict, NSError *error) {
        handler(infoDict, error);
    }];
    
}

- (void)callFacebookLoginWithCompletionBlock:(UIViewController *)controller completionBlock:(void (^)(NSDictionary *infoDict, NSError *error))handler {
//    /picture.type(large)
    NSMutableDictionary *requsetDict = [NSMutableDictionary dictionary];
    [requsetDict setValue:@"id,name,first_name,last_name,gender,email,birthday,picture.type(large)" forKey:@"fields"];
    //[requsetDict setValue:@"locale" forKey:@"en_US"];
    
    if ([FBSDKAccessToken currentAccessToken]) {
       // [self progressHud:YES];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:requsetDict]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             //[self progressHud:NO];
             handler(result,error);
         }];
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        
        [loginManager logInWithReadPermissions:[NSArray arrayWithObjects:@"email", @"public_profile", @"user_photos",@"user_friends", nil] fromViewController:controller handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            if (error) {
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Processing Error. Please try again!" forKey:NSLocalizedDescriptionKey];
                
                NSError *errorCustom = [NSError errorWithDomain:@"Processing Error!" code:error.code userInfo:errorDetails];
                handler(nil,errorCustom);
                
                [self logOutFromFacebook];
                
            } else if (result.isCancelled) {
                
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Request cancelled!" forKey:NSLocalizedDescriptionKey];
                NSError *errorCustom = [NSError errorWithDomain:@"Request cancelled!" code:2009 userInfo:errorDetails];
                handler(nil,errorCustom);
                
                [self logOutFromFacebook];
                
            } else {
                
                //[self progressHud:YES];
                //Getting Basic data from facebook
                [FBSDKAccessToken setCurrentAccessToken:result.token];
                if ([FBSDKAccessToken currentAccessToken]) {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:requsetDict]
                     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         //[self progressHud:NO];
                         handler(result,error);
                     }];
                }
            }
            
        }];
    }
}

- (void)logOutFromFacebook {
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
}

//#pragma mark - Private Methods
//
//- (void)progressHud:(BOOL)status {
//    
//    if (status) {
////        [MBProgressHUD hideAllHUDsForView:[APPDELEGATE window] animated:YES];
//        //            [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] withText:@"Please wait..." animated:YES];
//        
//        [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
//
//        
//    } else {
//        
//        [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
//    }
//}

@end
