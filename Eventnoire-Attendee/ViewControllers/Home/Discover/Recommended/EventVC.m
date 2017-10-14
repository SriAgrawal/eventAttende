//
//  EventVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 31/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "RequestTimeOutView.h"
#import "EventTicketDetailVC.h"
#import "EventTableViewCell.h"
#import "EventDetailVC.h"
#import "ServiceHelper.h"
#import "EventModal.h"
#import "EventVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"EventTableViewCell";

@interface EventVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAddresslabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDistanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *eventFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *eventBookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *eventShareButton;
@property (weak, nonatomic) IBOutlet UIButton *eventShareHistoryButton;


@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *eventTableView;

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@end

@implementation EventVC

#pragma mark - UIView Controller Life Cycle & Memory Management

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
    //dynamic height
    self.eventTableView.estimatedRowHeight = 400.0f;
    
    if (self.eventViewType == History) {
        [self.registerButton setHidden:YES];
        [self.eventBookmarkButton setHidden:YES];
        [self.eventFavouriteButton setHidden:YES];
        [self.eventShareButton setHidden:YES];
        [self.eventShareHistoryButton setHidden:NO];

        

    }else {
        [self.registerButton setHidden:NO];
        [self.eventShareHistoryButton setHidden:YES];

    }
    
    //set register button title
    if ([self.eventDetailModal.eventTicketType isEqualToString:@"Free"]) {
        [self.registerButton setTitle:@"REGISTER HERE" forState:UIControlStateNormal];
        self.eventAmountLabel.text = self.eventDetailModal.eventTicketType;
    }else {
        [self.registerButton setTitle:@"GET TICKET" forState:UIControlStateNormal];
        self.eventAmountLabel.text = [NSString stringWithFormat:@"US - %@%@",self.eventDetailModal.eventTicketCurrency,self.eventDetailModal.eventTicketAmount];
    }
 
    //set camera position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.eventDetailModal.eventLatitutde doubleValue]
                                                            longitude:[self.eventDetailModal.eventLongitude doubleValue]
                                                                 zoom:6];
    [self.mapView setCamera:camera];
    self.mapView.myLocationEnabled = NO;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([self.eventDetailModal.eventLatitutde doubleValue], [self.eventDetailModal.eventLongitude doubleValue]);
    marker.map = self.mapView;
    
    //set label text
    self.eventNameLabel.text = self.eventDetailModal.eventName;
    self.eventDayLabel.text = self.eventDetailModal.eventStartDay;
    self.eventDateLabel.text = self.eventDetailModal.eventDateRange;
    self.eventMonthLabel.text = self.eventDetailModal.eventStartMonth;
    
    if ([self.eventDetailModal.eventCategory length]) {
        self.categoryLabel.text = self.eventDetailModal.eventCategory;
        [self.categoryLabel setHidden:NO];

    }else {
        [self.categoryLabel setHidden:YES];
    }
    
    if ([self.eventDetailModal.eventSubCategory length]) {
        self.subTypeLabel.text = self.eventDetailModal.eventSubCategory;
        [self.subTypeLabel setHidden:NO];
        
    }else {
        [self.subTypeLabel setHidden:YES];
    }
    
    [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:self.eventDetailModal.eventImagePathURL] placeholderImage:[UIImage imageNamed:@"eventPlaceholder"]];
    
    self.eventAddresslabel.text = self.eventDetailModal.eventAddress1;
    self.eventDistanceLabel.text = self.eventDetailModal.eventDistance;
    
    [self.eventFavouriteButton setSelected:self.eventDetailModal.isFavourite];
    [self.eventBookmarkButton setSelected:self.eventDetailModal.isBookmarked];
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.descriptionLabel.text = self.eventDetailModal.eventDescription;
    
    return cell;
}

#pragma mark - UIButton Action Method

- (IBAction)registerHereButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([self.eventDetailModal.eventTicketType isEqualToString:@"Free"]) {
        EventDetailVC *eventDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailVC"];
        eventDetailVC.eventDetailModal = self.eventDetailModal;
        [self.navigationController pushViewController:eventDetailVC animated:YES];
        
    }else {
        EventTicketDetailVC *eventTicketDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventTicketDetailVC"];
        eventTicketDetailVC.eventDetailModal = self.eventDetailModal;
        [self.navigationController pushViewController:eventTicketDetailVC animated:YES];
    }
}

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareButtonAction:(id)sender {
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

-(void)apiCallForBookmarkOrFavaourite:(NSString *)serviceName andType:(NSString *)type andStatus:(BOOL)isStatus {
    
    NSMutableDictionary *request = [NSMutableDictionary new];
    
    [request setValue:self.eventDetailModal.eventID forKey:pEventID];
    [request setValue:type forKey:pFlaggingType];
    [request setValue:isStatus?@"flag":@"unflag" forKey:pAction];
    
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
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }
    }];
}

@end
