//
//  UIImage+Addition.h
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addition)

- (NSString *)getBase64String;
- (NSString *)getBase64StringWithQuality:(CGFloat)value;
-(NSString *)getBase64ImageString;

@end
