//
//  OptionsPickerSheetView.m
//  VPW
//
//  Created by Sunil Verma on 10/1/14.
//  Copyright (c) 2014 Halosys. All rights reserved.
//

#import "OptionsPickerSheetView.h"
#import "AppDelegate.h"
#import "Macro.h"

OptionPickerSheetBlock optionPickerBlock;
UIPickerView *picker;
NSInteger     currentPick;
NSArray      *pickerOptions;

static OptionsPickerSheetView *optionsPickerSheetView = nil;
@implementation OptionsPickerSheetView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}


+ (id)sharedPicker {
    
    if (!optionsPickerSheetView) {
        
        optionsPickerSheetView = [[OptionsPickerSheetView alloc] init];
    }
    
    return optionsPickerSheetView;
}


-(void)showPickerSheetWithOptions:(NSArray *)options AndComplitionblock:(OptionPickerSheetBlock)block
{
    [self endEditing:YES];
    optionPickerBlock = [block copy];
    
    pickerOptions = [[NSArray alloc] initWithArray:options];

    currentPick = 0;
    
        picker = [[UIPickerView alloc] init];
        picker.showsSelectionIndicator =  YES;
        picker.delegate = self;
        picker.dataSource = self;
        
        
        [optionsPickerSheetView addSubview:picker];
        
   // AppDelegate *appDel = [[UIApplication sharedApplication] delegate];

      [picker setFrame:CGRectMake(0, 40, [APPDELEGATE window].frame.size.width, 216)];

        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(5, 0,[APPDELEGATE window].frame.size.width-10, 40)];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneActionSheet:)];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
        UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems: [NSArray arrayWithObjects:cancelBtn,flexibleSpace,doneBtn, nil] animated:NO];
        [optionsPickerSheetView addSubview:toolBar];
        
    [picker selectRow:currentPick inComponent:0 animated:NO];
    
    [picker setFrame:CGRectMake(0, 40, [APPDELEGATE window].frame.size.width, 216)];
    
    [picker setBackgroundColor:[UIColor clearColor]];
    [picker reloadAllComponents];
    
    
    UIView *tempView = [[UIView alloc] initWithFrame:[APPDELEGATE window].bounds];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [tempView setAlpha:0.0];
    [tempView setTag:786];
    
    
    [[APPDELEGATE window] addSubview:tempView];
    
    [[APPDELEGATE window] addSubview:optionsPickerSheetView];
    [[APPDELEGATE window] bringSubviewToFront:optionsPickerSheetView];
    
    optionsPickerSheetView.frame = CGRectMake(0,[APPDELEGATE window].frame.size.height, [APPDELEGATE window].frame.size.width, 260);
    
    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, [APPDELEGATE window].frame.size.height -260, [APPDELEGATE window].frame.size.width, 260);
        [tempView setAlpha:0.50];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

-(void)cancelActionSheet:(id)sender{
    [self removePickerView];
}
#pragma mark - Action Sheet Callback function
-(void)doneActionSheet:(id)sender{
    
    optionPickerBlock([pickerOptions objectAtIndex:currentPick],currentPick);
    [self removePickerView];
}
-(void)removePickerView
{
    //AppDelegate *appDel = [[UIApplication sharedApplication] delegate];

    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, [APPDELEGATE window].frame.size.height, [APPDELEGATE window].frame.size.width, 260);
        
    } completion:^(BOOL finished) {
        for (id obj  in optionsPickerSheetView.subviews) {
            [obj removeFromSuperview];
        }
        [optionsPickerSheetView removeFromSuperview];
        optionsPickerSheetView =nil;
        [[[APPDELEGATE window] viewWithTag:786] removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDelegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [pickerOptions count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    currentPick = row;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if (!label)
    {
        // Customize your label (or any other type UIView) here
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, pickerView.bounds.size.width * 0.8, 25.0f)];
        
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:20.0]];
    if (row < [pickerOptions count])
    {
        label.text = (NSString *)[pickerOptions objectAtIndex:row];
        
    }
    return label;
}



@end
