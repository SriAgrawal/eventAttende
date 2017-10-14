//  OtpVC.m
//  Eventnoire-Attendee
//  Created by Aiman Akhtar on 28/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "AuthenticationModal.h"
#import "ServiceHelper.h"
#import "HomeVC.h"
#import "PersonalizeVC.h"
#import "UserModal.h"
#import "LoginVC.h"
#import "Macro.h"
#import "OtpVC.h"

@interface OtpVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitTopSpaceConstraint;

@property (strong, nonatomic) AuthenticationModal *otpModal;


@end

@implementation OtpVC

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

#pragma mark - Helper Method

- (void) initialSetup {
    //hide alert label
    self.alertLabel.hidden = YES;
    
    //Alloc modal class
    self.otpModal = [[AuthenticationModal alloc]init];

//    self.modalObject.otpString = @"";
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
            if (TRIM_SPACE(validationstring).length > 6) {
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
            self.otpModal.otp = TRIM_SPACE(textField.text);
            break;
        default:
            break;
    }
}

#pragma mark - Validation Methods

-(BOOL)validateFields {
    
    BOOL isAllValid = NO;
    
    self.alertLabel.hidden = NO;
    
    if (![self.otpModal.otp length]) {
        self.alertLabel.text = blank_OTP;
        
    }else if ([self.otpModal.otp length] < 4) {
        self.alertLabel.text = valid_Otp;
    }else {
        self.alertLabel.hidden = YES;
        isAllValid = YES;
    }
    
    self.submitTopSpaceConstraint.constant = (self.alertLabel.hidden)?20.0f:45.0f;
    return isAllValid;
}



#pragma mark - UIButton Action Methods

- (IBAction)submitButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([self validateFields]) {
//        PersonalizeVC *personalizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
//        [self.navigationController pushViewController:personalizeVC animated:YES];
        [self optRequest];
    }
}

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resentOTPAction:(UIButton *)sender {
    NSMutableDictionary *resendOtpDict = [NSMutableDictionary new];
    [resendOtpDict setValue:self.phoneNumber forKey:pPhoneNumber];
    [self apiCallForOTPVerification:resendOtpDict andApiName:resendOTPApi];
}


#pragma mark - Service Implemention

-(void)optRequest {
    
    NSMutableDictionary *otpDict = [NSMutableDictionary new];
    [otpDict setValue:self.otpModal.otp forKey:pOTPNumber];
    [otpDict setValue:self.phoneNumber forKey:pPhoneNumber];

    [self apiCallForOTPVerification:otpDict andApiName:verifyOTPApi];
}


-(void)apiCallForOTPVerification:(NSMutableDictionary *)otpDictonary andApiName:(NSString *)apiName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:otpDictonary apiName:apiName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        if (!error) {
            //Success and 200 responseCode
            NSString *successMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:successMessage forTime:2.0];
            
            NSMutableDictionary *userDict = [[NSUSERDEFAULT valueForKey:pUserDetail] mutableCopy];
            [NSUSERDEFAULT removeObjectForKey:pUserDetail];
            
            [userDict setValue:[NSString stringWithFormat:@"1"] forKey:pIsPhoneNumberVerify];
            [NSUSERDEFAULT setValue:userDict forKey:pUserDetail];
            
            if ([apiName isEqualToString:verifyOTPApi]) {
                [self dismissViewControllerAnimated:NO completion:^{
                    [self.backDelegate dismissAfterCompletePhoneVerification];
                }];
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

@end
