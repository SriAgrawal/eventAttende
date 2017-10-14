//
//  TicketVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.


#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "TicketTableViewCell.h"
#import "TicketInformationVC.h"
#import "AllTicketDisplayVC.h"
#import "ServiceHelper.h"
#import "TicketVC.h"
#import "EventModal.h"
#import "Macro.h"

static NSString *cellIdentifier = @"TicketTableViewCell";

@interface TicketVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *savedEventDetailArray;
    PAGE paginationData;
}
@property (weak, nonatomic) IBOutlet UITableView *ticketTableView;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation TicketVC

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
    [self historyEventRequest];
}

#pragma mark - Helper Method

- (void) initialSetup {
    //dynamic height
    self.ticketTableView.estimatedRowHeight = 400;
    savedEventDetailArray = [NSMutableArray array];
    
    [self.ticketTableView startIndicatorInMiddleOfView];
    
    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.ticketTableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
    
    [self historyEventRequest];
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [savedEventDetailArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = (TicketTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventModal *objModel = [savedEventDetailArray objectAtIndex:indexPath.row];
    NSString *totalQuantity = [NSString stringWithFormat:@"%lu",(unsigned long)[objModel.ticketInfoArray count]];

    cell.eventNameLabel.text = objModel.eventName;
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[objModel.eventStartDateTimeStamp integerValue]];
    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    [startDateFormatter setDateFormat: @"EEE MMMM dd hh:mm a"];
    [startDateFormatter setTimeZone:[NSTimeZone localTimeZone]];

    cell.eventscheduleLabel.text = [startDateFormatter stringFromDate:startDate];

    cell.totalTicketLabel.hidden = (self.isFromSaved) ? YES : NO;
    
    [cell.eventImageView sd_setImageWithURL:[NSURL URLWithString:objModel.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];

    
    NSAttributedString *atrributedString =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Ticket",totalQuantity]];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: atrributedString];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:AppColor
                 range:NSMakeRange(0,[[NSString stringWithFormat:@"%@",totalQuantity] length])];

    [cell.totalTicketLabel setAttributedText: text];

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isFromSaved) {

        EventModal *objModel = [savedEventDetailArray objectAtIndex:indexPath.row];
        
        AllTicketDisplayVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AllTicketDisplayVC"];
        ticketVC.eventModelData = objModel;
        [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:ticketVC] animated:YES completion:nil];

    
    }
}

#pragma mark - Refresh Data Method

-(void)refreshTableData:(NSNotification *)notify {
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    
    [self historyEventRequest];
}

#pragma mark UIScrollView delegates

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (self.isLoading)
        return;
    
    if (currentOffset - maximumOffset >= SCROLLUPREFRESHHEIGHT) {
        
        if (paginationData.totalNumberOfPages > paginationData.currentPage) {
            
            paginationData.currentPage++;
            [self historyEventRequest];
        }
    }
}



#pragma mark - Service Implemention

-(void)historyEventRequest {
    
    NSMutableDictionary *recommendedEventDict = [NSMutableDictionary new];
    
    [recommendedEventDict setValue:[NSNumber numberWithInt:paginationData.currentPage] forKey:pPageNumber];
    
    self.isLoading = YES;

    [recommendedEventDict setValue:@"booked_events" forKey:pType];
    [self apiCallForHistoryEvent:recommendedEventDict andServiceName:my_events_listAPI];
}

-(void)apiCallForHistoryEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.ticketTableView stopIndicator];
        
        self.isLoading = NO;
        
        if (!error) {
            //Success and 200 responseCode
            
            if (paginationData.currentPage == 1)
                [savedEventDetailArray removeAllObjects];

            
            NSArray *eventListArray = [result objectForKeyNotNull:pEvents expectedObj:[NSArray array]];
            if ([savedEventDetailArray count] || [eventListArray count]) {
                
                self.ticketTableView.backgroundView = nil;
                
                for (NSDictionary *eventDetail in eventListArray)
                    
                    [savedEventDetailArray addObject:[EventModal parseEventDetail:eventDetail]];
            }else {
                
                [self.ticketTableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];

           [self.ticketTableView reloadData];
            
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
