//
//  CreateNewToDoVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "OptionsPickerSheetView.h"
#import "ServiceHelper.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "DatePickerSheetView.h"
#import "CreateNewToDoVC.h"
#import "EventToDoModel.h"
#import "LocationVC.h"
#import "AHTextView.h"
#import "AppUtility.h"
#import "Macro.h"

@interface CreateNewToDoVC ()<navigateAddressProtocol,UITextViewDelegate>{
    BOOL isCurrentDate;
    NSString *selectedEventId;
    NSMutableArray *eventListArray;
    
}
@property (weak, nonatomic) IBOutlet UIButton *selectEventButton;
@property (weak, nonatomic) IBOutlet UIButton *searchEventButton;
@property (weak, nonatomic) IBOutlet UIButton *selectDateButton;
@property (weak, nonatomic) IBOutlet UIButton *addTimeButton;

@property (weak, nonatomic) IBOutlet AHTextView *detailTextView;

@property (weak,nonatomic) NSString *today;

@property (weak, nonatomic) IBOutlet UILabel *selecteventAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchEventAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectDateTimeAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAlertLabel;
@end

@implementation CreateNewToDoVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    eventListArray = [[NSMutableArray alloc]init];
    [self fetchEventRequest];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void) initialSetup {
    //set textview placeholder
    self.detailTextView.placeholderText = @"Event Detail...";
    self.detailTextView.placeholderColor = [UIColor darkGrayColor];
    self.detailTextView.textColor = [UIColor darkGrayColor];
    
    //hide alert label
    self.selecteventAlertLabel.hidden = YES;
    self.searchEventAlertLabel.hidden = YES;
    self.selectDateTimeAlertLabel.hidden = YES;
    self.detailAlertLabel.hidden = YES;
    
}

#pragma mark- UIView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.detailAlertLabel.hidden = YES;

}

#pragma mark- Validation Helper Methods

- (BOOL)isallFieldsVerified {
    
    BOOL  isVerified = NO;
    
    if([self.selectEventButton.titleLabel.text isEqualToString:@"Select Event"]) {
        self.selecteventAlertLabel.hidden = NO;
        self.selecteventAlertLabel.text = blank_Event;
    }
    
    else if ([self.searchEventButton.titleLabel.text isEqualToString:@"Select Location"]) {
        self.searchEventAlertLabel.hidden = NO;
        self.searchEventAlertLabel.text = blank_Search_Event;
    }
    
    else if([self.selectDateButton.titleLabel.text isEqualToString:@"Select Date"]){
        self.selectDateTimeAlertLabel.hidden = NO;
        self.selectDateTimeAlertLabel.text = blank_Event_Date;
    }
    
    else if([self.addTimeButton.titleLabel.text isEqualToString:@"Add a Time"]){
        self.selectDateTimeAlertLabel.hidden = NO;
        self.selectDateTimeAlertLabel.text = blank_Event_Time;
    }
    
    else if(![self.detailTextView.text length]){
        self.detailAlertLabel.hidden = NO;
        self.detailAlertLabel.text = blank_Event_Detail;
    }

    else {
        isVerified = YES;
    }
    
    return isVerified;
}

#pragma mark - UIButton Action Methods

- (IBAction)selectEventButtonAction:(id)sender {
    [self.view endEditing:YES];
    self.selecteventAlertLabel.hidden = YES;
    
    if ([eventListArray count]) {
        NSMutableArray *eventNameList = [[NSMutableArray alloc]init];
        for (int count=0; count<eventListArray.count; count++) {
            EventToDoModel *objModel = [eventListArray objectAtIndex:count];
            [eventNameList addObject:objModel.eventNameString];
        }
        
        [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:eventNameList AndComplitionblock:^(NSString *selectedText, NSInteger selectedIndex) {
            EventToDoModel *objModel = [eventListArray objectAtIndex:selectedIndex];

            selectedEventId = objModel.eventIDString;
            [self.selectEventButton setTitle:selectedText forState:UIControlStateNormal];
        }];
    }else{
        [RequestTimeOutView showWithMessage:no_event forTime:2.0];
       
    }
}

- (IBAction)searchEventButtonAction:(id)sender {
    [self.view endEditing:YES];
    self.searchEventAlertLabel.hidden = YES;
    LocationVC *locationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationVC"];
    locationVC.delegate = self;
    [self.navigationController presentViewController:locationVC animated:YES completion:nil];
}

- (IBAction)selectDateButtonAction:(id)sender {
    [self.view endEditing:YES];
    self.selectDateTimeAlertLabel.hidden = YES;
    [DatePickerSheetView showDatePickerWithDate:[NSDate date]
                                    AndTimeZone:@"systemTimeZone" datePickerType:UIDatePickerModeDate
                                 WithReturnDate:^(NSDate *date){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *pmamDateString = [dateFormatter stringFromDate:date];
        
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        if([today day] == [otherDay day] &&
           [today month] == [otherDay month] &&
           [today year] == [otherDay year] &&
           [today era] == [otherDay era]) {
            isCurrentDate = YES;
            self.selectDateTimeAlertLabel.hidden = NO;
            self.selectDateTimeAlertLabel.text = blank_Event_Time;
           [self.addTimeButton setTitle:@"Add a Time" forState:UIControlStateNormal];
        }
        else{
            isCurrentDate = NO;
            
        }
        [self.selectDateButton setTitle:pmamDateString forState:UIControlStateNormal];
        self.selectDateTimeAlertLabel.hidden = YES;

    }];
    
}

- (IBAction)addTimeButtonAction:(id)sender {
    [self.view endEditing:YES];
    self.selectDateTimeAlertLabel.hidden = YES;
    
    if([self.selectDateButton.currentTitle length]){
        [DatePickerSheetView showDatePickerWithDateWithMyCustomMethodWithBool:NO withDate:[NSDate date]  AndTimeZone:[NSString stringWithFormat:@"%@",[NSTimeZone systemTimeZone]] datePickerType:UIDatePickerModeTime WithReturnDate:^(NSDate *date)
         {
            
            if (isCurrentDate) {
                
                NSDate* now = [NSDate date];
                NSComparisonResult result = [date compare:now];
                if(result == NSOrderedDescending)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; dateFormatter.dateFormat = @"hh:mm a";
                    NSString *pmamDateString = [dateFormatter stringFromDate:date];
                    [self.addTimeButton setTitle:pmamDateString forState:UIControlStateNormal];
                }
                else if(result == NSOrderedAscending)
                {
                    [self.addTimeButton setTitle:@"Add a Time" forState:UIControlStateNormal];
                    self.selectDateTimeAlertLabel.text = invalid_Event_Time;
                    self.selectDateTimeAlertLabel.hidden = NO;

                }
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; dateFormatter.dateFormat = @"hh:mm a";
                NSString *pmamDateString = [dateFormatter stringFromDate:date];
                [self.addTimeButton setTitle:pmamDateString forState:UIControlStateNormal];
            }
        }];

        
      
    
    }else
    {
        self.selectDateTimeAlertLabel.hidden = NO;
        self.selectDateTimeAlertLabel.text = blank_Event_Time;

    }


}

- (IBAction)createButtonAction:(id)sender {
    [self.view endEditing:YES];
    if ([self isallFieldsVerified]) {
        [self createToDoEventRequest];
    }
}

#pragma mark - Location Screen Delegate Method

-(void)navigateToControllerAddress : (GMSPlace *)Address {
    [self.searchEventButton setTitle:Address.formattedAddress forState:UIControlStateNormal];
}


#pragma mark - Service Implemention

-(void)createToDoEventRequest {
    
    NSString *combinedDateTime = [[self.selectDateButton.titleLabel.text stringByAppendingString:@" "]stringByAppendingString:_addTimeButton.titleLabel.text];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"] ;
    NSDate *date = [dateFormatter dateFromString:combinedDateTime];

    NSMutableDictionary *createToDoDict = [NSMutableDictionary new];
    [createToDoDict setValue:selectedEventId forKey:pEventId];
    [createToDoDict setValue:self.searchEventButton.titleLabel.text forKey:pEventLocation];
    [createToDoDict setValue:self.detailTextView.text forKey:pEventDetail];
    [createToDoDict setValue:[NSString stringWithFormat:@"%f",[date timeIntervalSince1970]] forKey:pEventDateTime];

    
    [self apiCallForCreatingToDoEvent:createToDoDict andServiceName:createToDoApi];
}

-(void)fetchEventRequest {
    
    NSMutableDictionary *createToDoDict = [NSMutableDictionary new];
    [self apiCallForFetchingUserEvent:createToDoDict andServiceName:eventListForToDoApi];
}


-(void)apiCallForCreatingToDoEvent:(NSMutableDictionary *)createToDoDict andServiceName:(NSString *)serviceName {
    
     [[ServiceHelper sharedServiceHelper] callApiWithParameter:createToDoDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        if (!error) {
            //Success and 200 responseCode
                        NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
                        [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
            [self.selectEventButton setTitle:@"Select Event" forState:UIControlStateNormal];
            [self.searchEventButton setTitle:@"Search Location" forState:UIControlStateNormal];
            [self.selectDateButton setTitle:@"Select Date" forState:UIControlStateNormal];
            [self.addTimeButton setTitle:@"Add a Time" forState:UIControlStateNormal];
            self.detailTextView.text = @"";


            
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


-(void)apiCallForFetchingUserEvent:(NSMutableDictionary *)createToDoDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:createToDoDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        if (!error) {
            //Success and 200 responseCode
            if ([[result objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 200) {
                NSMutableArray *listArray = [result objectForKeyNotNull:pUserDetail expectedObj:[NSArray array]];
                for (NSDictionary *dict in listArray) {
                    EventToDoModel *obj = [EventToDoModel eventListForUser:dict];
                    [eventListArray addObject:obj];
                }
            }

            
        }else if (error.code == 100) {
            //Success but other than 200 responseCode
            NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSDictionary dictionary]];
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }else {
            //Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];        }
    }];
}



@end
