//
//  PersonaliseModal.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonaliseModal : NSObject

@property (strong, nonatomic) NSString *interestID;
@property (strong, nonatomic) NSString *interestName;
@property (strong, nonatomic) NSString *interestImageURL;
@property (assign, nonatomic) BOOL      isSelected;

@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSArray *dataArray;

@property (strong, nonatomic) NSMutableArray *selectedItemDetail;

+(PersonaliseModal *)parseInterestList:(NSDictionary *)interestDetailDict;

@end

@interface SelectedItemDetail : NSObject

@property (assign, nonatomic) BOOL      isSelected;
@property (assign, nonatomic) NSString *selectedItemName;

@end
