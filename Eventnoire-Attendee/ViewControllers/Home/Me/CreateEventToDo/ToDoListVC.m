//
//  ToDoListVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "UITableView+SetIndicatorAndLabelInMiddle.h"
#import "ToDoListTableViewCell.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "TicketInformationVC.h"
#import "EventToDoModel.h"
#import "ServiceHelper.h"
#import "ToDoListVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"ToDoListTableViewCell";

@interface ToDoListVC ()<UITableViewDelegate,UITableViewDataSource> {
    PAGE paginationData;
    BOOL isRequiredHud;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *toDoListArray;

//Refresh
@property (nonatomic, strong) UIRefreshControl *refereshControl;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation ToDoListVC

#pragma mark - UIViewController life cycle & memory management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isRequiredHud = YES;
    [self initialSetup];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.toDoListArray = [[NSMutableArray alloc]init];
    [self toDoListRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper method

- (void) initialSetup {
    //set dynamic height
    self.tableView.estimatedRowHeight = 400;
    
    [self.tableView startIndicatorInMiddleOfView];
    
    //Pagination
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    self.isLoading = NO;
    
    //Refresh Data
    self.refereshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refereshControl];
    [self.refereshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
    
   
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.toDoListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoListTableViewCell *cell = (ToDoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventToDoModel *objModel = [self.toDoListArray objectAtIndex:indexPath.row];
    cell.eventNameLabel.text = objModel.eventNameString;
    cell.createdDateLabel.text = [NSString stringWithFormat:@"Created Date : %@",objModel.createdTimeString];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

#pragma mark - Refresh Data Method

-(void)refreshTableData:(NSNotification *)notify {
    paginationData.currentPage = 1;
    paginationData.totalNumberOfPages = 0;
    
    [self toDoListRequest];
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
            [self toDoListRequest];
        }
    }
}

#pragma mark - Service Implemention

-(void)toDoListRequest {
    
    NSMutableDictionary *toDoListDict = [NSMutableDictionary new];
    
    [toDoListDict setValue:[NSNumber numberWithInt:paginationData.currentPage] forKey:pPageNumber];
    
    self.isLoading = YES;
    
    [self apiCallForGettingtoDoList:toDoListDict andServiceName:toDoListApi];
}

-(void)apiCallForGettingtoDoList:(NSMutableDictionary *)toDoListDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:toDoListDict apiName:serviceName andApiType:POST andIsRequiredHud:isRequiredHud WithComptionBlock:^(NSDictionary *result, NSError *error) {

        //Stop Refresh Data Process
        [self.refereshControl endRefreshing];
        [self.tableView stopIndicator];
        
        self.isLoading = NO;
        isRequiredHud = NO;
        
        if (!error) {
            if (paginationData.currentPage == 1)
                [self.toDoListArray removeAllObjects];
            
            //Success and 200 responseCode
            NSArray *listArray = [result objectForKeyNotNull:pUserDetail expectedObj:[NSArray array]];
            
            if ([self.toDoListArray count] || [listArray count]) {
                self.tableView.backgroundView = nil;
                
                for (NSDictionary *dict in listArray)
                    [self.toDoListArray addObject:[EventToDoModel eventToDoDetails:dict]];
            }else {
                [self.tableView setTextInMiddleOfView:[result objectForKeyNotNull:pResponseMessage expectedObj:@"No data found."]];
            }
            
            NSDictionary *paginationDict = [result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]];
            
            //Pagination Detail
            paginationData.currentPage = [[paginationDict objectForKeyNotNull:pPageNumber expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfPages = [[paginationDict objectForKeyNotNull:pMaximumPages expectedObj:[NSString string]] intValue];
            paginationData.totalNumberOfRecord = [[paginationDict objectForKeyNotNull:pTotalNumberOfRecords expectedObj:[NSString string]] intValue];
            
            [self.tableView reloadData];
            
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
