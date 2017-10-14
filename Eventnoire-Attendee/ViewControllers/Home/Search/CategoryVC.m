//
//  CategoryVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 06/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//


#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "NSDictionary+NullChecker.h"
#import "ReccomendedTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "EventnoireButton.h"
#import "ServiceHelper.h"
#import "CategoryVC.h"
#import "EventModal.h"
#import "EventVC.h"
#import "Macro.h"


static NSString *cellIdentifier = @"ReccomendedTableViewCell";

@interface CategoryVC () <UITableViewDataSource,UITableViewDelegate>{
    PAGE paginationData;
}

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLabel;

@property (strong, nonatomic) NSMutableArray *eventArray;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation CategoryVC

#pragma mark - UIViewController Life Cycle & Memory management

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
    //set navigation title text
    self.eventArray = [NSMutableArray array];
    
    [self.categoryTableView stopIndicator];
    [self.categoryTableView startIndicatorInMiddleOfView];

    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.categoryTableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
    
    [self fetchAllEventList];

}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 220.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReccomendedTableViewCell *cell = (ReccomendedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventModal *eventModal = [self.eventArray objectAtIndex:indexPath.row];
    
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
    
    cell.eventAmountLabel.text = ([eventModal.eventTicketType isEqualToString:@"Free"])? eventModal.eventTicketType : [NSString stringWithFormat:@"%@ -%@%@",eventModal.eventTicketType,eventModal.eventTicketCurrency,eventModal.eventTicketAmount];
    
    cell.shareButton.tag = indexPath.row;
    cell.bookmarkButton.tag = indexPath.row;
    cell.favoriteButton.tag = indexPath.row;
    
    [cell.bookmarkButton setSelected:eventModal.isBookmarked];
    [cell.favoriteButton setSelected:eventModal.isFavourite];
    
    [cell.shareButton addTarget:self action:@selector(sharingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bookmarkButton addTarget:self action:@selector(bookMarkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.favoriteButton addTarget:self action:@selector(favouriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventVC"];
    EventModal *eventModal = [self.eventArray objectAtIndex:indexPath.row];
    eventVC.eventDetailModal = eventModal;
    eventVC.eventViewType = General;

    [self.navigationController pushViewController:eventVC animated:YES];
}

#pragma mark - UIButton Action Methods

- (void) sharingButtonAction : (EventnoireButton *) sender {
    [self.view endEditing:YES];
    
    EventModal *eventModal = [self.eventArray objectAtIndex:sender.tag];
    
    NSArray* sharedObjects=[NSArray arrayWithObjects: eventModal.eventShareLink,  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    });
}

- (void) bookMarkButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.tag andType:@"bookmark" andStatus:sender.selected];
}

- (void) favouriteButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.tag andType:@"favourite" andStatus:sender.selected];
}



-(void)fetchAllEventList{
   
    
    NSMutableDictionary *searchedEventDict = [NSMutableDictionary new];
    [searchedEventDict setValue:@"" forKey:pType];
    [searchedEventDict setValue:self.eventLatitude forKey:pLatitude];
    [searchedEventDict setValue:self.eventLongitude forKey:pLongitude];
    [searchedEventDict setValue:@"" forKey:pEventID];
    [searchedEventDict setValue:self.searchedEvent forKey:pSearch_event];
    [searchedEventDict setValue:self.searchedEventId forKey:pInterest_id];
    
    [searchedEventDict setValue:[NSNumber numberWithInt:paginationData.currentPage] forKey:pPageNumber];
    self.isLoading = YES;

    
    [self apiCallForRecommendedEvent:searchedEventDict andServiceName:eventListApi];
}


-(void)apiCallForRecommendedEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.categoryTableView stopIndicator];
        
        self.isLoading = NO;

        if (!error) {
            //Success and 200 responseCode
            
            if (paginationData.currentPage == 1)
                [self.eventArray removeAllObjects];

            NSArray *eventListArray = [result objectForKeyNotNull:pEvents expectedObj:[NSArray array]];
            
            if ([self.eventArray count] || [eventListArray count]) {
                self.categoryTableView.backgroundView = nil;
                
                for (NSDictionary *eventDetail in eventListArray)
                    [self.eventArray addObject:[EventModal parseEventDetail:eventDetail]];
            }else {
                [self.categoryTableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];
            
            [self.categoryTableView reloadData];
            
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

-(void)apiCallForBookmarkOrFavaourite:(NSString *)serviceName andSelectedIndex:(NSInteger)selectedIndex andType:(NSString *)type andStatus:(BOOL)isStatus {
    
    EventModal *eventModal = [self.eventArray objectAtIndex:selectedIndex];
    
    NSMutableDictionary *request = [NSMutableDictionary new];
    
    [request setValue:eventModal.eventID forKey:pEventID];
    [request setValue:type forKey:pFlaggingType];
    [request setValue:isStatus?@"flag":@"unflag" forKey:pActions];
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            if ([type isEqualToString:@"bookmark"])
                eventModal.isBookmarked = isStatus;
            else
                eventModal.isFavourite = isStatus;
            
            [self.categoryTableView reloadData];
            
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

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Refresh Data Method

-(void)refreshTableData:(NSNotification *)notify {
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    
    [self fetchAllEventList];
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
            [self fetchAllEventList];
        }
    }
}

@end
