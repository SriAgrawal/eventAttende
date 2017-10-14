//
//  ForgotPasswordVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 28/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "CountryDetailViewController.h"
#import "NSDictionary+NullChecker.h"
#import "AuthenticationModal.h"
#import "RequestTimeOutView.h"
#import "NSString+Addition.h"
#import "ResetPasswordVC.h"
#import "ForgotPasswordVC.h"
#import "ServiceHelper.h"
#import "AlertView.h"
#import "LoginVC.h"
#import "OtpVC.h"
#import "Macro.h"

@interface ForgotPasswordVC ()<UITextFieldDelegate,CountryListDeleagte>


@property (weak, nonatomic) IBOutlet UITextField *emailMobileTextField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitTopSpaceConstraint;
@property (strong, nonatomic) AuthenticationModal *forgotPasswordModal;

@end

@implementation ForgotPasswordVC

#pragma mark - View Controller Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action Method

- (void) initialSetup {
    //hide alert label
    self.alertLabel.hidden = YES;
    
    //Alloc modal class
    self.forgotPasswordModal = [AuthenticationModal new];
    self.forgotPasswordModal.email = [NSString string];

}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.submitTopSpaceConstraint.constant = 20.0f;
    self.alertLabel.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
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
        default:
            break;
    }
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField layoutIfNeeded]; // for avoiding the bouncing of text inside textfield
    
    switch (textField.tag) {
        case 100:
            self.forgotPasswordModal.email = TRIM_SPACE(textField.text);
            break;
        default:
            break;
    }
}

#pragma mark - Validation Methods

-(BOOL)validateFields {
    
    BOOL isAllValid = NO;
    BOOL isPhoneNumber = [self checkForNumber:self.forgotPasswordModal.email];
    
    if (![self.emailMobileTextField.text length]) {
        self.alertLabel.text = blank_Email_Mobile;
    }
    
    else if (isPhoneNumber && ([self.emailMobileTextField.text length] < 10)) {
        self.alertLabel.text = valid_MobileNumber;
    }
    
    else if (isPhoneNumber && ![self.emailMobileTextField.text isValidPhoneNumber]) {
        self.alertLabel.text = valid_Phone;
    }
    
    else if (!isPhoneNumber && ![self.emailMobileTextField.text isValidEmail]) {
        self.alertLabel.text = valid_Email;
    }
    else {
        isAllValid = YES;
    }
    
    self.alertLabel.hidden = isAllValid;
    self.submitTopSpaceConstraint.constant = (isAllValid)?20.0f:45.0f;

    return isAllValid;
}

-(BOOL)checkForNumber:(NSString *)text {
    NSCharacterSet *alphaNums = [NSCharacterSet characterSetWithCharactersInString:@"1234567890+"];

  //  NSCharacterSet *alphaNums = @"1234567890+";
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:text];
        
    return [alphaNums isSupersetOfSet:inStringSet];
}

#pragma mark - UIButton Action Method

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([self validateFields]) {
        BOOL isPhoneNumber = [self checkForNumber:self.forgotPasswordModal.email];
        
        if (isPhoneNumber) {
            [self selectCountry];
        }else
            [self forgotPasswordRequest];
    }
}

#pragma mark - Service Implemention

-(void)forgotPasswordRequest {
    
    NSMutableDictionary *loginInfoDict = [NSMutableDictionary new];
    [loginInfoDict setValue:self.forgotPasswordModal.email forKey:pPhoneNumber];
    
    BOOL isPhoneNumber = [self checkForNumber:self.forgotPasswordModal.email];
    
    if (isPhoneNumber) {
        [loginInfoDict setValue:[NSString stringWithFormat:@"%@%@",self.forgotPasswordModal.countryCode,self.forgotPasswordModal.email] forKey:pPhoneNumber];
    }else {
        [loginInfoDict setValue:self.forgotPasswordModal.email forKey:pEmailID];
    }
    
    [self apiCallForGettingNewPasssword:loginInfoDict andServiceName:forgotPasswordApi];
}

-(void)apiCallForGettingNewPasssword:(NSMutableDictionary *)forgotPasswordDictonary andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:forgotPasswordDictonary apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        if (!error) {
            NSString *successMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:successMessage forTime:2.0];
            
            BOOL isPhoneNumber = [self checkForNumber:self.forgotPasswordModal.email];

            ResetPasswordVC *resetVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordVC"];
            resetVC.phoneNumberString =  (isPhoneNumber)?[NSString stringWithFormat:@"%@%@",self.forgotPasswordModal.countryCode,self.forgotPasswordModal.email]:@"";
            resetVC.emailString = (isPhoneNumber) ? @"" : self.forgotPasswordModal.email;
            
            [self.navigationController pushViewController:resetVC animated:YES];
            
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

-(void)selectCountry {
    CountryDetailViewController *countryDetail = [[CountryDetailViewController alloc]initWithNibName:@"CountryDetailViewController" bundle:nil];
    UINavigationController *chatNavigation = [[UINavigationController alloc]initWithRootViewController:countryDetail];
    [self updateNavigationBar:chatNavigation];
    
    countryDetail.delegate = self;
    
    [self presentViewController:chatNavigation animated:NO completion:nil];
}

-(void)selectedCountryDetail:(CountryDetailModal *)country {
    
    if ([country.countryPhoneCode length]) {
        self.forgotPasswordModal.countryCode = country.countryPhoneCode;
        
        [self forgotPasswordRequest];
    }
}


-(void)updateNavigationBar:(UINavigationController *)navController
{
    navController.navigationBar.translucent = NO;
    navController.navigationBar.tintColor = [UIColor redColor];
    [navController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName :[UIFont fontWithName:@"OpenSans" size:14]}];
}


@end
