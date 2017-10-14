//
//  InfoVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "EventBookInfoModel.h"
#import "EventModal.h"
#import "RequestTimeOutView.h"
#import "InfoTableViewCell.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "InfoVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"InfoTableViewCell";

@interface InfoVC ()<UITableViewDataSource,UITableViewDelegate,GMSMapViewDelegate>{
    NSMutableArray *eventInfoArray;
}
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *toDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (assign, nonatomic) BOOL isDynamicHeight;

@end

@implementation InfoVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialsetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void)initialsetup {
    //set dynamic height
    self.infoTableView.estimatedRowHeight = 400;
    eventInfoArray = [[NSMutableArray alloc]init];
    
    [self ticketIndoCall];
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.isDynamicHeight)? UITableViewAutomaticDimension : 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [eventInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoTableViewCell *cell = (InfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EventBookInfoModel *eventDetail = [eventInfoArray firstObject];
    
    (self.isDynamicHeight) ? [cell.moreButton setTitle:@"less.." forState:UIControlStateNormal] : [cell.moreButton setTitle:@"more.." forState:UIControlStateNormal];
	[cell.moreButton setHidden:!eventDetail.isMoreNeeded];

    cell.descriptionLabel.text = eventDetail.eventDescription;
    [cell.moreButton addTarget:self action:@selector(moreButtonAction :) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UIButton Action Methods

- (void) moreButtonAction : (UIButton *) sender {
    sender.selected = !sender.selected;
    self.isDynamicHeight = sender.selected;
    [self.infoTableView reloadData];
}

#pragma mark - Service Implemention

-(void)ticketIndoCall
{
    TicketModal *ticketModel = [self.eventModelData.ticketInfoArray objectAtIndex:self.selectedIndex];
    
    NSMutableDictionary *ticketDict = [NSMutableDictionary new];
    [ticketDict setValue:self.eventModelData.eventID forKey:pEventID];
    [ticketDict setValue:ticketModel.ticketID forKey:pEvent_ticket_id];
    if ([APPDELEGATE location]) {
        [ticketDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude] forKey:pLatitude];
        [ticketDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude] forKey:pLongitude];
    }
    
    [self apiCallForTicketInfo:ticketDict andServiceName:book_event_infoAPI];
}

-(void)apiCallForTicketInfo:(NSMutableDictionary *)ticketDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:ticketDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
                NSMutableArray *eventDetail = [result objectForKeyNotNull:pEvent_details expectedObj:[NSArray array]];
                
                for (NSDictionary *dict in eventDetail) {
                    EventBookInfoModel *obj = [EventBookInfoModel eventDetails:dict];
                    [eventInfoArray addObject:obj];
                }
                
                [self addEventDataOnView];
            
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


-(void)addEventDataOnView{
    
    EventBookInfoModel *objModel = [eventInfoArray objectAtIndex:0];
    
    //set camera position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[objModel.eventLatitude doubleValue]
                                                            longitude:[objModel.eventLongitude doubleValue]
                                                                 zoom:6];
    [self.mapView setCamera:camera];
    self.mapView.myLocationEnabled = NO;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([objModel.eventLatitude doubleValue], [objModel.eventLongitude doubleValue]);
    marker.map = self.mapView;
    
    //set label text
    self.eventNameLabel.text = objModel.eventName;
    self.fromDateLabel.text = objModel.eventStartDateModified;
    self.fromTimeLabel.text = objModel.eventStartTimeModified;
    self.toDateLabel.text = objModel.eventEndDateModified;
    self.toTimeLabel.text = objModel.eventEndTimeModified;
    self.locationNameLabel.text = objModel.eventVenueName;
    self.distanceLabel.text = objModel.eventDistance;
    
    //set imageView image
     [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:objModel.eventImage] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
    
    [_infoTableView reloadData];
}

@end
