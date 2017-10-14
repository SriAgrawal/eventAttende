//
//  HistoryVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "ReccomendedTableViewCell.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "EventnoireButton.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "HistoryVC.h"
#import "EventModal.h"
#import "EventVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"ReccomendedTableViewCell";

@interface HistoryVC ()<UITableViewDelegate,UITableViewDataSource> {
    PAGE paginationData;
}


@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) NSMutableArray *historyDetailArray;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation HistoryVC

#pragma mark - UIViewController life cycle & memory management

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
    self.historyDetailArray = [NSMutableArray array];
    
    [self.historyTableView stopIndicator];
    [self.historyTableView startIndicatorInMiddleOfView];
    
    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.historyTableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
    
    [self historyEventRequest];
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 220.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.historyDetailArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReccomendedTableViewCell *cell = (ReccomendedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventModal *eventModal = [self.historyDetailArray objectAtIndex:indexPath.row];
    
    [cell.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventModal.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
    
    cell.eventNameLabel.text = eventModal.eventName;
    cell.monthLabel.text = eventModal.eventStartMonth;
    cell.dateLabel.text = eventModal.eventDateRange;
    
    if (![eventModal.eventCategory length] && ![eventModal.eventSubCategory length]) {
        cell.categoryLabel.hidden = YES;
        cell.subTypeLabel.hidden = YES;
        
    }else if ([eventModal.eventCategory length] && [eventModal.eventSubCategory length]) {
        cell.categoryLabel.hidden = NO;
        cell.subTypeLabel.hidden = NO;
        
        cell.categoryLabel.text = eventModal.eventCategory;
        cell.subTypeLabel.text = eventModal.eventSubCategory;
        
    }else if ([eventModal.eventCategory length]) {
        cell.categoryLabel.hidden = NO;
        cell.subTypeLabel.hidden = YES;
        
        cell.categoryLabel.text = eventModal.eventCategory;
    }else {
        cell.categoryLabel.hidden = NO;
        cell.subTypeLabel.hidden = YES;
        
        cell.categoryLabel.text = eventModal.eventSubCategory;
    }

    cell.dayLabel.text = eventModal.eventStartDay;
    
    cell.eventAmountLabel.text = ([eventModal.eventTicketType isEqualToString:@"Free"])? @"Free" : [NSString stringWithFormat:@"Paid -$%@",eventModal.eventTicketAmount];
    
    cell.shareButton.indexPath = indexPath;
    cell.bookmarkButton.indexPath = indexPath;
    cell.favoriteButton.indexPath = indexPath;
    
    [cell.bookmarkButton setSelected:eventModal.isBookmarked];
    [cell.favoriteButton setSelected:eventModal.isFavourite];

    
    [cell.shareButton addTarget:self action:@selector(sharingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
   
    [cell.bookmarkButton addTarget:self action:@selector(bookMarkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.favoriteButton addTarget:self action:@selector(favouriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventVC"];
    
    EventModal *eventModal = [self.historyDetailArray objectAtIndex:indexPath.row];
    eventVC.eventDetailModal = eventModal;
    eventVC.eventViewType = History;
    
    //eventVC.isFromPaid = (indexPath.row == 0) ? NO : YES;
    [self.navigationController pushViewController:eventVC animated:YES];
}


#pragma mark - UIButton Action Methods

- (void) sharingButtonAction : (EventnoireButton *) sender {
    [self.view endEditing:YES];
    
    EventModal *eventModal = [self.historyDetailArray objectAtIndex:sender.indexPath.row];
    
    NSArray* sharedObjects=[NSArray arrayWithObjects: eventModal.eventShareLink,  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    });
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
    [recommendedEventDict setValue:@"history" forKey:pType];
    
    if ([APPDELEGATE location]) {
        [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude] forKey:pLatitude];
        [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude] forKey:pLongitude];
    }
    
    [self apiCallForHistoryEvent:recommendedEventDict andServiceName:myEventListApi];
}

-(void)apiCallForHistoryEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.historyTableView stopIndicator];
        
        self.isLoading = NO;
        
        if (!error) {
            //Success and 200 responseCode
            if (paginationData.currentPage == 1)
                [self.historyDetailArray removeAllObjects];
            
            NSArray *eventListArray = [result objectForKeyNotNull:pEvents expectedObj:[NSArray array]];
            
            if ([self.historyDetailArray count] || [eventListArray count]) {
                self.historyTableView.backgroundView = nil;
                
                for (NSDictionary *eventDetail in eventListArray)
                    [self.historyDetailArray addObject:[EventModal parseEventDetail:eventDetail]];
            }else {
                [self.historyTableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];

            
            [self.historyTableView reloadData];
            
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

- (void) bookMarkButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.indexPath andType:@"bookmark" andStatus:sender.selected];
}

- (void) favouriteButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.indexPath andType:@"favourite" andStatus:sender.selected];
}
-(void)apiCallForBookmarkOrFavaourite:(NSString *)serviceName andSelectedIndex:(NSIndexPath *)selectedIndex andType:(NSString *)type andStatus:(BOOL)isStatus {
    
    EventModal *eventModal = [self.historyDetailArray objectAtIndex:selectedIndex.row];
    
    NSMutableDictionary *request = [NSMutableDictionary new];
    
    [request setValue:eventModal.eventID forKey:pEventID];
    [request setValue:type forKey:pFlaggingType];
    [request setValue:isStatus?@"flag":@"unflag" forKey:pAction];
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            if ([type isEqualToString:@"bookmark"])
                eventModal.isBookmarked = isStatus;
            else
                eventModal.isFavourite = isStatus;
            
            [self.historyTableView reloadData];
            
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
