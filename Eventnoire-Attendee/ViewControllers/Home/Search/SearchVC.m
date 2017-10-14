//
//  SearchVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "SearchTableViewCell.h"
#import "EventnoireTextField.h"
#import "PersonaliseModal.h"
#import "CategoryVC.h"
#import "SearchVC.h"
#import "ServiceHelper.h"
#import "Macro.h"
#import "LocationVC.h"
#import "AppDelegate.h"

static NSString *cellIdentifier = @"SearchTableViewCell";

@interface SearchVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,navigateAddressProtocol>{
    
    NSString *selectedEventId;
    NSString *selectedEvent;
    NSString *selectedLatitude;
    NSString *selectedLongitude;
}

@property (weak, nonatomic) IBOutlet EventnoireTextField *seracheventTextField;
@property (weak, nonatomic) IBOutlet EventnoireTextField *currentLocationTextField;

@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@property (strong, nonatomic) NSMutableArray *categoryArray;
@property (strong, nonatomic) NSMutableArray *categoryNameArray;
@property (strong, nonatomic) NSMutableArray *tempArray;

@end

@implementation SearchVC

#pragma mark - UIViewController Life cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper method

- (void) initialSetup{
    //dynamic row height
    self.searchTableView.estimatedRowHeight = 400;
    self.seracheventTextField.enablesReturnKeyAutomatically = YES;

    selectedEventId = @"";
    selectedEvent = @"";

    //Initialise array
    self.categoryArray = [[NSMutableArray alloc]init];
    self.categoryNameArray = [[NSMutableArray alloc]init];
    
    //set placeholder text
    [self.seracheventTextField placeHolderTextWithColor:@"Search Event" Color:[UIColor darkGrayColor]];
    [self.currentLocationTextField placeHolderTextWithColor:@"Search Location" Color:[UIColor darkGrayColor]];
    
    [self requestForGettingInterest];

}

-(void)apiCallForInterests:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
           NSArray *interestArray = [result objectForKeyNotNull:pCategories expectedObj:[NSArray array]];
            
            for (int count = 0; count< [interestArray count]; count++) {
                 [self.categoryArray addObject:[PersonaliseModal parseInterestList:[interestArray objectAtIndex:count]]];
                PersonaliseModal *objModel = [self.categoryArray objectAtIndex:count];
                [self.categoryNameArray addObject:objModel.interestName];
            }
            self.tempArray = [NSMutableArray arrayWithArray:self.categoryNameArray];
            [self.searchTableView reloadData];
            
            
            
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


#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoryNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.categoryNameLabel.text = [self.categoryNameArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonaliseModal *objModel = [self.categoryArray objectAtIndex:indexPath.row];
    selectedEventId = objModel.interestID;
    selectedEvent = @"";
    self.seracheventTextField.text = [self.categoryNameArray objectAtIndex:indexPath.row];
	
    CategoryVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryVC"];
  	eventVC.searchedEvent = selectedEvent;
  	eventVC.searchedEventId = selectedEventId;
	  eventVC.eventLatitude = ([self.currentLocationTextField.text length]) ? selectedLatitude : [NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude];
  	eventVC.eventLongitude = ([self.currentLocationTextField.text length]) ? selectedLongitude : [NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude];
	  [self.navigationController pushViewController:eventVC animated:YES];
	
}

#pragma mark - UITextField Delegate

#pragma mark - UITextField Delegate Method
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString* str = ([string isEqualToString:@""])? [textField.text substringToIndex:textField.text.length - 1] :[NSString stringWithFormat:@"%@%@", textField.text, string];
    [self.categoryNameArray removeAllObjects];
    if (range.location != 0 || string.length != 0 ){
        [self.tempArray enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger index, BOOL *stop){
            
            if ([obj rangeOfString:str options:NSCaseInsensitiveSearch].length != 0) {
                [self.categoryNameArray addObject:obj];
            }
        }];
    }else{
        [self.categoryNameArray addObjectsFromArray:self.tempArray];
    }
    [self.searchTableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	  selectedEventId = @"";
	 	[self displayAllEvent];
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - Service Implemention

-(void)requestForGettingInterest {
    
    NSMutableDictionary *getInterestRequest = [NSMutableDictionary new];
    
    [self apiCallForInterests:getInterestRequest andServiceName:getInterestListApi];
}

- (IBAction)searchLocationAction:(id)sender {
    [self.view endEditing:YES];
    [self.view endEditing:YES];
    LocationVC *locationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationVC"];
    locationVC.delegate = self;
    [self.navigationController presentViewController:locationVC animated:YES completion:nil];

}

#pragma mark - Location Screen Delegate Method

-(void)navigateToControllerAddress : (GMSPlace *)addressDetail {
    
    self.currentLocationTextField.text = addressDetail.formattedAddress;
    selectedLatitude = [NSString stringWithFormat:@"%f",addressDetail.coordinate.latitude];
    selectedLongitude = [NSString stringWithFormat:@"%f",addressDetail.coordinate.longitude];
    
    [self displayAllEvent];

    
   

}

-(void)displayAllEvent{
    if ([self.seracheventTextField.text length]) {
        for (int count = 0; count < [self.categoryArray count]; count++) {
            PersonaliseModal *objModel = [self.categoryArray objectAtIndex:count];
            if ([objModel.interestName isEqualToString:self.seracheventTextField.text]) {
                selectedEventId = objModel.interestID;
                selectedEvent = @"";
                break;
            }
        }
        
        if (![selectedEventId length]) {
            selectedEvent = self.seracheventTextField.text;
            selectedEventId = @"";
        }
    }
    
    CategoryVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryVC"];
    eventVC.searchedEvent = selectedEvent;
    eventVC.searchedEventId = selectedEventId;
    eventVC.eventLatitude = ([self.currentLocationTextField.text length]) ? selectedLatitude : [NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.latitude];
    eventVC.eventLongitude = ([self.currentLocationTextField.text length]) ? selectedLongitude : [NSString stringWithFormat:@"%f",[APPDELEGATE location].coordinate.longitude];
    [self.navigationController pushViewController:eventVC animated:YES];
}

@end
