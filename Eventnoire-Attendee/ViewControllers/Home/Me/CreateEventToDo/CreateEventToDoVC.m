//
//  CreateEventToDoVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 05/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "CreateEventToDoVC.h"
#import "CreateNewToDoVC.h"
#import "ToDoListVC.h"
#import "CarbonKit.h"
#import "Macro.h"

@interface CreateEventToDoVC ()
@property (weak, nonatomic) IBOutlet UIView *pageController;

@property (strong, nonatomic) NSArray *arrayItems;
@property (strong, nonatomic) CarbonTabSwipeNavigation *pageVC;
@end

@implementation CreateEventToDoVC

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
    self.arrayItems = @[@"To Do List", @"Create New To Do"];
    
    self.pageVC = [[CarbonTabSwipeNavigation alloc] initWithItems:self.arrayItems delegate:self];
    [self.pageVC.view setFrame:self.pageController.bounds];
    [self.pageController addSubview:self.pageVC.view];
    [self addChildViewController:self.pageVC];
    
    // set up page style
    UIColor *color = [UIColor blackColor];
    [self.pageVC setIndicatorColor:[UIColor blackColor]];
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
            ToDoListVC *toDoListVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ToDoListVC"];
            return toDoListVC;
        }
            
        case 1: {
            CreateNewToDoVC *createVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"CreateNewToDoVC"];
            return createVC;
        }
            
        default:{
            CreateNewToDoVC *createVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"CreateNewToDoVC"];
            return createVC;
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


#pragma mark - UIButton Action Method

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
