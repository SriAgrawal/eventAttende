//
//  StaticDataContentVC.h
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 04/04/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum content
{
    About_Us = 2,
    Contact_Us,
    Terms_and_Conditions,
    Privacy_Policy,
    Talk_To_Us
    
} ContentType;


@interface StaticDataContentVC : UIViewController

@property (nonatomic) ContentType contentType;

@end
