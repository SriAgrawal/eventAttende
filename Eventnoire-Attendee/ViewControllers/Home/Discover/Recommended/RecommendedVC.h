//
//  RecommendedVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

typedef enum : NSUInteger {
    Recommended,
    Popular,
    Friend,
    Featured
    
} EventType;

@interface RecommendedVC : UIViewController

@property (nonatomic,assign) BOOL isFromPopular;
@property (nonatomic,assign) BOOL isFromFriends;
@property (nonatomic,assign) BOOL isFromFeatured;

@property (nonatomic) EventType eventType;

-(void)recommendedEventRequest : (GMSPlace *)addressDetail andComingFromLocation:(BOOL)isComingFromLocation;

@end
