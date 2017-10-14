//
//  PersonalizeVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 28/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "PersonalizeCollectionViewCell.h"
#import "NSDictionary+NullChecker.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "PersonaliseModal.h"
#import "AppDelegate.h"
#import "ServiceHelper.h"
#import "PersonalizeVC.h"
#import "AlertView.h"
#import "HomeVC.h"
#import "Macro.h"

static NSString *cellIdentifier = @"PersonalizeCollectionViewCell";

@interface PersonalizeVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *selectedInterestID;
}

@property (weak, nonatomic) IBOutlet UICollectionView *persinalizeCollectionView;

@property (strong, nonatomic) NSMutableArray *interestDetailArray;

@end

@implementation PersonalizeVC

#pragma mark - View Controller Life Cycle & Memory Management

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

- (void) initialSetup {

    //Alloc main array
    self.interestDetailArray = [NSMutableArray array];
    
    [self requestForGettingInterest];
}

#pragma mark - UICollectionView Delegate & Datasoutce

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
    
    [self.persinalizeCollectionView reloadData];
}

#pragma mark - UIButton Action Methods

- (IBAction)nextButtonAction:(id)sender {
    selectedInterestID = [NSMutableArray array];
    
    for (PersonaliseModal *interestModal  in self.interestDetailArray) {
        
        if (interestModal.isSelected) {
            [selectedInterestID addObject:interestModal.interestID];
        }
    }
    
    if ([selectedInterestID count] > 2) {
        [self requestForSendSelectedInterest:[selectedInterestID copy]];
    }else
        [RequestTimeOutView showWithMessage:@"Please select more than two categories for getting best result further." forTime:2];
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
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode

            if ([serviceName isEqualToString:getInterestListApi]) {
                NSArray *interestArray = [result objectForKeyNotNull:pCategories expectedObj:[NSArray array]];
                
                for (NSDictionary *interestDict in interestArray)
                    [self.interestDetailArray addObject:[PersonaliseModal parseInterestList:interestDict]];
                
                [self.persinalizeCollectionView reloadData];
                
            }else {
                NSString *successMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
                [RequestTimeOutView showWithMessage:successMessage forTime:2.0];
                
                NSMutableDictionary *userDict = [[NSUSERDEFAULT valueForKey:pUserDetail] mutableCopy];
                [NSUSERDEFAULT removeObjectForKey:pUserDetail];

                [userDict setValue:@"1" forKey:pInterestData];
                
                [NSUSERDEFAULT setValue:userDict forKey:pUserDetail];
                
                [APPDELEGATE startWithLanding];
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
