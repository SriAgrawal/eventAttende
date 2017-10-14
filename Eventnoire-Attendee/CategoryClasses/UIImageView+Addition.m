//
//  UIImageView+Addition.m
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "UIImageView+Addition.h"

@implementation UIImageView (Addition)

@dynamic iconColor;

- (void)setIconColor:(UIColor *)color {
    [self color:color];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 10);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)color:(UIColor *)color {
    
    if(!color)
        return;
    
    UIImage *image = self.image;
    
    CGSize s = image.size;
    s.height *= image.scale;
    s.width *= image.scale;
    
    UIGraphicsBeginImageContext(s);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = s;
    
    // Retrieve source image and begin image context
    CGSize itemImageSize = s;
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContext(contextRect.size);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    //  CGContextRotateCTM(c, M_1_PI);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
    // Fill and end the transparency layer
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
    const CGFloat* colors = CGColorGetComponents(color.CGColor);
    
    if (model == kCGColorSpaceModelMonochrome) {
        CGContextSetRGBFillColor(c, colors[0], colors[0], colors[0], colors[1]);
    } else {
        CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], colors[3]);
    }
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIImage* img2 = [UIImage imageWithCGImage:img.CGImage scale:image.scale orientation:image.imageOrientation];
    UIGraphicsEndImageContext();
    
    [self setImage:img2];
}

@end
