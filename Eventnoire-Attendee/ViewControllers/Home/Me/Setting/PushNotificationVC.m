//
//  PushNotificationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 04/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "PushNotificationVC.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "ServiceHelper.h"
#import "Macro.h"

@interface PushNotificationVC ()

@property (weak, nonatomic) IBOutlet UISwitch *announcementSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *friendUpdateSwitch;

@property (weak, nonatomic) IBOutlet UIView *friendUpdateView;

@end

@implementation PushNotificationVC

#pragma mark - UIViewController life cycle & memory management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton action Methods

- (void) initialSetup {
    NSDictionary *userDetail = [NSUSERDEFAULT valueForKey:pUserDetail];
	
	
	if ([[userDetail objectForKeyNotNull:pLogInType expectedObj:@""] isEqualToString:@"facebook"])
		self.friendUpdateView.hidden = NO;
	else
		self.friendUpdateView.hidden = YES;

	
    BOOL announcementStatus = [[userDetail objectForKeyNotNull:pIsAnouncement expectedObj:[NSString string]] boolValue];
    
    BOOL friendStatus = [[userDetail objectForKeyNotNull:pIsFriendUpdate expectedObj:[NSString string]] boolValue];
    
    [self.announcementSwitch setOn:announcementStatus];
    [self.friendUpdateSwitch setOn:friendStatus];


}

#pragma mark - UIButton action Methods

- (IBAction)announcementSwitchButtonAction:(UISwitch *)sender {
    [self statusOfAnnouncement:sender.on];
}


- (IBAction)friendsUpdateSwitchButtonAction:(UISwitch *)sender {
    [self statusOfFriendUpdate:sender.on];
}


- (IBAction)backButtonACtion:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Service Implemention

-(void)statusOfAnnouncement:(BOOL)status {
    
    NSMutableDictionary *announementStatusDict = [NSMutableDictionary new];
    [announementStatusDict setValue:[NSString stringWithFormat:@"%d",status] forKey:pIsAnouncement];
    
    [self apiCallForchangeNotificationStatus:announementStatusDict andServiceName:updateNotificationApi];
}

-(void)statusOfFriendUpdate:(BOOL)status {
    
    NSMutableDictionary *announementStatusDict = [NSMutableDictionary new];
    [announementStatusDict setValue:[NSString stringWithFormat:@"%d",status] forKey:pIsFriendUpdate];
    
    [self apiCallForchangeNotificationStatus:announementStatusDict andServiceName:updateNotificationApi];
}

-(void)apiCallForchangeNotificationStatus:(NSMutableDictionary *)announcementDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:announcementDict apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        if (!error) {
            //Success and 200 responseCode
            NSMutableDictionary *userDetailDict = [[NSUSERDEFAULT valueForKey:pUserDetail] mutableCopy];
            [NSUSERDEFAULT removeObjectForKey:pUserDetail];
            
            NSDictionary *responseData = [result objectForKeyNotNull:pUserDetail expectedObj:[NSDictionary dictionary]];
            
            [userDetailDict setValue:[responseData objectForKeyNotNull:pIsAnouncement expectedObj:[NSString string]] forKey:pIsAnouncement];
            
            [userDetailDict setValue:[responseData objectForKeyNotNull:pIsFriendUpdate expectedObj:[NSString string]] forKey:pIsFriendUpdate];
            
            [NSUSERDEFAULT setValue:userDetailDict forKey:pUserDetail];
            
        }else if (error.code == 100) {
            //Success but other than 200 responseCode
            NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }else {
            //Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }
    }];
}


@end
