//
//  EventDetailVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "OptionsPickerSheetView.h"
#import "ServiceHelper.h"
#import "EventDetailVC.h"
#import "EventModal.h"
#import "AttendeesVC.h"
#import "Macro.h"

@interface EventDetailVC ()

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatAvailabiltyLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTicketTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTicketLabel;

@property (weak, nonatomic) IBOutlet UIButton *eventFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *eventBookmarkButton;

@property (weak, nonatomic) IBOutlet UIButton *ticketSelectionButton;

@end

@implementation EventDetailVC

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

- (void)initialSetup {
    
   //set label text
   self.eventNameLabel.text = self.eventDetailModal.eventName;
   self.eventDayLabel.text = self.eventDetailModal.eventStartDay;
   self.eventDateLabel.text = self.eventDetailModal.eventDateRange;
   self.eventMonthLabel.text = self.eventDetailModal.eventStartMonth;
   self.eventTimeLabel.text = self.eventDetailModal.eventStartTime;
   self.eventTicketTypeLabel.text = self.eventDetailModal.eventTicketType;
    
    TicketModal *ticketInfo = [self.eventDetailModal.ticketInfoArray firstObject];
    [self.ticketSelectionButton setTitle:ticketInfo.bookSeats forState:UIControlStateNormal];

    if ([ticketInfo.ticketTotalSeat isEqualToString:@"0"] || [ticketInfo.ticketTotalSeat length] == 0) {
        self.seatAvailabiltyLabel.text = [NSString stringWithFormat:@"%@ [No seat available.]",ticketInfo.ticketName];
    }else {
        NSString *seatString = ([ticketInfo.ticketTotalSeat intValue] == 1)?@"seat":@"seats";
        self.seatAvailabiltyLabel.text = [NSString stringWithFormat:@"%@ [%@ %@ only]",ticketInfo.ticketName,ticketInfo.ticketTotalSeat,seatString];
    }
    
   self.totalTicketLabel.text = [NSString stringWithFormat:@"Qty: %@ (Free)",ticketInfo.bookSeats];
    
    [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:self.eventDetailModal.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
}

#pragma mark - UIButton Action Method

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    TicketModal *ticketInfo = [self.eventDetailModal.ticketInfoArray firstObject];
    ticketInfo.bookSeats = @"0";
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueButtonAction:(id)sender {
    [self.view endEditing:YES];
    
   TicketModal *ticketModal = [self.eventDetailModal.ticketInfoArray firstObject];
    if ([ticketModal.bookSeats isEqualToString:@"0"]) {
        [RequestTimeOutView showWithMessage:@"Please select ticket before go to further." forTime:2.0];
        
    }else {
        AttendeesVC *attendeesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AttendeesVC"];
        attendeesVC.eventDetailModal = self.eventDetailModal;
        [self.navigationController pushViewController:attendeesVC animated:YES];
    }
}

- (IBAction)incrementButtonAction:(id)sender {
    [self.view endEditing:YES];
//    int quantity = [self.Obj.quantityString intValue] + 1;
//    self.Obj.quantityString = [NSString stringWithFormat:@"%d",quantity];
//    self.quantityLabel.text = self.Obj.quantityString;
//    self.totalTicketLabel.text = [NSString stringWithFormat:@"Qty: %@ (Free)",self.Obj.quantityString];
}

- (IBAction)decrementButtonAction:(id)sender {
    [self.view endEditing:YES];
//   int quantity = ([self.Obj.quantityString intValue] > 1)?([self.Obj.quantityString intValue] - 1):[self.Obj.quantityString intValue];
//   self.Obj.quantityString = [NSString stringWithFormat:@"%d",quantity];
//   self.quantityLabel.text = self.Obj.quantityString;
//   self.totalTicketLabel.text = [NSString stringWithFormat:@"Qty: %@ (Free)",self.Obj.quantityString];
}

- (IBAction)ticketSelectionAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    TicketModal *ticketInfo = [self.eventDetailModal.ticketInfoArray firstObject];
    NSMutableArray *ticketSequence = [NSMutableArray array];
    
    for (int ticketNumber = 1; ticketNumber <= [ticketInfo.ticketRemainingSeats intValue]; ticketNumber++)
        [ticketSequence addObject:[NSString stringWithFormat:@"%d",ticketNumber]];
    
    if ([ticketSequence count]) {
        [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:[ticketSequence mutableCopy] AndComplitionblock:^(NSString *selectedText, NSInteger selectedIndex) {
            
            ticketInfo.bookSeats = selectedText;
            
            [self.ticketSelectionButton setTitle:ticketInfo.bookSeats forState:UIControlStateNormal];
            self.totalTicketLabel.text = [NSString stringWithFormat:@"Qty: %@ (Free)",ticketInfo.bookSeats];
        }];
    }else {
        [RequestTimeOutView showWithMessage:@"No ticket available." forTime:2.0];
    }
}

- (IBAction)shareButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSArray* sharedObjects=[NSArray arrayWithObjects:self.eventDetailModal.eventShareLink,  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)bookmarkButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andType:@"bookmark" andStatus:sender.selected];
}

- (IBAction)favouriteButtonAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andType:@"favourite" andStatus:sender.selected];
}

#pragma mark - Service Integration for Bookmark and Favourite

-(void)apiCallForBookmarkOrFavaourite:(NSString *)serviceName andType:(NSString *)type andStatus:(BOOL)isStatus {
    
    NSMutableDictionary *request = [NSMutableDictionary new];
    
    [request setValue:self.eventDetailModal.eventID forKey:pEventID];
    [request setValue:type forKey:pFlaggingType];
    [request setValue:isStatus?@"flag":@"unflag" forKey:pActions];
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            if ([type isEqualToString:@"bookmark"])
                self.eventDetailModal.isBookmarked = isStatus;
            else
                self.eventDetailModal.isFavourite = isStatus;
            
            [self.eventFavouriteButton setSelected:self.eventDetailModal.isFavourite];
            [self.eventBookmarkButton setSelected:self.eventDetailModal.isBookmarked];
            
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
