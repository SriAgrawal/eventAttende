//
//  RegistrationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "UIImageView+WebCache.h"
#import "EventBookInfoModel.h"
#import <EventKit/EventKit.h>
#import <PassKit/PassKit.h>
#import "RegistrationVC.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "Macro.h"

@interface RegistrationVC ()<PKAddPassesViewControllerDelegate> {
    NSMutableArray *eventInfoArray;
}

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@end

@implementation RegistrationVC

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
    //set label text
    self.userNameLabel.text = @"";
    eventInfoArray = [[NSMutableArray alloc]init];
    
    [self ticketIndoCall:book_event_infoAPI];
}

#pragma mark - UIButton Action Methods

- (IBAction)appleWalletButtonAction:(id)sender {
    [self ticketIndoCall:ticketPass];
}

- (IBAction)calenderButtonAction:(id)sender {
    [self saveEventInCalender];
}


-(void)saveEventInCalender
{
    
    EventBookInfoModel *objModel = [eventInfoArray objectAtIndex:0];
    
    NSString *eventStartDateStr = objModel.eventStartDate;
    NSString *eventEndDateStr = objModel.eventEndDate;

    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                }
                else if (!granted){
                }
                else{
                    
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[eventStartDateStr integerValue]];
                    
                      NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[eventEndDateStr integerValue]];
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title = objModel.eventName;
                    event.location = objModel.eventVenueName;
                    event.calendar = [eventStore defaultCalendarForNewEvents];
                    
                    event.startDate = startDate;
                    event.endDate = endDate;
                    event.notes = objModel.eventDescription;
                    event.allDay = NO;
                    
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -30.0f]];
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    NSString *message = [[[@"Your event [" stringByAppendingString:objModel.eventName]stringByAppendingString:@"] "]stringByAppendingString:@"has been successfully saved in calendar."];
                    [RequestTimeOutView showWithMessage:message forTime:2.0];
                }
            });
        }];
    }
}


#pragma mark - Service Implemention

-(void)ticketIndoCall:(NSString *)serviceName
{
    TicketModal *ticketModel = [self.eventModelData.ticketInfoArray objectAtIndex:self.selectedIndex];
    
    NSMutableDictionary *ticketDict = [NSMutableDictionary new];
    [ticketDict setValue:self.eventModelData.eventID forKey:pEventID];
    [ticketDict setValue:ticketModel.ticketID forKey:pEvent_ticket_id];
  
    if ([APPDELEGATE location]) {
        [ticketDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude] forKey:pLatitude];
        [ticketDict setValue:[NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude] forKey:pLongitude];
    }

    if ([serviceName isEqualToString:book_event_infoAPI]) {
        [self apiCallForTicketInfo:ticketDict andServiceName:serviceName];
    }else {
        [self apiCallForTicketAddToWallet:ticketDict andServiceName:serviceName];
    }
}

-(void)apiCallForTicketInfo:(NSMutableDictionary *)ticketDict andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:ticketDict apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
                NSArray *ticketDetail = [result objectForKeyNotNull:pTicket_details expectedObj:[NSArray array]];
                NSArray *eventDetail = [result objectForKeyNotNull:pEvent_details expectedObj:[NSArray array]];
            
                for (NSDictionary *dict in ticketDetail) {
                    EventBookInfoModel *obj = [EventBookInfoModel ticketsDetails:dict];
                    self.userNameLabel.text = [[obj.firstNameTicketOwner stringByAppendingString:@" "]stringByAppendingString:obj.lastNameTicketOwner];
                     [self.scanImageView sd_setImageWithURL:[NSURL URLWithString:obj.QrCodeUrl] placeholderImage:[UIImage imageNamed:@""]];
                }
                
                for (NSDictionary *dict in eventDetail) {
                    EventBookInfoModel *obj = [EventBookInfoModel eventDetails:dict];
                    [eventInfoArray addObject:obj];
                }
            
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

-(void)apiCallForTicketAddToWallet:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            NSString *eventURLForStore = [result objectForKeyNotNull:pEventPKPass expectedObj:[NSString string]];
        
            //Check Availabilty
            if (![PKPassLibrary isPassLibraryAvailable]) {
                [RequestTimeOutView showWithMessage:@"PassKit not available" forTime:2.0];
                return;
            }
            
            [self openPassWithName:eventURLForStore];
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

-(void)openPassWithName:(NSString*)eventURL

{
   //3
    NSData *passData = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventURL]];
    
    NSLog(@"%@",passData);
    
    //4
    NSError* error = nil;
    PKPass *newPass = [[PKPass alloc] initWithData:passData
                       
                                             error:&error];
    
    //5
    if (error!=nil) {
        [RequestTimeOutView showWithMessage:[error
                                             
                                             localizedDescription] forTime:2.0];
        
        return;
        
    }
    //6
    PKAddPassesViewController *addController =
    
    [[PKAddPassesViewController alloc] initWithPass:newPass];
    
    addController.delegate = self;
    
    [self presentViewController:addController
     
                       animated:YES completion:nil];
}

#pragma mark - Pass controller delegate

-(void)addPassesViewControllerDidFinish: (PKAddPassesViewController*) controller
{
    //pass added
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
