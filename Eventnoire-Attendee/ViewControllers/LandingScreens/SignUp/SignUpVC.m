//
//  SignUpVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 24/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "CountryDetailViewController.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "AuthenticationModal.h"
#import "SignUpTableViewCell.h"
#import "MZSelectableLabel.h"
#import "NSString+Addition.h"
#import "PersonalizeVC.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "SignUpVC.h"
#import "HomeVC.h"
#import "Macro.h"
#import "OtpVC.h"


#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


static NSString *cellIdentifier = @"SignUpTableViewCell";

@interface SignUpVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PhoneNumberVerificationProcessComplete,CountryListDeleagte>{
    NSString *selectedCountryCode;
}

@property (weak, nonatomic) IBOutlet MZSelectableLabel *loginLabel;
@property (weak, nonatomic) IBOutlet UITableView *signUpTableView;
@property (strong, nonatomic) AuthenticationModal *signUpModal;



@end

@implementation SignUpVC

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
    
    //Set Range and make Login tapable
    [self.loginLabel setSelectableRange:[[self.loginLabel.attributedText string] rangeOfString:@"Login"]];
    self.loginLabel.selectionHandler = ^(NSRange range, NSString *string) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    //Alloc modal class
    self.signUpModal = [AuthenticationModal new];
    self.signUpModal.index = -1;
}


# pragma mark - Helper Methods

-(void)cancelNumberPad{
    [self.view endEditing:YES];
}

-(void)doneWithNumberPad{
    [[self.view viewWithTag:104] becomeFirstResponder];
}


#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.signUpModal.index == indexPath.row) ? 70 : 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignUpTableViewCell *cell =
    (SignUpTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.signUpTextField.tag = indexPath.row + 100;
    cell.alertLabel.tag = indexPath.row + 200;
    cell.signUpTextField.keyboardType = UIKeyboardTypeDefault;
    cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cell.signUpTextField.keyboardType = UIKeyboardTypeASCIICapable;
    cell.signUpTextField.secureTextEntry = NO;
    cell.signUpTextField.returnKeyType = UIReturnKeyNext;
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];


    switch (indexPath.row) {
        case 0:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.firstName;
            [cell.signUpTextField placeHolderTextWithColor:@"First Name" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_user"];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
            break;
        case 1:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.lastName;
             [cell.signUpTextField placeHolderTextWithColor:@"Last Name" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_user"];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
            break;
        case 2:
        {
            cell.selectCountryBtn.hidden = NO;
            cell.signUpTextField.text = self.signUpModal.countryCode;
            [cell.signUpTextField placeHolderTextWithColor:@"Country Code" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_mob"];
            cell.signUpTextField.keyboardType = UIKeyboardTypeNumberPad;
            [cell.selectCountryBtn addTarget:self
                         action:@selector(selectCountry)
               forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 3:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.phoneNumber;
            [cell.signUpTextField placeHolderTextWithColor:@"Phone Number" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_mob"];
            cell.signUpTextField.keyboardType = UIKeyboardTypeNumberPad;
            [cell.signUpTextField setInputAccessoryView:numberToolbar];

        }
            break;
        
        case 4:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.email;
            [cell.signUpTextField placeHolderTextWithColor:@"Email" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_mail"];
            cell.signUpTextField.keyboardType = UIKeyboardTypeEmailAddress;

        }
            break;
            
        case 5:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.password;
            [cell.signUpTextField placeHolderTextWithColor:@"Password" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_pass"];
            cell.signUpTextField.secureTextEntry = YES;
        }
            break;
            
        case 6:
        {
            cell.selectCountryBtn.hidden = YES;
            cell.signUpTextField.text = self.signUpModal.confirmPassword;
            [cell.signUpTextField placeHolderTextWithColor:@"Confirm Password" Color:[UIColor blackColor]];
            cell.iconImageView.image = [UIImage imageNamed:@"ic_pass"];
            cell.signUpTextField.secureTextEntry = YES;
            cell.signUpTextField.returnKeyType = UIReturnKeyDone;
        }
            break;
            
        default:
            break;
    }
    
    if (indexPath.row == self.signUpModal.index) {
        [cell.alertLabel setText:self.signUpModal.errorMessage];
        [cell.alertLabel setHidden:NO];
        cell.signUpTextField.layer.borderColor = [UIColor redColor].CGColor;
    }else{
        [cell.alertLabel setHidden:YES];
        cell.signUpTextField.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
    return cell;
}

-(void)selectCountry{
    
    if(self.signUpModal.index != -1) {
        self.signUpModal.index = -1;
        [self.signUpTableView reloadData];
    }
    CountryDetailViewController *countryDetail = [[CountryDetailViewController alloc]initWithNibName:@"CountryDetailViewController" bundle:nil];
    UINavigationController *chatNavigation = [[UINavigationController alloc]initWithRootViewController:countryDetail];
    [self updateNavigationBar:chatNavigation];
    countryDetail.delegate = self;
    
    [self presentViewController:chatNavigation animated:NO completion:nil];
    
   
}

-(void)selectedCountryDetail:(CountryDetailModal *)country {
  _signUpModal.countryCode = [NSString stringWithFormat:@"%@ - (%@)",country.countryPhoneCode,country.countryName];
    selectedCountryCode = country.countryPhoneCode;
    [_signUpTableView reloadData];
}


-(void)updateNavigationBar:(UINavigationController *)navController
{
    navController.navigationBar.translucent = NO;
    navController.navigationBar.tintColor = [UIColor redColor];
    [navController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName :[UIFont fontWithName:@"OpenSans" size:14]}];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegates

- (void)textFieldDidBeginEditing:(EventnoireTextField *)textField {
    if(self.signUpModal.index != -1) {
        self.signUpModal.index = -1;
        [self.signUpTableView reloadData];
        
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [textField becomeFirstResponder];
        });    }
}

- (BOOL)textFieldShouldReturn:(EventnoireTextField *)textField {
    
    if(textField.returnKeyType == UIReturnKeyNext){
        if (textField.tag == 101) {
            [[self.view viewWithTag:textField.tag+2] becomeFirstResponder];
        }else{
            [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        }
    }else
        [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(EventnoireTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString* )string {
    
    NSString *validationstring = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage])
    {
        return NO;
    }
    else if (textField.tag ==100 || textField.tag ==101){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        return [string isEqualToString:filtered];
 
    }
   
   
    
  
    
    
    switch (textField.tag) {
        case 100:
            if ([string isEqualToString:@" "]) {
                return NO;
            }
            break;
        case 103:
        {
            if (TRIM_SPACE(validationstring).length > 15 && ![string isEqual:@""]) {
                return NO;
            }
        }
            break;
        case 104:
            if (TRIM_SPACE(validationstring).length > 64 && ![string isEqual:@""]) {
                return NO;
            }
            break;
        case 105:case 106:
            if (TRIM_SPACE(validationstring).length > 16 && ![string isEqual:@""]) {
                return NO;
            }
            break;
        default:
            if (TRIM_SPACE(validationstring).length > 50 && ![string isEqual:@""]) {
                return NO;
            }
            break;
    }
    return YES;
    
}

- (void)textFieldDidEndEditing:(EventnoireTextField *)textField{
    
    [textField layoutIfNeeded]; // for avoiding the bouncing of text inside textfield
    
    switch (textField.tag) {
        case 100:
            self.signUpModal.firstName = TRIM_SPACE(textField.text);
            break;
        case 101:
            self.signUpModal.lastName = TRIM_SPACE(textField.text);
            break;
        case 102:
            self.signUpModal.countryCode = TRIM_SPACE(textField.text);
            break;
        case 103:
            self.signUpModal.phoneNumber = TRIM_SPACE(textField.text);
            break;
        case 104:
            self.signUpModal.email = TRIM_SPACE(textField.text);
            break;
        case 105:
            self.signUpModal.password = TRIM_SPACE(textField.text);
            break;
        case 106:
            self.signUpModal.confirmPassword = TRIM_SPACE(textField.text);
            break;
        default:
            break;
    }
}

#pragma mark - Validation Methods

-(BOOL)validateFields {
    BOOL isAllValid = NO;
    
    if (![self.signUpModal.firstName length]) {
        self.signUpModal.errorMessage = blank_FirstName;
        self.signUpModal.index = 0;
        
    }else if (![self.signUpModal.lastName length]) {
        self.signUpModal.errorMessage = blank_LastName;
        self.signUpModal.index = 1;

    }else if (![self.signUpModal.countryCode length]) {
        self.signUpModal.errorMessage = blank_CountryCode;
        self.signUpModal.index = 2;
    }
    else if (![self.signUpModal.phoneNumber length]) {
        self.signUpModal.errorMessage = blank_Phone;
        self.signUpModal.index = 3;

    }else if ([self.signUpModal.phoneNumber length] < 10) {
        self.signUpModal.errorMessage = valid_MobileNumber;
        self.signUpModal.index = 3;

    }else if (![self.signUpModal.email length]) {
        self.signUpModal.errorMessage = blank_Email;
        self.signUpModal.index = 4;

    }else if (![self.signUpModal.email isValidEmail]) {
        self.signUpModal.errorMessage = valid_Email;
        self.signUpModal.index = 4;

    }else if (![self.signUpModal.password length]) {
        self.signUpModal.errorMessage = blank_Password;
        self.signUpModal.index = 5;

    }else if ([self.signUpModal.password length] < 8) {
        self.signUpModal.errorMessage = valid_Password;
        self.signUpModal.index = 5;

    }else if (![self.signUpModal.confirmPassword length]) {
        self.signUpModal.errorMessage = blank_Confirm_Password;
        self.signUpModal.index = 6;

    }else if (![self.signUpModal.confirmPassword isEqualToString:self.signUpModal.password]) {
        self.signUpModal.errorMessage = password_Confirm_Password_Not_Match;
        self.signUpModal.index = 6;

    }
    else {
        isAllValid = YES;
    }
    return isAllValid;
    
}

#pragma mark - UIButton Action Methods

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpButtonAction:(id)sender {
    [self.view endEditing:YES];
    if ([self validateFields]) {
        [self  SignUpRequest];
//        OtpVC *otpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtpVC"];
//        [self.navigationController pushViewController:otpVC animated:YES];
    }else {
        [self.signUpTableView reloadData];
    }
}

#pragma mark - Service Implemention

-(void)SignUpRequest {
    
    NSMutableDictionary *signUpDict = [NSMutableDictionary new];
    [signUpDict setValue:self.signUpModal.email forKey:pEmailID];
    [signUpDict setValue:self.signUpModal.password forKey:pPassword];
    [signUpDict setValue:self.signUpModal.firstName forKey:pFirstName];
    [signUpDict setValue:self.signUpModal.lastName forKey:pLastName];
    [signUpDict setValue:[selectedCountryCode stringByAppendingString:self.signUpModal.phoneNumber] forKey:pPhoneNumber];
    [signUpDict setValue:@"0" forKey:pUserType];
    [signUpDict setValue:@"" forKey:pProfilePic];
    [signUpDict setValue:[APPDELEGATE deviceToken] forKey:pDeviceToken];
    [signUpDict setValue:@"0" forKey:pDeviceType];


    
    [self apiCallForNewRegistration:signUpDict];
}

-(void)apiCallForNewRegistration:(NSMutableDictionary *)signUpDictonary {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:signUpDictonary apiName:signUpApi andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            NSDictionary *userDetail = [result objectForKeyNotNull:pUserDetail expectedObj:[NSDictionary dictionary]];
            
            OtpVC *otpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtpVC"];
            otpVC.phoneNumber = [userDetail objectForKeyNotNull:pPhoneNumber expectedObj:[NSString string]];
            otpVC.isBackButtonRequired = NO;
            otpVC.backDelegate = self;
            [self.navigationController presentViewController:otpVC animated:YES completion:nil];
            
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
    //Open Main Screen
    PersonalizeVC *personalizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizeVC"];
    [self.navigationController pushViewController:personalizeVC animated:YES];
}


@end
