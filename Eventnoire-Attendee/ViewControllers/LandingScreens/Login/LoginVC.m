//
//  LoginVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 23/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//


#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "NSDictionary+NullChecker.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <TwitterKit/TwitterKit.h>
#import "RequestTimeOutView.h"
#import "AuthenticationModal.h"
#import "ServiceHelper.h"
#import "NSString+Addition.h"
#import "MZSelectableLabel.h"
#import "ForgotPasswordVC.h"
#import "ChangePasswordVC.h"
#import <Fabric/Fabric.h>
#import "PersonalizeVC.h"
#import "FacebookLogin.h"
#import "UserModal.h"
#import "SignUpVC.h"
#import "LoginVC.h"
#import "HomeVC.h"
#import "OtpVC.h"
#import "Macro.h"

@interface LoginVC ()<UITextFieldDelegate,GIDSignInDelegate,GIDSignInUIDelegate,PhoneNumberVerificationProcessComplete>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordfieldTopSpaceConstraint;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet MZSelectableLabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordAlertLabel;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;


@property (weak, nonatomic) IBOutlet UITableView *loginTableView;

@property (strong, nonatomic) AuthenticationModal *loginInfo;

@end

@implementation LoginVC

#pragma mark - View Controller Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[NSUSERDEFAULT valueForKey:iSTutorialSeen] boolValue])
        [NSUSERDEFAULT setValue:[NSNumber numberWithBool:YES] forKey:iSTutorialSeen];
    
    [self initialSetup];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)initialSetup {
    
    //Set Range and make SignUp tapable
    [self.signUpLabel setSelectableRange:[[self.signUpLabel.attributedText string] rangeOfString:@"Sign Up"]];
    self.signUpLabel.selectionHandler = ^(NSRange range, NSString *string) {
        SignUpVC *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpVC"];
        [self.navigationController pushViewController:signUpVC animated:YES];
           };
    
    //set imageView border color
    self.logoImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.logoImageView.layer.cornerRadius =  self.logoImageView.frame.size.width/2;
    self.logoImageView.layer.masksToBounds = YES;
    
    if (windowHeight == 568) {
        self.imageViewHeightConstraint.constant = 180;
        self.logoTopSpaceConstraint.constant = 120;
        self.signUpLabelBottomConstraint.constant = 105;
        self.loginTableView.scrollEnabled = NO;
    }else if (windowHeight == 480)
        self.loginTableView.scrollEnabled = YES;
    else
      self.loginTableView.scrollEnabled = NO;
    
    //Alooc modal class
    self.loginInfo = [AuthenticationModal new];
    
    //Hide alert label
    self.emailAlertLabel.hidden = YES;
    self.passwordAlertLabel.hidden = YES;
    
    //Check Remember
    if ([[[NSUSERDEFAULT valueForKey:pLoginInfo] valueForKey:pIsRemember] boolValue]) {
        NSDictionary *userDict = [NSUSERDEFAULT valueForKey:pLoginInfo];
        
        self.loginInfo.email = [userDict valueForKey:pEmailID];
        [self.emailTextField setText:self.loginInfo.email];
        
        [self.rememberMeBtn setSelected:[[userDict valueForKey:pIsRemember] boolValue]];
    }


    //Gooogle sign in
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
}


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.passwordfieldTopSpaceConstraint.constant = 15.0f;
    self.emailAlertLabel.hidden = YES;
    self.passwordAlertLabel.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    if(textField.returnKeyType == UIReturnKeyNext)
        [[self.view viewWithTag:textField.tag+100] becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString* )string {
    
    NSString *validationstring = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage])
    {
        return NO;
    }

    switch (textField.tag) {
        case 100:
        {
            if (TRIM_SPACE(validationstring).length > 64) {
                return NO;
            }
        }
            
            break;
        case 200:
            if (TRIM_SPACE(validationstring).length > 16) {
                return NO;
            }
            break;
        default:
            break;
    }
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField layoutIfNeeded]; // for avoiding the bouncing of text inside textfield
    
    switch (textField.tag) {
        case 100:
            self.loginInfo.email = TRIM_SPACE(textField.text);
            break;
        case 200:
            self.loginInfo.password = TRIM_SPACE(textField.text);
            break;
        default:
            break;
    }
}


#pragma mark- Validation Helper Methods

- (BOOL)isallFieldsVerified {
    
    BOOL  isVerified = NO;

    if(![self.loginInfo.email length]) {
        self.emailAlertLabel.hidden = NO;
        self.emailAlertLabel.text = blank_Email;
        self.passwordfieldTopSpaceConstraint.constant = 25.0f;
    }
    
    else if (![self.loginInfo.email isValidEmail]) {
        self.emailAlertLabel.hidden = NO;
        self.emailAlertLabel.text = valid_Email;
        self.passwordfieldTopSpaceConstraint.constant = 25.0f;
    }
    
    else if(![self.loginInfo.password length]){
        self.passwordAlertLabel.hidden = NO;
        self.passwordAlertLabel.text = blank_Password;
    }
    
    else if ([self.loginInfo.password length] < 8) {
        self.passwordAlertLabel.hidden = NO;
        self.passwordAlertLabel.text = valid_Password;
    }
    
    else {
        isVerified = YES;
    }
    
    return isVerified;
}

#pragma mark - UIButton Action Methods

- (IBAction)rememberButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.selected = !sender.selected;
    
    NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
    [userDictionary setValue:[NSNumber numberWithBool:sender.selected] forKey:pIsRemember];
    [NSUSERDEFAULT setValue:userDictionary forKey:pLoginInfo];
    
}

- (IBAction)forgotPasswordButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    ForgotPasswordVC *forgotVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPasswordVC"];
    [self.navigationController pushViewController:forgotVC animated:YES];
    
   
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if ([self isallFieldsVerified]) {
//        PersonalizeVC *personalizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
//        [self.navigationController pushViewController:personalizeVC animated:YES];
        [self loginRequestViaNormal];
    }
}

- (IBAction)twitterButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [[Twitter sharedInstance] logInWithMethods:TWTRLoginMethodWebBased completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        if (session) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
            
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
            
            [client loadUserWithID:userID completion:^(TWTRUser *user, NSError *error) {
                if(user){
                    NSString *urlString = [[NSString alloc]initWithString:user.profileImageLargeURL];
                    
                    NSArray *nameArray = [[user valueForKey:@"name"] componentsSeparatedByString:@" "];
                    self.loginInfo.firstName = [nameArray firstObject];
                    self.loginInfo.lastName = [nameArray lastObject];
                    self.loginInfo.socialID = [user valueForKey:@"userID"];
                    self.loginInfo.socialType = @"twitter";
                    self.loginInfo.profilePicture = urlString;
                    self.loginInfo.email =[[user valueForKey:@"userID"] stringByAppendingString:@"@twitter.com"];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loginRequestViaSocialMedia:nil];
                    });
                }
            }];
        }
        else {
           // [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (IBAction)facebookButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    [[FacebookLogin sharedManager] getFacebookInfoWithCompletionHandler:self completionBlock:^(NSDictionary *infoDict, NSError *error) {
        
        if (!error) {
            
                        self.loginInfo.firstName = [infoDict objectForKeyNotNull:@"first_name" expectedObj:@""];
                        self.loginInfo.lastName = [infoDict objectForKeyNotNull:@"last_name" expectedObj:@""];
                        self.loginInfo.socialID = [infoDict valueForKey:@"id"];
                        self.loginInfo.socialType = @"facebook";
            
                        NSDictionary *pictureDict = [infoDict objectForKeyNotNull:@"picture" expectedObj:[NSDictionary dictionary]];
                        self.loginInfo.profilePicture = [[pictureDict objectForKeyNotNull:@"data" expectedObj:[NSDictionary dictionary]] objectForKeyNotNull:@"url" expectedObj:@""];
            
             self.loginInfo.email = ([[infoDict objectForKey:@"email"] length]) ? [infoDict objectForKey:@"email"] : [self.loginInfo.socialID stringByAppendingString:@"@facebook.com"];
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"id,name",@"fields",nil] tokenString:FBSDKAccessToken.currentAccessToken.tokenString version:nil HTTPMethod:@"GET"]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //[self progressHud:NO];
                 
                 if (error) {
                     
                     [self loginRequestViaSocialMedia:[NSArray array]];
                 }else {
                     NSArray *friendListArray = [result objectForKeyNotNull:@"data" expectedObj:[NSArray array]];
                     NSMutableArray *friendIDArray = [NSMutableArray array];
                     
                     for (NSDictionary *dict in friendListArray) {
                         [friendIDArray addObject:[dict objectForKeyNotNull:@"id" expectedObj:[NSString string]]];
                     }
                     [self loginRequestViaSocialMedia:friendIDArray];
                 }
             }];
        }
    }];
}


- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    self.loginInfo.socialID = user.userID;                  // For client-side use only!
    self.loginInfo.socialType = @"google";                  // For client-side use only!
    self.loginInfo.firstName = user.profile.givenName;
    self.loginInfo.lastName = user.profile.familyName;
    self.loginInfo.userName = user.profile.name;
    self.loginInfo.email = ([user.profile.email length]) ? user.profile.email : [self.loginInfo.socialID stringByAppendingString:@"@gmail.com"];
    
    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage){
        NSUInteger dimension = round(200 * 200);
        NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
        self.loginInfo.profilePicture = [imageURL absoluteString];
    }else{
        self.loginInfo.profilePicture = @"";
    }
    [self loginRequestViaSocialMedia:nil];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}


- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)googleButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)didTapSignOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
}


#pragma mark - Service Implemention

-(void)loginRequestViaNormal {
    
    NSMutableDictionary *loginInfoDict = [NSMutableDictionary new];
    [loginInfoDict setValue:self.loginInfo.email forKey:pEmailID];
    [loginInfoDict setValue:self.loginInfo.password forKey:pPassword];
    
    [self apiCallForLoginAuthentication:loginInfoDict andServiceName:loginApi];
}

-(void)loginRequestViaSocialMedia:(NSArray *)facebookFriendArray {
    
    NSMutableDictionary *socialLoginDict = [NSMutableDictionary new];
    [socialLoginDict setValue:self.loginInfo.email forKey:pEmailID];
    [socialLoginDict setValue:self.loginInfo.password forKey:pPassword];
    [socialLoginDict setValue:self.loginInfo.socialID forKey:pSocialID];
    [socialLoginDict setValue:self.loginInfo.socialType forKey:pSocialType];
    [socialLoginDict setValue:self.loginInfo.firstName forKey:pFirstName];
    [socialLoginDict setValue:self.loginInfo.lastName forKey:pLastName];
    [socialLoginDict setValue:self.loginInfo.userName forKey:pUserName];
    [socialLoginDict setValue:self.loginInfo.profilePicture forKey:pProfilePic];
    [socialLoginDict setValue:@"" forKey:pPhoneNumber];

    if (facebookFriendArray)
        [socialLoginDict setValue:facebookFriendArray forKey:pFbFriendList];
    
    [self apiCallForLoginAuthentication:socialLoginDict andServiceName:socialLoginApi];
}

-(void)apiCallForLoginAuthentication:(NSMutableDictionary *)loginDetailDictonary andServiceName:(NSString *)serviceName {
    
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:loginDetailDictonary apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
    
        if (!error) {
            //Success and 200 responseCode
            NSDictionary *userDetail = [result objectForKeyNotNull:pUserDetail expectedObj:[NSDictionary dictionary]];
            
            //Check Remember
            if ([[[NSUSERDEFAULT valueForKey:pLoginInfo] valueForKey:pIsRemember] boolValue]) {
                NSMutableArray *userDict = [[NSUSERDEFAULT valueForKey:pLoginInfo] mutableCopy];
                [userDict setValue:[userDetail objectForKeyNotNull:pEmailID expectedObj:[NSString string]] forKey:pEmailID];
                
                [NSUSERDEFAULT removeObjectForKey:pLoginInfo];
                [NSUSERDEFAULT setValue:userDict forKey:pLoginInfo];
            }
            
            BOOL isPhoneVerified = [[userDetail objectForKeyNotNull:pIsPhoneNumberVerify expectedObj:[NSString string]] boolValue];
            
            
            if (isPhoneVerified) {
                if ([[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pInterestData] boolValue]) {
                    HomeVC *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                    [self.navigationController pushViewController:homeVC animated:NO];
                }else {
                    PersonalizeVC *personalizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
                    [self.navigationController pushViewController:personalizeVC animated:YES];
                }
            }else {
                // Open OTP Screen
                OtpVC *otpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtpVC"];
                
                otpVC.phoneNumber = [userDetail objectForKeyNotNull:pPhoneNumber expectedObj:[NSString string]];
                otpVC.isBackButtonRequired = YES;
                otpVC.backDelegate = self;
                
                [self.navigationController presentViewController:otpVC animated:YES completion:nil];
            }
            
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

#pragma mark - Protocol Implementation

-(void)dismissAfterCompletePhoneVerification {
    //Open Personalize Screen
    PersonalizeVC *personalizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
    [self.navigationController pushViewController:personalizeVC animated:YES];
}

@end
