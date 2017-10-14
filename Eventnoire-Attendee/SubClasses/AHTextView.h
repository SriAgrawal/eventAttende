//
//  AHTextView.h
//  AHTO
//
//  Created by Raj Kumar Sharma on 17/06/15.
//  Copyright (c) 2015 mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface AHTextView : UITextView {
    UILabel *_placeholderLabel;
}
@property (strong, nonatomic) NSString      *placeholderText;
@property (strong, nonatomic) UIColor       *placeholderColor;

@property (strong, nonatomic) NSIndexPath   *indexPath; // use if cell for getting easily the cell & txtfield

@property (assign, nonatomic) BOOL          active;

@end
