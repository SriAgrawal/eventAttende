//
//  AttendeesVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "NSDictionary+NullChecker.h"
#import "AttendeesTableViewCell.h"
#import "TicketConfirmationVC.h"
#import "RequestTimeOutView.h"
#import "OptionsPickerSheetView.h"
#import "AttendeesVC.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "EventModal.h"
#import "HomeVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"AttendeesTableViewCell";

@interface AttendeesVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *attendeesTableView;

@property (strong,nonatomic) NSArray *titleArray;
@property (strong,nonatomic) NSArray *dataArray;

@end

@implementation AttendeesVC

#pragma mark - UIViewController Life Cycle & Memory Management

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
    //set dynamic height
    self.attendeesTableView.estimatedRowHeight = 400;
    
    //Initialise array
    self.titleArray = [[NSArray alloc]initWithObjects:@"First Name",@"Last Name",@"Email",@"Prefix",@"Job Title*",@"Organisation/Company*", nil];
    self.dataArray = [[NSArray alloc]initWithObjects:@"Arvind",@"Tyagi",@"arvind.tyagi@gmail.com",@"Mr.",@"Lorem ipsum",@"ABC", nil];

}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendeesTableViewCell *cell = (AttendeesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.detailTextField.tag = indexPath.row + 100;
	  cell.detailTextField.delegate = self;

	
    switch (indexPath.row) {
        case 0:
        {
            cell.selectPrefix.hidden = YES;
            cell.titleLabel.text = @"First Name";
            cell.detailTextField.text = [[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pFirstName];
            cell.detailTextField.keyboardType = UIKeyboardTypeDefault;
            cell.detailTextField.returnKeyType = UIReturnKeyNext;
            cell.detailTextField.enabled = NO;

        }
            break;
        case 1:
        {
            cell.selectPrefix.hidden = YES;
            cell.titleLabel.text = @"Last Name";
            cell.detailTextField.text = [[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pLastName];
            cell.detailTextField.keyboardType = UIKeyboardTypeDefault;
            cell.detailTextField.returnKeyType = UIReturnKeyNext;
            cell.detailTextField.enabled = NO;



        }
            break;
        case 2:
        {
            cell.selectPrefix.hidden = YES;
            cell.titleLabel.text = @"Email";
            cell.detailTextField.text = [[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pEmailID];
            cell.detailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.detailTextField.returnKeyType = UIReturnKeyNext;
            cell.detailTextField.enabled = NO;



        }
            break;
        case 3:
        {
            cell.selectPrefix.hidden = NO;
            cell.titleLabel.text = @"Prefix";
            cell.detailTextField.text = self.eventDetailModal.attendeePrefix;
            [cell.selectPrefix addTarget:self
                                      action:@selector(selectPrefix)
                            forControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
        case 4:
        {
            cell.selectPrefix.hidden = YES;
            cell.titleLabel.text = @"Job Title";
            cell.detailTextField.text = self.eventDetailModal.jobTitle;
            cell.detailTextField.keyboardType = UIKeyboardTypeDefault;
            cell.detailTextField.returnKeyType = UIReturnKeyNext;


        }
            break;
        case 5:
        {
            cell.selectPrefix.hidden = YES;
            cell.titleLabel.text = @"Organisation/Company";
            cell.detailTextField.text = self.eventDetailModal.organizationOrCompanyName;
            cell.detailTextField.keyboardType = UIKeyboardTypeDefault;
            cell.detailTextField.returnKeyType = UIReturnKeyDone;


        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UIButton ACtion Method

-(void)selectPrefix{
    NSMutableArray *prefixArray = [[NSMutableArray alloc]initWithObjects:@"Mr.",@"Mrs.", nil];
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:prefixArray AndComplitionblock:^(NSString *selectedText, NSInteger selectedIndex) {
        self.eventDetailModal.attendeePrefix = selectedText;
        [_attendeesTableView reloadData];
    }];
}


- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    self.eventDetailModal.organizationOrCompanyName = [NSString string];
    self.eventDetailModal.jobTitle = [NSString string];
    self.eventDetailModal.attendeePrefix = [NSString string];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)completeOrderButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    NSMutableDictionary *bookDictionary = [NSMutableDictionary new];

    [bookDictionary setValue:self.eventDetailModal.eventID forKey:pEventID];
    
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pFirstName] forKey:pFirstName];
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pLastName] forKey:pLastName];
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pEmailID] forKey:pEmailID];

    [bookDictionary setValue:self.eventDetailModal.attendeePrefix forKey:pPrefix];
    [bookDictionary setValue:self.eventDetailModal.jobTitle forKey:pJobTitle];
    [bookDictionary setValue:self.eventDetailModal.organizationOrCompanyName forKey:pOrganisation];
    [bookDictionary setValue:self.eventDetailModal.eventTicketType forKey:pTicketType];
    [bookDictionary setValue:[self.eventDetailModal generateTicketInfo] forKey:pTicketInfo];

    [self apiCallForBookEvent:bookDictionary andServiceName:bookEventApi];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    self.eventDetailModal.organizationOrCompanyName = [NSString string];
    self.eventDetailModal.jobTitle = [NSString string];
    self.eventDetailModal.attendeePrefix = [NSString string];
    
    TicketModal *ticketInfo = [self.eventDetailModal.ticketInfoArray firstObject];
    ticketInfo.bookSeats = @"0";
    
    [APPDELEGATE startWithLanding];
    
//    for (UIViewController *controller in self.navigationController.viewControllers)
//    {
//        if ([controller isKindOfClass:[HomeVC class]])
//        {
//            [self.navigationController popToViewController:controller animated:YES];
//            break;
//        }
//    }
}

-(void)apiCallForBookEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            TicketConfirmationVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketConfirmationVC"];
            [self.navigationController pushViewController:ticketVC animated:YES];
            
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField.returnKeyType == UIReturnKeyNext){
        if (textField.tag == 102) {
            [[self.view viewWithTag:textField.tag+2] becomeFirstResponder];
        }else{
            [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        }
    }else
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
            if ([string isEqualToString:@" "]) {
                return NO;
            }
            break;
        case 102:
        {
            if (TRIM_SPACE(validationstring).length > 64) {
                return NO;
            }
        }
            break;
            case 104:case 105:
            if (TRIM_SPACE(validationstring).length > 80) {
                return NO;
            }
            break;
        default:
            if (TRIM_SPACE(validationstring).length > 50) {
                return NO;
            }
            break;
    }
    return YES;
    
}


@end
