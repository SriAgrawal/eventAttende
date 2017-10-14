//
//  NotificationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 31/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "NotificationTableViewCell.h"
#import "ServiceHelper.h"
#import "NSDictionary+NullChecker.h"
#import "NotificationVC.h"
#import "NotificationModel.h"
#import "RequestTimeOutView.h"
#import "AlertView.h"
#import "Macro.h"

static NSString *cellIdentifier = @"NotificationTableViewCell";

@interface NotificationVC ()<UITableViewDelegate,UITableViewDataSource> {
    PAGE paginationData;
}

@property (weak, nonatomic) IBOutlet UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *notificationArray;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation NotificationVC

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
    //dynamic row height
    self.notificationTableView.estimatedRowHeight = 400.0f;

    [self.notificationTableView stopIndicator];
    [self.notificationTableView startIndicatorInMiddleOfView];
    
    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.notificationTableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
    
    //Initialise Array
    self.notificationArray = [[NSMutableArray alloc]init];
    [self notificationListRequest];
}


#pragma mark - UITableView Datasource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notificationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NotificationModel *objModel = [self.notificationArray objectAtIndex:indexPath.row];
    
    cell.notificationLabel.text = objModel.notificationMessageString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

//-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"       "  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        
//        [[AlertView sharedManager] presentAlertWithTitle:@"" message:@"Do you want to delete the notification?" andButtonsWithTitle:@[@"YES",@"NO"] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//            if (index == 0) {
//                [self.dataArray removeObjectAtIndex:indexPath.row];
//                [self.notificationTableView reloadData];
//            }
//        }];
//        
//    }];
//    
//    UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon1"]];
//    img2.frame = CGRectMake(cell.frame.size.width + 20, cell.frame.size.height / 3, 30, 30);
//    img2.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.contentView addSubview:img2];
//    deleteAction.backgroundColor = [UIColor whiteColor];
//    
//    return @[deleteAction];
//}

#pragma mark - UIButton Action Methods

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Refresh Data Method

-(void)refreshTableData:(NSNotification *)notify {
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    
    [self notificationListRequest];
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
            [self notificationListRequest];
        }
    }
}


#pragma mark - Service Implemention

-(void)notificationListRequest {
    
    NSMutableDictionary *notificationListDict = [NSMutableDictionary new];
    
    [notificationListDict setValue:[NSNumber numberWithInt:paginationData.currentPage] forKey:pPageNumber];
    self.isLoading = YES;
    
    [self apiCallForGettingNotificationList:notificationListDict andServiceName:getNotificationAPI];
}

-(void)apiCallForGettingNotificationList:(NSMutableDictionary *)notificationListDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:notificationListDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error) {
        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.notificationTableView stopIndicator];
        
        self.isLoading = NO;
        
        if (!error) {
            
            if (paginationData.currentPage == 1)
                [self.notificationArray removeAllObjects];
            
            //Success and 200 responseCode
            NSMutableArray *listArray = [result objectForKeyNotNull:pUserDetail expectedObj:[NSArray array]];
            
            if ([self.notificationArray count] || [listArray count]) {
                self.notificationTableView.backgroundView = nil;
                
                for (NSDictionary *notificationDict in listArray)
                    [self.notificationArray addObject:[NotificationModel notificationDetails:notificationDict]];
            }else {
                [self.notificationTableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];
            
            [self.notificationTableView reloadData];

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
