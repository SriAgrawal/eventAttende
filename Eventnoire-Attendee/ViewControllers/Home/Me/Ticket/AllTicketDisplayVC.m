//
//  AllTicketDisplayVC.m
//  Eventnoire-Attendee
//
//  Created by Ashish Kumar Gupta on 18/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "TicketTableViewCell.h"
#import "TicketInformationVC.h"
#import "TicketInformationVC.h"
#import "AllTicketDisplayVC.h"
#import "RequestTimeOutView.h"
#import "ServiceHelper.h"
#import "EventModal.h"
#import "TicketVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"TicketTableViewCell";


@interface AllTicketDisplayVC ()<UITableViewDelegate,UITableViewDataSource>{
	NSMutableArray *ticketBookedInfo;
}
@property (weak, nonatomic) IBOutlet UITableView *ticketTableView;

@end

@implementation AllTicketDisplayVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void) initialSetup {
    //dynamic height
    self.ticketTableView.estimatedRowHeight = 400;
  	NSLog(@"%@",self.eventModelData.ticketInfoArray);

	
	if (self.isFromPayment) {
		ticketBookedInfo = [[NSMutableArray alloc]init];
		for (TicketModal *ticketModal in self.eventModelData.ticketInfoArray) {
			if (![ticketModal.bookSeats isEqualToString:@"0"]) {
				[ticketBookedInfo addObject:ticketModal];
			}
		}
	}
	
	NSLog(@"%lu",(unsigned long)ticketBookedInfo.count);
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.isFromPayment) {
		return ticketBookedInfo.count;
	}else{
		return [self.eventModelData.ticketInfoArray count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = (TicketTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	
	if (self.isFromPayment) {
		
		TicketModal *ticketModel = [ticketBookedInfo objectAtIndex:indexPath.row];
		EventModal *eventModel = self.eventModelData;
		
		cell.eventNameLabel.text = ticketModel.ticketName;
		
		NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[eventModel.eventStartDateTimeStamp integerValue]];
		NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
		[startDateFormatter setDateFormat: @"EEE MMMM dd hh:mm a"];
		[startDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
		
		cell.eventscheduleLabel.text = [startDateFormatter stringFromDate:startDate];
		
		[cell.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventModel.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
		
		
		NSAttributedString *atrributedString =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Ticket",ticketModel.bookSeats]];
		
		NSMutableAttributedString *text =
		[[NSMutableAttributedString alloc]
		 initWithAttributedString: atrributedString];
		
		[text addAttribute:NSForegroundColorAttributeName
								 value:AppColor
								 range:NSMakeRange(0,[[NSString stringWithFormat:@"%@",ticketModel.bookSeats] length])];
		
		[cell.totalTicketLabel setAttributedText: text];

		
		
		
	}else{
		TicketModal *ticketModel = [self.eventModelData.ticketInfoArray objectAtIndex:indexPath.row];
		EventModal *eventModel = self.eventModelData;
		
		cell.eventNameLabel.text = ticketModel.ticketName;
		
		NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[eventModel.eventStartDateTimeStamp integerValue]];
		NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
		[startDateFormatter setDateFormat: @"EEE MMMM dd hh:mm a"];
		[startDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
		
		cell.eventscheduleLabel.text = [startDateFormatter stringFromDate:startDate];
		
		[cell.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventModel.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
		
		
		NSAttributedString *atrributedString =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Ticket",ticketModel.tQuantity]];
		
		NSMutableAttributedString *text =
		[[NSMutableAttributedString alloc]
		 initWithAttributedString: atrributedString];
		
		[text addAttribute:NSForegroundColorAttributeName
								 value:AppColor
								 range:NSMakeRange(0,[[NSString stringWithFormat:@"%@",ticketModel.tQuantity] length])];
		
		[cell.totalTicketLabel setAttributedText: text];

	}
	
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	if (!self.isFromPayment) {
		TicketInformationVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketInformationVC"];
		ticketVC.eventModelData = self.eventModelData;
		ticketVC.selectedIndex = indexPath.row;
		[self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:ticketVC] animated:YES completion:nil];

	}
	
	
}

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}





@end
