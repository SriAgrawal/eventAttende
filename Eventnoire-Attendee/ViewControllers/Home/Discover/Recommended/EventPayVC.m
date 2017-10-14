//  EventPayVC.m
//  Eventnoire-Attendee
//  Created by Aiman Akhtar on 01/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "NSDictionary+NullChecker.h"
#import "TicketConfirmationVC.h"
#import "RequestTimeOutView.h"
#import "BraintreeDropIn.h"
#import "BraintreeCore.h"
#import "BraintreeCard.h"
#import "ServiceHelper.h"
#import <EventKit/EventKit.h>
#import "AllTicketDisplayVC.h"
#import "PaymentInfo.h"
#import "EventPayVC.h"
#import "BraintreeUI.h"
#import "EventModal.h"
#import "HomeVC.h"
#import "Macro.h"
#import <Stripe/Stripe.h>

@interface EventPayVC ()<BTCardFormViewControllerDelegate,BTDropInViewControllerDelegate,STPAddCardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventScheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@property (weak, nonatomic) IBOutlet UIButton *viewButton;

@property (nonatomic, strong) BTAPIClient *braintreeClient;

@property (nonatomic, strong) PaymentInfo *paymentInfo;

@end

@implementation EventPayVC

#pragma mark - UIViewController Life Cycle & memory Management

- (void)viewDidLoad {
	NSLog(@"%@",self.eventDetailModal);
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
    
		// [self.viewButton setHidden:YES];
    
    //set label text
    self.eventNameLabel.text = self.eventDetailModal.eventName;
    
    [self.eventScheduleLabel setText:[NSString stringWithFormat:@"%@, %@ to %@, %@ at %@",self.eventDetailModal.eventStartMonth,self.eventDetailModal.eventStartDateString,self.eventDetailModal.eventEndMonth,self.eventDetailModal.eventEndDateString,self.eventDetailModal.eventStartTime]];
    
    NSInteger totalTicket = 0;
    float totalAmount = 0;

    for (TicketModal *ticketInfo in self.eventDetailModal.ticketInfoArray) {

        totalTicket = totalTicket + [ticketInfo.bookSeats integerValue];
        totalAmount = totalAmount + ([ticketInfo.bookSeats integerValue]*[ticketInfo.ticketAmount floatValue]);
    }
    
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld item",(long)totalTicket];
    
    //set attributed text
    NSAttributedString *atrributedString =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Total: %@%0.0f",self.eventDetailModal.eventTicketCurrency,totalAmount]];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: atrributedString];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:AppColor
                 range:NSMakeRange(7,[atrributedString length]-7)];
    
    [self.totalAmountLabel setAttributedText: text];
    
    //PaymentInfo
    self.paymentInfo = [PaymentInfo new];
    
    self.paymentInfo.totalTickets = [NSString stringWithFormat:@"%ld",(long)totalTicket];
    self.paymentInfo.totalAmount = [NSString stringWithFormat:@"%ld",(long)totalAmount];
    self.paymentInfo.eventName = self.eventDetailModal.eventName;
    self.paymentInfo.eventID = self.eventDetailModal.eventID;

}

#pragma mark - UIButton Action Methods

- (IBAction)payNowButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self bookApiRequest:NO];
}

- (IBAction)backButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)viewButtonAction:(id)sender {
	
	AllTicketDisplayVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AllTicketDisplayVC"];
	ticketVC.eventModelData = self.eventDetailModal;
	ticketVC.isFromPayment = true;
	[self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:ticketVC] animated:YES completion:nil];
}

#pragma mark - Stripe Implementation
-(void)payViaStripe{
    
    STPPaymentConfiguration *config = [STPPaymentConfiguration sharedConfiguration];
    
    STPAddCardViewController *controller = [[STPAddCardViewController alloc] initWithConfiguration:config theme:[STPTheme defaultTheme]];
    controller.delegate = self;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:controller animated:YES];
//    [self presentViewController:controller animated:YES completion:nil];
    
}

#pragma mark - STPAddCardViewController Delegate


/**
 *  Called when the user cancels adding a card. You should dismiss (or pop) the view controller at this point.
 *
 *  @param addCardViewController the view controller that has been cancelled
 */
- (void)addCardViewControllerDidCancel:(STPAddCardViewController *)addCardViewController{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];

}

/**
 *  This is called when the user successfully adds a card and tokenizes it with Stripe. You should send the token to your backend to store it on a customer, and then call the provided `completion` block when that call is finished. If an error occurred while talking to your backend, call `completion(error)`, otherwise, dismiss (or pop) the view controller.
 *
 *  @param addCardViewController the view controller that successfully created a token
 *  @param token                 the Stripe token that was created. @see STPToken
 *  @param completion            call this callback when you're done sending the token to your backend
 */
- (void)addCardViewController:(STPAddCardViewController *)addCardViewController
               didCreateToken:(STPToken *)token
                   completion:(STPErrorBlock)completion{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
    NSMutableDictionary *sendTokenDictionary = [NSMutableDictionary new];
    
   // [sendTokenDictionary setValue:@"payment" forKey:pAction];
    [sendTokenDictionary setValue:self.paymentInfo.bookingIDs forKey:pBookingID];
    [sendTokenDictionary setValue:self.paymentInfo.eventName forKey:pEventType];
    [sendTokenDictionary setValue:token.tokenId forKey:pStripe_token];
    [sendTokenDictionary setValue:self.paymentInfo.totalAmount forKey:pTotalAmount];
    [sendTokenDictionary setValue:self.paymentInfo.eventID forKey:pEventID];
    
    [self apiCallForGettingTokenAndSendItAgain:sendTokenDictionary andServiceName:make_paymentAPi andIsCallingAfterNonceGenerate:YES];

    
}
#pragma mark - Brain Tree Implemention

-(void)openBrainTree : (NSString *)cardNumber : (NSString *)month : (NSString *)year {
    
    _braintreeClient = [[BTAPIClient alloc] initWithAuthorization:self.paymentInfo.clientToken];
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc]
                                                    initWithAPIClient:self.braintreeClient];
    dropInViewController.delegate = self;
    [dropInViewController setCardNumber:cardNumber];
    [dropInViewController setCardExpirationMonth:[month integerValue] year:[year integerValue]];
    
    // This is where you might want to customize your view controller (see below)
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally-presented navigation controller:
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancelPayment)];
    dropInViewController.navigationItem.leftBarButtonItem = item;
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Brain Tree Delegate
/*
- (void)dropInViewController:(BTDropInViewController *)viewController
  didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
    // Send payment method nonce to your server for processing
    [self dismissViewControllerAnimated:YES completion:^{
        if ([paymentMethodNonce.nonce length]) {
            self.paymentInfo.brainTicketNonce = paymentMethodNonce.nonce;
            
            NSMutableDictionary *sendTokenDictionary = [NSMutableDictionary new];
            
            [sendTokenDictionary setValue:@"payment" forKey:pAction];
            [sendTokenDictionary setValue:self.paymentInfo.bookingIDs forKey:pBookingID];
            [sendTokenDictionary setValue:self.paymentInfo.eventName forKey:pEventType];
            [sendTokenDictionary setValue:self.paymentInfo.brainTicketNonce forKey:pTransactionNonce];
            [sendTokenDictionary setValue:self.paymentInfo.totalAmount forKey:pTotalAmount];
            [sendTokenDictionary setValue:self.paymentInfo.eventID forKey:pEventID];

            [self apiCallForGettingTokenAndSendItAgain:sendTokenDictionary andServiceName:makePaymentApi andIsCallingAfterNonceGenerate:YES];
        }else {
            [RequestTimeOutView showWithMessage:@"Please try again.Something went wrong." forTime:2.0];
        }
    }];
}

-(void)cardTokenizationCompleted:(BTPaymentMethodNonce *)tokenizedCard error:(NSError *)error sender:(BTCardFormViewController *)sender {
    
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

#pragma mark - Booking Info

-(void) bookApiRequest:(BOOL)isCallLastTime {
    [self.view endEditing:YES];
    
    NSMutableDictionary *bookDictionary = [NSMutableDictionary new];
    
    [bookDictionary setValue:self.eventDetailModal.eventID forKey:pEventID];
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pFirstName] forKey:pFirstName];
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pLastName] forKey:pLastName];
    [bookDictionary setValue:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pEmailID] forKey:pEmailID];

    [bookDictionary setValue:self.eventDetailModal.eventTicketType forKey:pTicketType];
    [bookDictionary setValue:[self.eventDetailModal generateTicketInfo] forKey:pTicketInfo];

    
    if (isCallLastTime) {
        [bookDictionary setValue:self.paymentInfo.transactionID forKey:pTransactionID];
        [bookDictionary setValue:self.paymentInfo.bookingIDs forKey:pBookingID];
    }
    
    [self apiCallForBookEvent:bookDictionary andServiceName:bookEventApi andCallLastTime:isCallLastTime];
}

#pragma mark - Service Implemention

-(void)apiCallForBookEvent:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName andCallLastTime:(BOOL)isCallLastTime {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            
            if (!isCallLastTime) {
                self.paymentInfo.bookingIDs = [result objectForKeyNotNull:pBookingID expectedObj:[NSArray array]];
                self.paymentInfo.totalAmount = [NSString stringWithFormat:@"%.f",[[result objectForKeyNotNull:pTotalAmount expectedObj:[NSString string]] floatValue]];
                
             /*   NSMutableDictionary *getTokenDictionary = [NSMutableDictionary new];
                
                [getTokenDictionary setValue:@"clientToken" forKey:pAction];
                [getTokenDictionary setValue:self.paymentInfo.bookingIDs forKey:pBookingID];
                
                [self apiCallForGettingTokenAndSendItAgain:getTokenDictionary andServiceName:makePaymentApi andIsCallingAfterNonceGenerate:NO];*/
                
                [self payViaStripe];

            }else {
               /* TicketConfirmationVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketConfirmationVC"];
                [self.navigationController pushViewController:ticketVC animated:YES];*/
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

-(void)apiCallForGettingTokenAndSendItAgain:(NSMutableDictionary *)request andServiceName:(NSString *)serviceName andIsCallingAfterNonceGenerate:(BOOL)isNonceGenerated {
    
    [[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:serviceName andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
        
        if (!error) {
            //Success and 200 responseCode
            if (!isNonceGenerated) {
                self.paymentInfo.clientToken = [result objectForKeyNotNull:pClientToken expectedObj:[NSString string]];
               // [self openBrainTree:@"" :@"" :@""];
            }else {
                self.paymentInfo.transactionID = [result objectForKeyNotNull:pTransactionID expectedObj:[NSString string]];
                TicketConfirmationVC *ticketVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TicketConfirmationVC"];
                [self.navigationController pushViewController:ticketVC animated:YES];

               // [self bookApiRequest:YES];
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
