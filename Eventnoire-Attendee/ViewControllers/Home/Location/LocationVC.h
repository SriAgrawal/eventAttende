//
//  LocationVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 30/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@protocol navigateAddressProtocol<NSObject>

-(void)navigateToControllerAddress : (GMSPlace *)Address;

@end

@interface LocationVC : UIViewController
@property (nonatomic,weak) id <navigateAddressProtocol> delegate;

@end
