//
//  AppDelegate.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 23/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import "AppDelegate.h"
#import "TutorialVC.h"
#import "Macro.h"
#import "HomeVC.h"
#import "LoginVC.h"
#import "TicketInformationVC.h"
#import "PersonalizeVC.h"
#import "Reachability.h"
#import "RegistrationVC.h"
#import <Stripe/Stripe.h>

@import GooglePlaces;
@import GoogleMaps;

@interface AppDelegate ()<UNUserNotificationCenterDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    //facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //google sign In
    [GIDSignIn sharedInstance].clientID = @"9819598811-ccg4b33elbi4o9520bh0g4i7l3ao8beh.apps.googleusercontent.com";
    
    //twitter
    [Fabric with:@[[Twitter class]]];

    //GooglePlace
    [GMSPlacesClient provideAPIKey:@"AIzaSyBmRSkjUGg1ApRs_-zLMRNeYGhv0RZbD7I"];

    //GoogleMap
    [GMSServices provideAPIKey:@"AIzaSyDzCmPLTZLKlLRxvCMFqO8S63wGKaGhE-g"];
    
    [self registerForRemoteNotification];
    
    [self checkReachability];
    
    [self createLocationManager];
    
    if ([[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pInterestData] boolValue]) {
        //First Screen Home
        [self startWithLanding];
        
    }else if ([[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pToken] length] && [[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pIsPhoneNumberVerify] boolValue] && ![[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pInterestData] boolValue]) {
        //First Screen Home
        [self startWithPersonalize];
        
    }
    else if ([[NSUSERDEFAULT valueForKey:iSTutorialSeen] boolValue]) {
        //First Screen Login
        [self startWithLogin];
        
    }else {
        //First Screen tutorial
        TutorialVC *tutorialVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TutorialVC"];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:tutorialVC];
        self.navigationController.navigationBarHidden = YES;
        
        self.window.rootViewController = self.navigationController;
    }

    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@"pk_live_2CcAGdDL6jGzMM37WKJ19lXc"];

    
//    for (NSString *familyName in [UIFont familyNames]){
//        NSLog(@"Family name: %@", familyName);
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
//            NSLog(@"--Font name: %@", fontName);
//        }
//    }
    return YES;
}


#pragma mark - Navigation Control

-(void)startWithLogin {
    LoginVC *loginVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
}

-(void)startWithLanding {
    HomeVC *homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
}

-(void)startWithPersonalize {
    
    PersonalizeVC *personalizeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:personalizeVC];
    self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
}

#pragma mark - REGISTER METHOD FOR NOTIFICATION

-(void)registerForRemoteNotification {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    BOOL isVersionLessThan10 =  ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] == NSOrderedAscending);
    
    if( isVersionLessThan10)
    {
        if (([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert |
                                                                                                                                  UIUserNotificationTypeBadge |
                                                                                                                                  UIUserNotificationTypeSound) categories:nil]];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 //Push registration success.
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
}


#pragma mark - Get Device Token After register

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.deviceToken = token;
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    self.deviceToken = @"deviceToken";
}

#pragma mark - Check Reachability

-(void)checkReachability {
    
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    self.isReachable = [reach isReachable];
    reach.reachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = NO;
        });
    };
    
    
    [reach startNotifier];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    if ([url.absoluteString containsString:@"fb"])
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                              openURL:url
                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    else {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
}

#pragma mark - CLLocation manager Delegate Methods

-(void)createLocationManager {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

-(void)startLocationManager {
    [locationManager startUpdatingLocation];
}

-(void)stopLocationManager {
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //New Location
    self.location = newLocation;
    
    //[locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                               message:@"To re-enable, please go to Settings and turn on Location Services for this app."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [alert show];
        }
    }
   // [locationManager stopUpdatingLocation];
}

@end
