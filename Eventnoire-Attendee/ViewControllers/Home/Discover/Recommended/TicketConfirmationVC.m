//
//  TicketConfirmationVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "TicketConfirmationVC.h"
#import "AppDelegate.h"
#import "HomeVC.h"
#import "Macro.h"

@interface TicketConfirmationVC ()

@end

@implementation TicketConfirmationVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action Methods

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)discoverEventsButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    [APPDELEGATE startWithLanding];

}

@end
