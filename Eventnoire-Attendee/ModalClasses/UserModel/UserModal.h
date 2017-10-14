//
//  UserModal.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 24/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModal : NSObject

@property (strong, nonatomic) NSString   *emailString;
@property (strong, nonatomic) NSString   *passwordString;
@property (strong, nonatomic) NSString   *firstNameString;
@property (strong, nonatomic) NSString   *lastNameString;
@property (strong, nonatomic) NSString   *phoneNumberString;
@property (strong, nonatomic) NSString   *confirmPasswordString;
@property (strong, nonatomic) NSString   *errorText;
@property (strong, nonatomic) NSString   *emailMobileString;
@property (strong, nonatomic) NSString   *otpString;

@property (assign, nonatomic) BOOL       isSelected;
@property (nonatomic, assign) NSInteger index;

@end

