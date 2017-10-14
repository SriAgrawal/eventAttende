//
//  TicketInformationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 03/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "TicketInformationVC.h"
#import "RegistrationVC.h"
#import "CarbonKit.h"
#import "InfoVC.h"
#import "Macro.h"

@interface TicketInformationVC ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSArray                       *arrayItems;
@property (strong, nonatomic) CarbonTabSwipeNavigation      *pageVC;
@end

@implementation TicketInformationVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void) initialSetup {
    self.arrayItems = @[@"Registration", @"Info"];
    
    self.pageVC = [[CarbonTabSwipeNavigation alloc] initWithItems:self.arrayItems delegate:self];
    [self.pageVC.view setFrame:self.containerView.bounds];
    [self.containerView addSubview:self.pageVC.view];
    [self addChildViewController:self.pageVC];
    
    // set up page style
    UIColor *color = [UIColor blackColor];
    [self.pageVC setIndicatorColor:color];
    [self.pageVC setTabExtraWidth:0];
    [self.pageVC setTabBarHeight:50];
    [self.pageVC setIndicatorHeight:3];
    
    [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:0];
    [self.pageVC.carbonSegmentedControl setWidth:windowWidth/self.arrayItems.count forSegmentAtIndex:1];
    
    [self.pageVC.toolbar setBarStyle:UIBarStyleDefault];
    
    // Custimize segmented control
    [self.pageVC setNormalColor:[UIColor darkGrayColor]
                           font:AppFont(17)];
    [self.pageVC setSelectedColor:color
                             font:AppFont(17)];
}

#pragma mark - CarbonTabSwipeNavigation Delegate
// required
- (nonnull UIViewController *)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: {
            RegistrationVC *registrationVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegistrationVC"];
            registrationVC.eventModelData = self.eventModelData;
            registrationVC.selectedIndex = self.selectedIndex;
            return registrationVC;
        }
            
        case 1: {
            InfoVC *infoVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"InfoVC"];
            infoVC.eventModelData = self.eventModelData;
            infoVC.selectedIndex = self.selectedIndex;
            return infoVC;
        }
            
        default:{
            RegistrationVC *registrationVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegistrationVC"];
            registrationVC.eventModelData = self.eventModelData;
            registrationVC.selectedIndex = self.selectedIndex;
            return registrationVC;
       }
    }
}

// optional
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
    // self.title = self.arrayItems[index];
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

#pragma mark - UIButton Action Methods

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    NSArray* sharedObjects = [NSArray arrayWithObjects:@"sharecontent",nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];

}
@end
