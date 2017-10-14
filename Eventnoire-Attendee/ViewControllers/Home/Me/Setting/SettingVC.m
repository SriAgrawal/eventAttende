//
//  SettingVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "NSDictionary+NullChecker.h"
#import "SettingTableViewCell.h"
#import "StaticDataContentVC.h"
#import "PushNotificationVC.h"
#import "RequestTimeOutView.h"
#import "CreateEventToDoVC.h"
#import "ChangePasswordVC.h"
#import "AppDelegate.h"
#import "ServiceHelper.h"
#import "AlertView.h"
#import "SettingVC.h"
#import "LoginVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"SettingTableViewCell";
static NSString *pSettingTitle = @"title";
static NSString *pIcon = @"icon";

@interface SettingVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSString *loginType;
}

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) NSArray *dataSourceArray;

@end

@implementation SettingVC

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

#pragma mark - Helper Method

- (void) initialSetup {
    //Initialise array
    
    NSDictionary *userInfoDict = [NSUSERDEFAULT valueForKey:pUserDetail];
    loginType = [userInfoDict objectForKey:pLogInType];
    if ([loginType isEqualToString:@"normal"]) {
        self.dataSourceArray = @[
                                 @{pSettingTitle : @"Push Notifications", pIcon: @"ic3"},
                                 @{pSettingTitle : @"Share On Social Media", pIcon: @"ic4"},
                                 @{pSettingTitle : @"About Us", pIcon: @"ic5"},
                                 @{pSettingTitle : @"Contact Us", pIcon: @"ic6"},
                                 @{pSettingTitle : @"Privacy Policy", pIcon: @"ic7"},
                                 @{pSettingTitle : @"Terms & Conditions", pIcon: @"ic8"},
                                 @{pSettingTitle : @"Talk To Us", pIcon: @"ic9"},
                                 @{pSettingTitle : @"Event To Do", pIcon: @"ic1"},
                                 @{pSettingTitle : @"Change Password", pIcon: @"ic7"},
                                 @{pSettingTitle : @"Logout", pIcon: @"logout"}
                                 ];
 
    }else{
        self.dataSourceArray = @[
                                 @{pSettingTitle : @"Push Notifications", pIcon: @"ic3"},
                                 @{pSettingTitle : @"Share On Social Media", pIcon: @"ic4"},
                                 @{pSettingTitle : @"About Us", pIcon: @"ic5"},
                                 @{pSettingTitle : @"Contact Us", pIcon: @"ic6"},
                                 @{pSettingTitle : @"Privacy Policy", pIcon: @"ic7"},
                                 @{pSettingTitle : @"Terms & Conditions", pIcon: @"ic8"},
                                 @{pSettingTitle : @"Talk To Us", pIcon: @"ic9"},
                                 @{pSettingTitle : @"Event To Do", pIcon: @"ic1"},
                                 @{pSettingTitle : @"Logout", pIcon: @"logout"}
                                 ];
 
    }
    
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *dataDict = [self.dataSourceArray objectAtIndex:indexPath.row];
    [cell.titleImageView setImage:[UIImage imageNamed:[dataDict valueForKey:pIcon]]];
    cell.titleLabel.text = [dataDict valueForKey:pSettingTitle];
    
    if ([loginType isEqualToString:@"normal"]) {
        cell.arrowImageView.hidden = (indexPath.row == 9)?YES:NO;
    }else{
        cell.arrowImageView.hidden = (indexPath.row == 8)?YES:NO;
  
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
        {
            PushNotificationVC *notificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PushNotificationVC"];
            [self.navigationController pushViewController:notificationVC animated:YES];
        }
            break;
            
        case 1:
        {
            NSString *textToShare = @"Eventnoir-Attendee!";
            NSURL *myWebsite = [NSURL URLWithString:@"http://www.eventnoire.com/"];
            
            NSArray *objectsToShare = @[textToShare, myWebsite];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList
                                           ];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            break;
            
        case 2:
        {
            StaticDataContentVC *staticDataVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticDataContentVC"];
            staticDataVC.contentType = About_Us;
            [self.navigationController pushViewController:staticDataVC animated:YES];
        }
            break;
        case 3:
        {
            StaticDataContentVC *staticDataVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticDataContentVC"];
            staticDataVC.contentType = Contact_Us;
            [self.navigationController pushViewController:staticDataVC animated:YES];
        }
            break;
            
        case 4 :
        {
            StaticDataContentVC *staticDataVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticDataContentVC"];
            staticDataVC.contentType = Privacy_Policy;
            [self.navigationController pushViewController:staticDataVC animated:YES];
        }
            break;
            
        case 5:
        {
            StaticDataContentVC *staticDataVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticDataContentVC"];
            staticDataVC.contentType = Terms_and_Conditions;
            [self.navigationController pushViewController:staticDataVC animated:YES];
        }
            break;
    
        case 6:
        {
            StaticDataContentVC *staticDataVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticDataContentVC"];
            staticDataVC.contentType = Talk_To_Us;
            [self.navigationController pushViewController:staticDataVC animated:YES];
            
        }
            break;
            
        case 7:
        {
            CreateEventToDoVC *createEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventToDoVC"];
            [self.navigationController pushViewController:createEventVC animated:YES];
        }
            break;
        case 8:
        {
            if ([loginType isEqualToString:@"normal"]) {
                ChangePasswordVC *changePassVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
                [self.navigationController pushViewController:changePassVC animated:YES];
            }else{
                [self displayLogoutOption];
            }
        }
            break;
            
        case 9:
        {
            [self displayLogoutOption];
        }
            break;

        default:
            break;
    }
}


-(void)displayLogoutOption{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertView sharedManager] presentAlertWithTitle:@"Logout" message:@"Are you sure you want to logout?" andButtonsWithTitle:@[@"Yes",@"No"]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index == 0) {
                [self logoutRequest];
            }
        }];
    });
}

#pragma mark - UIButton Action Method

- (IBAction)backButtonaction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Service Implemention

-(void)logoutRequest {
    
    [self apiCallForLogoutUser:[NSMutableDictionary new] andServiceName:logoutApi];
}

-(void)apiCallForLogoutUser:(NSMutableDictionary *)logoutDetailDictionary andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:logoutDetailDictionary apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        if (!error) {
            [RequestTimeOutView showWithMessage:[result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]] forTime:2.0];
            
            //Remove all the Store Data
            [NSUSERDEFAULT removeObjectForKey:pUserDetail];
            
            [APPDELEGATE startWithLogin];
        }else if (error.code == 100) {
            //Success but other than 200 responseCode
            NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }else {
            //Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];        }
    }];
}

@end
