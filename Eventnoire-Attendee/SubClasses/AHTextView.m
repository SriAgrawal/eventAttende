//
//  AHTextView.m
//  AHTO
//
//  Created by Raj Kumar Sharma on 17/06/15.
//  Copyright (c) 2015 mobiloitte. All rights reserved.
//

#import "AHTextView.h"
#import "Macro.h"

@implementation AHTextView

#pragma mark - init & dealloc
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    //set the placeholder color
   self.placeholderColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0];
    
    [self layoutGUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -

#pragma mark - Notification center
- (void)textChanged:(NSNotification *)notification {
    if (notification.object == self)
        [self layoutGUI];
}
#pragma mark -

#pragma mark - layoutGUI
- (void)layoutGUI {
    _placeholderLabel.alpha = [self.text length] > 0 || [_placeholderText length] == 0 ? 0 : 1;
    self.textContainerInset = UIEdgeInsetsMake(8, 6, 0, 0);
    
}
#pragma mark -

#pragma mark - Setters
- (void)setText:(NSString *)text {
    [super setText:text];
    [self layoutGUI];
}

- (void)setPlaceholderText:(NSString*)placeholderText {
    _placeholderText = placeholderText;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor*)color { //Set placeholder color

    _placeholderColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0];
    self.tintColor = AppColor;
//    _placeholderColor = color;
    [self setNeedsDisplay];
}
#pragma mark -

#pragma mark - Public methods

- (void)setActive:(BOOL)active {
    
    if (active) {
        _placeholderLabel.textColor = AppColor;
      
    } else {
        _placeholderLabel.textColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0];
    }
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    if ([_placeholderText length] > 0) {
        if (!_placeholderLabel) {
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 30, 0)];
            _placeholderLabel.numberOfLines = 1;
            _placeholderLabel.font = self.font;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            _placeholderLabel.alpha = 0;
            [self addSubview:_placeholderLabel];
        }
        self.textColor = [UIColor darkGrayColor];
        _placeholderLabel.text = _placeholderText;
        _placeholderLabel.textColor = _placeholderColor;
        [_placeholderLabel sizeToFit];
        [self sendSubviewToBack:_placeholderLabel];
    }
    
    [self layoutGUI];
    [super drawRect:rect];
}

#pragma mark -

@end
