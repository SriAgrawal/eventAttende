//
//  EventnoireTextField.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 24/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "EventnoireTextField.h"
#import "UIImageView+Addition.h"
#import "Macro.h"


@interface EventnoireTextField ()

@property (strong, nonatomic) UIImageView   *iconImageView;
@property (strong, nonatomic) UIView        *paddingView;
@property (strong, nonatomic) UIColor       *errorColor;
@property (strong, nonatomic) UIColor       *normalColor;
@property (strong, nonatomic) UIColor       *underLineColor;

@property (strong, nonatomic) CALayer       *underLine;


@end

@implementation EventnoireTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self placeHolderText:self.placeholder];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self defaultSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self =  [super initWithCoder:aDecoder];
    
    if(self){
        [self defaultSetup];
    }
    
    return self;
}

#pragma mark - Private methods

- (void)defaultSetup {
    
    self.errorColor = [UIColor redColor];
    self.normalColor = [UIColor blackColor];
    
    self.tintColor = [UIColor blackColor];
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.clipsToBounds = YES;
    [self setBorderStyle:UITextBorderStyleNone];
    
    self.font = [UIFont fontWithName:@"OpenSans" size:15];
    [self placeHolderTextWithColor:self.placeholder Color:[UIColor blackColor]];
    self.active = NO;
}

- (void)addUnderline {
    
    CGFloat borderWidth = 0.5f;
    
    if (!self.underLine) {
        self.underLine = [CALayer layer];
    }
    
    self.underLine.borderColor = [self.underLineColor CGColor];
    
    self.underLine.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
    self.underLine.borderWidth = borderWidth;
    [self.layer addSublayer:self.underLine];
    [self.layer setMasksToBounds:YES];
    
    self.active = NO;
}

- (void)removeUnderLine {
    [self.underLine removeFromSuperlayer];
}

- (void)addPaddingWithValue:(CGFloat )value {
    
    if (!self.paddingView) {
        self.paddingView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, value, self.frame.size.height)];
    } else {
        [self.paddingView setFrame:CGRectMake(8, 0, value, self.frame.size.height)];
    }
    
    [self setLeftView:self.paddingView];
    self.paddingView.tag = 998;
    
    [self setLeftViewMode:UITextFieldViewModeAlways];
}

- (void)addplaceHolderImageInsideView:(UIView *)view placeHolderImage:(UIImage *)image {
    
    if (!self.paddingView) {
        [self addPaddingWithValue:30];
        view = self.paddingView;
    }
    
    UIImageView *placeHolderImageView = [view viewWithTag:999];
    if (!placeHolderImageView) {
        placeHolderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, view.frame.size.height / 2, 20, 20)];
        placeHolderImageView.tag = 999;
        [view addSubview:placeHolderImageView];
        [placeHolderImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    [placeHolderImageView setImage:image];
    placeHolderImageView.center = CGPointMake(view.frame.size.width - 5,
                                              view.frame.size.height / 2);
    
    self.iconImageView = placeHolderImageView;
    
    self.active = NO;
}

- (void)setPlaceholderImage:(UIImage *)iconImage {
    if (iconImage) {
        [self setPaddingIcon:iconImage];
    }
}

#pragma mark - Public methods

- (void)setActive:(BOOL)active {
    
    if (active) {
        [self.iconImageView color:[UIColor blackColor]];
        [self placeHolderTextWithColor:[self.attributedPlaceholder string] Color:self.normalColor];
    } else {
        [self.iconImageView color:self.normalColor];
        [self placeHolderTextWithColor:[self.attributedPlaceholder string] Color:self.normalColor];
    }
}

- (void)error:(BOOL)status {
    self.layer.borderColor = status ? [self.errorColor CGColor]:[self.normalColor CGColor];
}

- (void)setPaddingIcon:(UIImage *)iconImage {
    
    [self addplaceHolderImageInsideView:self.paddingView placeHolderImage:iconImage];
}

- (void)setPaddingValue:(NSInteger)value {
    [self addPaddingWithValue:value];
}

- (void)placeHolderText:(NSString *)text {
    if (text.length) {//for avoiding nil placehoder
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: self.normalColor}];
    }
}

- (void)placeHolderTextWithColor:(NSString *)text Color:(UIColor *)color {
    if (text.length) {//for avoiding nil placehoder
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
    }
}


@end
