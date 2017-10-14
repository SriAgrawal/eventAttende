//
//  AppDelegate.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 23/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController     *navigationController;
@property (nonatomic, assign) BOOL isReachable;
@property (nonatomic, strong) NSString *deviceToken;

//Location,latitude and longitude
@property (nonatomic, strong) CLLocation *location;
-(void)startLocationManager;
-(void)stopLocationManager;

//Navigation Flow
-(void)startWithLogin;
-(void)startWithLanding;

@end

