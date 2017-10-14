//
//  EventTicketDetailVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "OptionsPickerSheetView.h"
#import "RequestTimeOutView.h"
#import "EventTicketDetailVC.h"
#import "EventnoireButton.h"
#import "PaidTicketCell.h"
#import "EventPayVC.h"
#import "EventModal.h"

static NSString *cellIdentifier = @"PaidTicketCell";

@interface EventTicketDetailVC ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventScheduleLabel;

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation EventTicketDetailVC

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

#pragma mark - Helper method

- (void) initialSetup {
    //set label text
    self.eventNameLabel.text = self.eventDetailModal.eventName;
    
    [self.eventScheduleLabel setText:[NSString stringWithFormat:@"%@, %@ to %@, %@ at %@",self.eventDetailModal.eventStartMonth,self.eventDetailModal.eventStartDateString,self.eventDetailModal.eventEndMonth,self.eventDetailModal.eventEndDateString,self.eventDetailModal.eventStartTime]];
   // self.eventScheduleLabel.text = @"MON, 06th March 2017 From 12:30 PM to 2:00 PM (IST)";
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventDetailModal.ticketInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PaidTicketCell *cell = (PaidTicketCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TicketModal *ticketModal = [self.eventDetailModal.ticketInfoArray objectAtIndex:indexPath.row];
    
    cell.ticketName.text = [NSString stringWithFormat:@"%@ [%@]",ticketModal.ticketName,ticketModal.ticketType];
    [cell.bookedButton setTitle:ticketModal.bookSeats forState:UIControlStateNormal];
    
    cell.ticketPriceLabel.text = [NSString stringWithFormat:@"%@%@",self.eventDetailModal.eventTicketCurrency,ticketModal.ticketAmount];

    [cell.bookedButton setIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    
    if ([ticketModal.ticketStatus boolValue]) {
        cell.userInteractionEnabled = YES;
        [cell.dropDownImage setHidden:NO];
        cell.arrowDownWidth.constant = 10;
        
        [cell.bookedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }else {
        cell.userInteractionEnabled = NO;
        [cell.dropDownImage setHidden:YES];
        cell.arrowDownWidth.constant = 0;

        [cell.bookedButton setTitle:@"Sold Out" forState:UIControlStateNormal];
        [cell.bookedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    [cell.bookedButton addTarget:self action:@selector(quantityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


#pragma mark - UIButton Action Methods

- (void)quantityButtonAction:(EventnoireButton *)sender {
    [self.view endEditing:YES];
    
    TicketModal *ticketInfo = [self.eventDetailModal.ticketInfoArray objectAtIndex:sender.indexPath.row];
    NSMutableArray *ticketSequence = [NSMutableArray array];
    
    for (int ticketNumber = 1; ticketNumber <= [ticketInfo.ticketRemainingSeats intValue]; ticketNumber++)
        [ticketSequence addObject:[NSString stringWithFormat:@"%d",ticketNumber]];
    
    if ([ticketSequence count]) {
        [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:[ticketSequence mutableCopy] AndComplitionblock:^(NSString *selectedText, NSInteger selectedIndex) {
            
            ticketInfo.bookSeats = selectedText;
            
            [self.tblView reloadData];
        }];
    }else {
        [RequestTimeOutView showWithMessage:@"No ticket available." forTime:2.0];
    }
}

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    for (TicketModal *ticket in self.eventDetailModal.ticketInfoArray)
        ticket.bookSeats = @"0";
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)orderNowButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    NSInteger totalTicket = 0;
    
    for (TicketModal *ticketInfo in self.eventDetailModal.ticketInfoArray)
        totalTicket = totalTicket + [ticketInfo.bookSeats integerValue];

    if (totalTicket != 0) {
        self.eventDetailModal.eventTotalTickets = [NSString stringWithFormat:@"%ld",(long)totalTicket];
        EventPayVC *eventPayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventPayVC"];
        eventPayVC.eventDetailModal = self.eventDetailModal;
        [self.navigationController pushViewController:eventPayVC animated:YES];
    }else {
        [RequestTimeOutView showWithMessage:@"Please apply ticket for furture process." forTime:2.0];
    }
   
}
@end
