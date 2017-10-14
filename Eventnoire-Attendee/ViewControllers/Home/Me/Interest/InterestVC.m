//
//  InterestVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "PersonalizeCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "PersonaliseModal.h"
#import "ServiceHelper.h"
#import "AppDelegate.h"
#import "InterestVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"PersonalizeCollectionViewCell";

@interface InterestVC () {
    NSMutableArray *selectedInterestID;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *interestDetailArray;

@end

@implementation InterestVC

#pragma mark - UIViewController life cycle & memory management

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
    
   // [self requestForGettingInterest];
}

#pragma mark - Helper Method

- (void) initialSetup {
    //Initialise array
    //Alloc main array
    self.interestDetailArray = [NSMutableArray array];
    
    [self requestForGettingInterest];
}

#pragma mark - UICollectionView Delegate & Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.interestDetailArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PersonalizeCollectionViewCell *cell = (PersonalizeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PersonaliseModal *interestDetail = [self.interestDetailArray objectAtIndex:indexPath.row];
    
    [cell.personalizeLabel setText:interestDetail.interestName];
    [cell.personalizeImageView sd_setImageWithURL:[NSURL URLWithString:interestDetail.interestImageURL]];
    [cell.personalizeImageView setBackgroundColor:(interestDetail.isSelected)?[UIColor whiteColor]:[UIColor clearColor]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonaliseModal *interestDetail = [self.interestDetailArray objectAtIndex:indexPath.row];
    interestDetail.isSelected = !interestDetail.isSelected;
    
    selectedInterestID = [NSMutableArray array];
    
    for (PersonaliseModal *interestModal  in self.interestDetailArray) {
        
        if (interestModal.isSelected) {
            [selectedInterestID addObject:interestModal.interestID];
        }
    }
    
    [self requestForSendSelectedInterest:[selectedInterestID copy]];
    
//    PersonaliseModal *interestDetail = [self.interestDetailArray objectAtIndex:indexPath.row];
//    interestDetail.isSelected = !interestDetail.isSelected;
//    
//    [self.collectionView reloadData];
}


#pragma mark - Service Implemention

-(void)requestForGettingInterest {
    
    NSMutableDictionary *getInterestRequest = [NSMutableDictionary new];
    
    [self apiCallForInterests:getInterestRequest andServiceName:getInterestListApi];
}

-(void)requestForSendSelectedInterest:(NSArray *)interestIDArray {
    
    NSMutableDictionary *sendSelectedInterestRequest = [NSMutableDictionary new];
    [sendSelectedInterestRequest setValue:interestIDArray forKey:pInterestData];
    
    [self apiCallForInterests:sendSelectedInterestRequest andServiceName:sendSelectedInterestsApi];
}


-(void)apiCallForInterests:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            if ([serviceName isEqualToString:getInterestListApi]) {
                NSArray *interestArray = [result objectForKeyNotNull:pCategories expectedObj:[NSArray array]];
                
                for (NSDictionary *interestDict in interestArray)
                    [self.interestDetailArray addObject:[PersonaliseModal parseInterestList:interestDict]];
                
                [self.collectionView reloadData];
                
            }else {
//                NSString *successMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
//                [RequestTimeOutView showWithMessage:successMessage forTime:2.0];
                
                [self.collectionView reloadData];
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

@end
