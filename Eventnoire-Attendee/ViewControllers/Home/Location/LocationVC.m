//
//  LocationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 30/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "LocationTableViewCell.h"
#import "EventnoireTextField.h"
#import "LocationVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"LocationTableViewCell";

@interface LocationVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (weak, nonatomic) IBOutlet EventnoireTextField *searchTextField;
@property (strong, nonatomic) NSMutableArray *locationArray;

@end

@implementation LocationVC

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
    self.locationTableView.estimatedRowHeight = 400;
    
    //Initialise Array
    self.locationArray = [NSMutableArray array];
    
    self.searchTextField.tintColor = [UIColor blackColor];
}

#pragma mark - UITextfeild Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self placeAutocompleteWithText:TRIM_SPACE(str)];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self placeAutocompleteWithText:self.searchTextField.text];
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.locationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = (LocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    GMSAutocompletePrediction* result = [self.locationArray objectAtIndex:indexPath.row];
    cell.locationLabel.text = result.attributedFullText.string;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];

    GMSAutocompletePrediction* result = [self.locationArray objectAtIndex:indexPath.row];

    [self getLatitudeAndLongitudeFromAddress:result];
}

-(void)getLatitudeAndLongitudeFromAddress:(GMSAutocompletePrediction *)selectedAddress {
    
    [[GMSPlacesClient sharedClient] lookUpPlaceID:selectedAddress.placeID callback:^(GMSPlace *place, NSError *error) {
        
        if (error != nil) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate navigateToControllerAddress:nil];
            }];
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place placeID %@", place.placeID);
            NSLog(@"Place attributions %@", place.attributions);
            NSLog(@"Place attributions %f", place.coordinate.latitude);
            NSLog(@"Place attributions %f", place.coordinate.longitude);

            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate navigateToControllerAddress:place];
            }];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate navigateToControllerAddress:nil];
            }];
        }
    }];
}

#pragma mark - Google Place API

- (void)placeAutocompleteWithText:(NSString *)locationStr {
    
    if ([locationStr length]) {
        
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterRegion;
        GMSPlacesClient *placesClient = [GMSPlacesClient sharedClient];
        
        [placesClient autocompleteQuery:locationStr
                                 bounds:nil
                                 filter:filter
                               callback:^(NSArray*results, NSError *error) {
                                   
                                   if (error) {
                                       [self.locationArray removeAllObjects];
                                       [self.locationTableView reloadData];
                                       
                                       return;
                                   }else {
                                       [self.locationArray removeAllObjects];
                                       if ([self.searchTextField.text length]) {
                                           for (GMSAutocompletePrediction* result in results) {
                                               [self.locationArray addObject:result];
                                           }
                                       }
                                       [self.locationTableView reloadData];
                                   }
                               }];
    }else{
        [self.locationArray removeAllObjects];
        [self.locationTableView reloadData];
    }
}

#pragma mark - UIButton Action Methods

- (IBAction)crossButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
