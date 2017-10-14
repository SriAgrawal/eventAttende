//
//  CountryDetailViewController.m
//  VendorApp
//
//  Created by Abhishek Agarwal on 07/04/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import "CountryDetailViewController.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "CountryCell.h"
#import "Macro.h"

static NSString *countryCellIdentifier = @"CountryCell";

@interface CountryDetailViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *countryTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarButton;

@property (strong, nonatomic) NSArray *countryDetailArray;
@property (strong, nonatomic) NSArray *filterArray;

@end

@implementation CountryDetailViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    
    self.title  = @"Country List";
    self.navigationItem.leftBarButtonItem=  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"saveIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countriesInformation" ofType:@"json"]];
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    self.countryDetailArray  = [NSArray array];
    self.filterArray = [NSArray array];
    self.searchBarButton.delegate = self;
    
    if (localError != nil) {
        [RequestTimeOutView showWithMessage:[NSString stringWithFormat:@"%@",[localError userInfo]] forTime:3.0];
    }else {
        
        NSMutableArray *country = [NSMutableArray array];
        
        for (NSDictionary *countryDetailDictionary in parsedObject) {
            [country addObject:[CountryDetailModal fetchAllCountryDetail:countryDetailDictionary]];
        }
        
        self.countryDetailArray = [country mutableCopy];
        self.filterArray = self.countryDetailArray;
     }
    
//    self.countryTableView.rowHeight = UITableViewAutomaticDimension;
//    self.countryTableView.estimatedRowHeight = 40.0;
    
    //Register TableView Cell
    [self.countryTableView registerNib:[UINib nibWithNibName:countryCellIdentifier bundle:nil] forCellReuseIdentifier:countryCellIdentifier];
}

#pragma mark - Button Action

-(void)backBtnAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)saveAction:(id)sender {
    [self.view endEditing:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isSelected == YES"];
    NSArray *selectedArray = [self.filterArray filteredArrayUsingPredicate:predicate];

    if ([selectedArray count])
        [self.delegate selectedCountryDetail:[selectedArray firstObject]];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark UITableView overrids

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.filterArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CountryCell *cell = [tableView dequeueReusableCellWithIdentifier:countryCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    
     CountryDetailModal *countryModal = [self.filterArray objectAtIndex:indexPath.row];
    
    if (countryModal.isSelected)
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType =  UITableViewCellAccessoryNone;

    [cell.countryName setText:countryModal.countryName];
    [cell.flagImage sd_setImageWithURL:[NSURL URLWithString:countryModal.countryFlagLink]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isSelected == YES"];
    NSArray *selectedArray = [self.filterArray filteredArrayUsingPredicate:predicate];
   CountryDetailModal *countryModal = [selectedArray firstObject];
    countryModal.isSelected = NO;
    
    CountryDetailModal *selectedCountryModal = [self.filterArray objectAtIndex:indexPath.row];
    selectedCountryModal.isSelected = YES;
    
    [self.countryTableView reloadData];
}

#pragma mark - Button Actions

- (IBAction)commonButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    
    if([TRIM_SPACE(text) length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.countryName contains[cd] %@",self.searchBarButton.text];
        self.filterArray = [self.countryDetailArray filteredArrayUsingPredicate:predicate];
    }
    
    [self.countryTableView reloadData];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation CountryDetailModal

+(CountryDetailModal *)fetchAllCountryDetail:(NSDictionary *)countryDictionary {
    
    CountryDetailModal *countryDetail = [CountryDetailModal new];
    
    countryDetail.countryName = [countryDictionary objectForKeyNotNull:@"country_name" expectedObj:@""];
    countryDetail.countryPhoneCode = [countryDictionary objectForKeyNotNull:@"dial_code" expectedObj:@""];
    countryDetail.countryFlagLink = [countryDictionary objectForKeyNotNull:@"flag_url" expectedObj:@""];
    countryDetail.isSelected = NO;
    
    return countryDetail;
}


//- (IBAction)saveAction:(id)sender {
//    [self.view endEditing:YES];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isSelected == YES"];
//    NSArray *selectedArray = [self.filterArray filteredArrayUsingPredicate:predicate];
//    
//    if ([selectedArray count])
//        [self.delegate selectedCountryDetail:[selectedArray firstObject]];
//    
//    [self dismissViewControllerAnimated:NO completion:nil];
//
//}

@end
