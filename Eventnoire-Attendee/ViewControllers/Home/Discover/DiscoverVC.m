//
//  DiscoverVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//
#import <GooglePlaces/GooglePlaces.h>
#import "RecommendedVC.h"
#import "NotificationVC.h"
#import "DiscoverVC.h"
#import "LocationVC.h"
#import "FeatureVC.h"
#import "CarbonKit.h"
#import "FriendVC.h"
#import "NSDictionary+NullChecker.h"
#import "RequestTimeOutView.h"
#import "ServiceHelper.h"
#import "Macro.h"
#import "AppDelegate.h"

@interface DiscoverVC ()<CarbonTabSwipeNavigationDelegate,navigateAddressProtocol>

@property (weak, nonatomic) IBOutlet UIView                 *containerView;

@property (strong, nonatomic) NSArray                       *arrayItems;

@property (strong, nonatomic) CarbonTabSwipeNavigation      *pageVC;

@property (weak, nonatomic) IBOutlet UILabel *notificationCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectLocationButton;
@end

@implementation DiscoverVC

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self notificationCountApi];
}

#pragma mark - Helper Method

- (void) initialSetup {
	
	NSDictionary *tempDict = [NSUSERDEFAULT valueForKey:pUserDetail];
	
	if ([[tempDict objectForKeyNotNull:pLogInType expectedObj:@""] isEqualToString:@"facebook"])
		self.arrayItems = @[@"Recommended", @"Popular", @"Friends", @"Featured"];
	else
    self.arrayItems = @[@"Recommended", @"Popular",@"Featured"];
    
    self.pageVC = [[CarbonTabSwipeNavigation alloc] initWithItems:self.arrayItems delegate:self];
    [self.pageVC.view setFrame:self.containerView.bounds];
    [self.containerView addSubview:self.pageVC.view];
    [self addChildViewController:self.pageVC];
    
    // set up page style
    UIColor *color = [UIColor blackColor];
    [self.pageVC setIndicatorColor:[UIColor blackColor]];
    [self.pageVC setTabExtraWidth:0];
    [self.pageVC setTabBarHeight:50];
    [self.pageVC setIndicatorHeight:3];
    
    if (windowWidth == 320) {
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count + 65 forSegmentAtIndex:0];
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:1];
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:2];
			if (self.arrayItems.count > 3)
				[self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count+ 10 forSegmentAtIndex:3];

    }
    else {
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count + 50 forSegmentAtIndex:0];
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:1];
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:2];
			if (self.arrayItems.count > 3)
        [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count + 5 forSegmentAtIndex:3];
    }
   
    [self.pageVC.toolbar setBarStyle:UIBarStyleDefault];
    
    // Custimize segmented control
    [self.pageVC setNormalColor:[UIColor darkGrayColor]
                           font:AppFont(17)];
    [self.pageVC setSelectedColor:color
                             font:AppFont(17)];
	
	self.notificationCountLabel.hidden = YES;
}

#pragma mark - CarbonTabSwipeNavigation Delegate
// required
- (nonnull UIViewController *)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    
    RecommendedVC *recommendedVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecommendedVC"];
    recommendedVC.eventType = index;
	
    
    return recommendedVC;
    
  /*  switch (index) {
        case 0: {
            RecommendedVC *recommendedVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecommendedVC"];
            return recommendedVC;
        }
            
        case 1: {
            RecommendedVC *recommendedVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecommendedVC"];
            recommendedVC.isFromPopular = YES;
            return recommendedVC;
        }
            
        case 2: {
//            FriendVC *friendVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"FriendVC"];
//            return friendVC;
            RecommendedVC *recommendedVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecommendedVC"];
            recommendedVC.isFromFriends = YES;
            return recommendedVC;
        }
            
        case 3: {
//            FeatureVC *featureVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"FeatureVC"];
//            return featureVC;
            RecommendedVC *recommendedVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecommendedVC"];
            recommendedVC.isFromFeatured = YES;
            return recommendedVC;
        }
            
        default:{
            FriendVC *friendVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"FriendVC"];
            return friendVC;
        }
    }*/
}

// optional
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
    
    //self.title = self.arrayItems[index];
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                  didMoveAtIndex:(NSUInteger)index {
    LogInfo(@"Did move at index: %ld", (unsigned long)index);
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
      didFinishTransitionToIndex:(NSUInteger)index {
    LogInfo(@"Did move at index: %ld", (unsigned long)index);
    
}

- (UIBarPosition)barPositionForCarbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation {
    return UIBarPositionTop; // default UIBarPositionTop
}

#pragma mark - UIButton Action Method

- (IBAction)notificationButtonAction:(id)sender {
    [self.view endEditing:YES];
    NotificationVC *notificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationVC"];
    self.notificationCountLabel.text = [NSString stringWithFormat:@"%ld",(long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    
    [self.navigationController pushViewController:notificationVC animated:YES];
}

- (IBAction)selectLocationButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    LocationVC *locationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationVC"];
    locationVC.delegate = self;
    [self.navigationController presentViewController:locationVC animated:YES completion:nil];
}

#pragma mark - Location Screen Delegate Method

-(void)navigateToControllerAddress : (GMSPlace *)addressDetail {
    NSLog(@"%f",addressDetail.coordinate.latitude);
    [self.selectLocationButton setTitle:addressDetail.formattedAddress forState:UIControlStateNormal];
    
    RecommendedVC *recommendedVC =  (RecommendedVC *)[self.pageVC.viewControllers objectForKey:[NSNumber numberWithInteger:self.pageVC.currentTabIndex]];
    
    [recommendedVC recommendedEventRequest:addressDetail andComingFromLocation:YES];
}


#pragma mark - Api Method

-(void)notificationCountApi {
	
	[[ServiceHelper sharedServiceHelper] callApiWithParameter:[NSMutableDictionary dictionary] apiName:setNotificationCountApi andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error){
		
		if (!error) {
				//Success and 200 responseCode
			if ([[result objectForKeyNotNull:setNotificationCountApi expectedObj:@"0"] isEqualToString:@"0"]) {
				self.notificationCountLabel.hidden = YES;
			}else {
				self.notificationCountLabel.hidden = NO;
				self.notificationCountLabel.text = [result objectForKeyNotNull:setNotificationCountApi expectedObj:@"0"];
			}
			
		}else if (error.code == 100) {
				//Success but other than 200 responseCode
			NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
			[RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
		}else {
				//Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];		}
	}];
}



@end
