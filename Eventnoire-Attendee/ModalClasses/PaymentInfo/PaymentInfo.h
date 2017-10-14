//
//  PaymentInfo.h
//  Eventnoire-Attendee
//
//  Created by Abhishek Agarwal on 17/05/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentInfo : NSObject

@property (strong, nonatomic) NSArray *bookingIDs;
@property (strong, nonatomic) NSString *totalAmount;
@property (strong, nonatomic) NSString *totalTickets;
@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSString *eventID;

@property (strong, nonatomic) NSString *brainTicketNonce;
@property (strong, nonatomic) NSString *transactionID;
@property (strong, nonatomic) NSString *clientToken;

@end
