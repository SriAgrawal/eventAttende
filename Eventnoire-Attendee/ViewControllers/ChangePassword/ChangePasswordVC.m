//
//  ChangePasswordVC.m
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 06/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "ChangePasswordVC.h"
#import "NSDictionary+NullChecker.h"
#import "AuthenticationModal.h"
#import "RequestTimeOutView.h"
#import "ServiceHelper.h"
#import "NSString+Addition.h"
#import "ServiceHelper.h"
#import "AlertView.h"
#import "LoginVC.h"
#import "OtpVC.h"
#import "Macro.h"

@interface ChangePasswordVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTxt;
@property (weak, nonatomic) IBOutlet UITextField *selectedPasswordTxt;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTxt;

@property (weak, nonatomic) IBOutlet UILabel *alertLabelOld;
@property (weak, nonatomic) IBOutlet UILabel *alertLabelNew;
@property (weak, nonatomic) IBOutlet UILabel *alertLabelConfirm;

@property (strong, nonatomic) AuthenticationModal *changePasswordModal;

@end

@implementation ChangePasswordVC

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
    
    //Alloc modal class
    self.changePasswordModal = [AuthenticationModal new];
    
    self.changePasswordModal.password = [NSString string];
    self.changePasswordModal.selectedPassword = [NSString string];
    self.changePasswordModal.confirmPassword = [NSString string];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.alertLabelOld.text = [NSString string];
    self.alertLabelNew.text = [NSString string];
    self.alertLabelConfirm.text = [NSString string];
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
            if (TRIM_SPACE(validationstring).length > 16) {
                return NO;
            }
        }
            break;
        case 101:
        {
            if (TRIM_SPACE(validationstring).length > 16) {
                return NO;
            }
        }
            break;
        case 102:
        {
            if (TRIM_SPACE(validationstring).length > 16) {
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
            self.changePasswordModal.password = TRIM_SPACE(textField.text);
            break;
        case 101:
            self.changePasswordModal.selectedPassword = TRIM_SPACE(textField.text);
            break;
        case 102:
            self.changePasswordModal.confirmPassword = TRIM_SPACE(textField.text);
            break;
        default:
            break;
    }
}

#pragma mark - Validation Methods

-(BOOL)validateFields {
    
    BOOL isAllValid = NO;
    
    if (![self.changePasswordModal.password length]) {
        self.alertLabelOld.text = blank_Password;
        self.alertLabelNew.text = [NSString string];
        self.alertLabelConfirm.text = [NSString string];
        
    }
    else if ([self.changePasswordModal.password length] < 8) {
        self.alertLabelOld.text = valid_Password;
        self.alertLabelNew.text = [NSString string];
        self.alertLabelConfirm.text = [NSString string];
        
    }
    else if (![self.changePasswordModal.selectedPassword length]) {
        self.alertLabelNew.text = new_Password;
        self.alertLabelConfirm.text = [NSString string];
        self.alertLabelOld.text = [NSString string];
        
    }
    else if ([self.changePasswordModal.selectedPassword length] < 8) {
        self.alertLabelNew.text = valid_New_Password;
        self.alertLabelConfirm.text = [NSString string];
        self.alertLabelOld.text = [NSString string];
    }
    else if (![self.changePasswordModal.confirmPassword length]) {
        self.alertLabelConfirm.text = blank_Confirm_Password;
        self.alertLabelNew.text = [NSString string];
        self.alertLabelOld.text = [NSString string];
        
    }
    else if (![self.changePasswordModal.confirmPassword isEqualToString:self.changePasswordModal.selectedPassword]) {
        self.alertLabelConfirm.text = password_Confirm_Password_Not_Match;
        self.alertLabelNew.text = [NSString string];
        self.alertLabelOld.text = [NSString string];
    }
    else
        isAllValid = YES;
    
    
    return isAllValid;
}


#pragma mark - UIButton Action Method

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([self validateFields]) {
        [self changePasswordRequest];
    }
}


#pragma mark - Service Implemention

-(void)changePasswordRequest {
    
    NSMutableDictionary *changePassDict = [NSMutableDictionary new];
    
    NSDictionary *userDetail = [NSUSERDEFAULT valueForKey:pUserDetail];
    
    [changePassDict setValue:[userDetail valueForKey:pEmailID] forKey:pEmailID];
    [changePassDict setValue:self.changePasswordModal.password forKey:pPassword];
    [changePassDict setValue:self.changePasswordModal.selectedPassword forKey:pNewPassword];
    
    [self apiCallForChangingPasssword:changePassDict andServiceName:changePasswordApi];
}

-(void)apiCallForChangingPasssword:(NSMutableDictionary *)changePassDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:changePassDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        if (!error) {
            NSString *successMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:successMessage forTime:2.0];
            
            [self.navigationController popViewControllerAnimated:YES];
            
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
