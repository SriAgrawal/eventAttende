//
//  UIImage+Addition.m
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "UIImage+Addition.h"

@implementation UIImage (Addition)

- (NSString *)getBase64String {
    
    NSData *imageData = UIImageJPEGRepresentation(self ,1.0);
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)getBase64StringWithQuality:(CGFloat)value {
    
    NSData *imageData = UIImageJPEGRepresentation(self ,value);
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

-(NSString *)getBase64ImageString {
	
	CGFloat compression = 0.9f;
	CGFloat maxCompression = 0.1f;
	int maxFileSize = 250*1024;
	NSData *imageData = UIImageJPEGRepresentation(self, compression);
	while ([imageData length] > maxFileSize && compression > maxCompression){
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation(self, compression);
	}
	return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}


@end
