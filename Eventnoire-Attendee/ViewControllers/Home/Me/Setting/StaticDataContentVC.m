//
//  StaticDataContentVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 04/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "StaticDataContentVC.h"
#import "TicketInformationVC.h"
#import "ServiceHelper.h"
#import "RequestTimeOutView.h"
#import "NSDictionary+NullChecker.h"
#import "Macro.h"


@interface StaticDataContentVC ()
@property (weak, nonatomic) IBOutlet UIWebView          *webView;
@property (weak, nonatomic) IBOutlet UILabel            *navigationTittleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation StaticDataContentVC

#pragma mark - UIViewController Life Cycle & Memory management

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
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    switch (self.contentType) {
            
        case About_Us: {
            self.navigationTittleLabel.text = @"About Us";
            [self gettingStaticContentRequest:@"about_us"];
        }
            break;
            
        case Contact_Us: {
            self.navigationTittleLabel.text = @"Contact Us";
            [self gettingStaticContentRequest:@"contact_us"];
        }
            break;
            
        case Terms_and_Conditions: {
            self.navigationTittleLabel.text = @"Terms & Conditions";
            [self gettingStaticContentRequest:@"terms_conditions"];
        }
            break;
            
        case Privacy_Policy: {
            self.navigationTittleLabel.text=@"Privacy Policy";
            [self gettingStaticContentRequest:@"privacy_policy"];
        }
            break;
            
        case Talk_To_Us: {
            self.navigationTittleLabel.text=@"Talk To Us";
            [self gettingStaticContentRequest:@"talk_to_us"];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Service Implemention

-(void)gettingStaticContentRequest:(NSString *)type {
    
    NSMutableDictionary *contentRequest = [NSMutableDictionary new];
    [contentRequest setValue:type forKey:pContentType];
    
    [self apiCallForApplicationInformation:contentRequest andServiceName:infoPagesApi];
}

-(void)apiCallForApplicationInformation:(NSMutableDictionary *)requestDictonary andServiceName:(NSString *)serviceName {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:requestDictonary apiName:serviceName andApiType:POST andIsRequiredHud:NO WithComptionBlock:^(NSDictionary *result, NSError *error) {
        
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
        
        if (!error) {
            //Success and 200 responseCode
            
            NSString *content = [result objectForKeyNotNull:pContent expectedObj:[NSString string]];
            [self.webView loadHTMLString:[content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
            
        }else if (error.code == 100) {
            //Success but other than 200 responseCode
            NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }else {
            //Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
        }
    }];
}

#pragma mark - UIButton Action

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
