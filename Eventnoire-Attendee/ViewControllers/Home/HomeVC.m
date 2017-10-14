//
//  HomeVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "HomeVC.h"
#import "Macro.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *tabBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, windowWidth, 50)];
    tabBackground.image = [UIImage imageNamed:@"tabbarBG"];
    tabBackground.contentMode = UIViewContentModeScaleAspectFill;
    [self.tabBar insertSubview:tabBackground atIndex:0];
    //  [self.tabBar setTintColor:[UIColor whiteColor]];
    
    //selected tint color
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    //text tint color
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }
                                             forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }
                                             forState:UIControlStateSelected];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
