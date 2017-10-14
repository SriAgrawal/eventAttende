//
//  RecommendedVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "ReccomendedTableViewCell.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "EventnoireButton.h"
#import "RecommendedVC.h"
#import "AppDelegate.h"
#import "ServiceHelper.h"
#import "EventModal.h"
#import "EventVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"ReccomendedTableViewCell";

@interface RecommendedVC ()<UITableViewDelegate,UITableViewDataSource>{
    PAGE paginationData;
}

@property (weak, nonatomic) IBOutlet UITableView *recommendedTableView;
@property (strong, nonatomic) NSMutableArray *recommendedArray;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation RecommendedVC

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
 
    [self recommendedEventRequest:nil andComingFromLocation:NO];
}

#pragma mark - Helper Method

- (void) initialSetup {
    self.recommendedArray = [NSMutableArray array];
    
   // [self.recommendedTableView stopIndicator];
    [self.recommendedTableView startIndicatorInMiddleOfView];
    
    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.recommendedTableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Refresh Data Method

-(void)refreshTableData:(NSNotification *)notify {
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    
    [self recommendedEventRequest:nil andComingFromLocation:NO];
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
            [self recommendedEventRequest:nil andComingFromLocation:NO];
        }
    }
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 225.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recommendedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReccomendedTableViewCell *cell = (ReccomendedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventModal *eventModal = [self.recommendedArray objectAtIndex:indexPath.row];
    
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
    
    EventModal *eventModal = [self.recommendedArray objectAtIndex:indexPath.row];
    eventVC.eventDetailModal = eventModal;
    eventVC.eventViewType = General;

    //eventVC.isFromPaid = (indexPath.row == 0) ? NO : YES;
    [self.navigationController pushViewController:eventVC animated:YES];
}

#pragma mark - UIButton Action Methods

- (void) sharingButtonAction : (EventnoireButton *) sender {
    [self.view endEditing:YES];

    EventModal *eventModal = [self.recommendedArray objectAtIndex:sender.indexPath.row];
   
    NSArray* sharedObjects=[NSArray arrayWithObjects: eventModal.eventShareLink,  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityViewController animated:YES completion:nil];

    });
}

- (void) bookMarkButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;
    
    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.indexPath andType:@"bookmark" andStatus:sender.selected];
}

- (void) favouriteButtonAction : (EventnoireButton *) sender {
    sender.selected = !sender.selected;

    [self apiCallForBookmarkOrFavaourite:setActionApi andSelectedIndex:sender.indexPath andType:@"favourite" andStatus:sender.selected];
}

#pragma mark - Service Implemention

-(void)recommendedEventRequest : (GMSPlace *)addressDetail andComingFromLocation:(BOOL)isComingFromLocation {
    
    if (isComingFromLocation)
        [self.recommendedArray removeAllObjects];
    
    NSMutableDictionary *recommendedEventDict = [NSMutableDictionary new];
    
    switch (self.eventType) {
        case Recommended:
            [recommendedEventDict setValue:@"recommended" forKey:pType];
            
            break;
        case Popular:
            [recommendedEventDict setValue:@"popular" forKey:pType];
            break;
        case Friend:{
            NSDictionary *tempDict = [NSUSERDEFAULT valueForKey:pUserDetail];
            if ([[tempDict objectForKeyNotNull:pLogInType expectedObj:@""] isEqualToString:@"facebook"]){
            [recommendedEventDict setValue:@"friends" forKey:pType];
            }else{
            [recommendedEventDict setValue:@"feature" forKey:pType];
            }
        }
            break;
        case Featured:
            [recommendedEventDict setValue:@"feature" forKey:pType];

            break;
        default:
            break;
    }
    
    if (addressDetail) {
        [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",addressDetail.coordinate.latitude] forKey:pLatitude];
        [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",addressDetail.coordinate.longitude] forKey:pLongitude];
    }else {
        if ([APPDELEGATE location]) {
            [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude] forKey:pLatitude];
            [recommendedEventDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude] forKey:pLongitude];
        }
    }

    [recommendedEventDict setValue:[NSNumber numberWithInt:paginationData.currentPage] forKey:pPageNumber];
    self.isLoading = YES;
    
    [self apiCallForRecommendedEvent:recommendedEventDict andServiceName:eventListApi];
}


-(void)apiCallForRecommendedEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.recommendedTableView stopIndicator];
        
        self.isLoading = NO;
        
        if (!error) {
            //Success and 200 responseCode

            if (paginationData.currentPage == 1)
                [self.recommendedArray removeAllObjects];
            
            NSArray *eventListArray = [result objectForKeyNotNull:pEvents expectedObj:[NSArray array]];
            
            if ([self.recommendedArray count] || [eventListArray count]) {
                self.recommendedTableView.backgroundView = nil;
                
                for (NSDictionary *eventDetail in eventListArray)
                    [self.recommendedArray addObject:[EventModal parseEventDetail:eventDetail]];
            }else {
                [self.recommendedTableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];
            
            [self.recommendedTableView reloadData];
            
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

-(void)apiCallForBookmarkOrFavaourite:(NSString *)serviceName andSelectedIndex:(NSIndexPath *)selectedIndex andType:(NSString *)type andStatus:(BOOL)isStatus {
    
    EventModal *eventModal = [self.recommendedArray objectAtIndex:selectedIndex.row];
    
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
            
            [self.recommendedTableView reloadData];
            
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
