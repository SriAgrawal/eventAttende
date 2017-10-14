//
//  PersonaliseModal.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "NSDictionary+NullChecker.h"
#import "PersonaliseModal.h"
#import "Macro.h"

@implementation PersonaliseModal

+(PersonaliseModal *)parseInterestList:(NSDictionary *)interestDetailDict {
    PersonaliseModal *interestModal = [PersonaliseModal new];
    
    interestModal.interestID = [interestDetailDict objectForKeyNotNull:pID expectedObj:[NSString string]];
    interestModal.interestName = [interestDetailDict objectForKeyNotNull:pCategoryName expectedObj:[NSString string]];
    interestModal.interestImageURL = [interestDetailDict objectForKeyNotNull:pImageURL expectedObj:[NSString string]];
    interestModal.isSelected = [[interestDetailDict objectForKeyNotNull:pIsSelected expectedObj:[NSString string]] boolValue];

    return interestModal;
}

@end

@implementation SelectedItemDetail

@end
