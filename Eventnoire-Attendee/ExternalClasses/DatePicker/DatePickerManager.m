//
//  DatePicker.m
//  MeAndChange
//
//  Created by Raj Kumar Sharma on 27/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "DatePickerManager.h"

@interface DatePickerManager ()

@property (nonatomic, strong) UIViewController *parentController;

@end

@implementation DatePickerManager

+ (DatePickerManager *)dateManager {
    
    static DatePickerManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[DatePickerManager alloc] init];
    });
    return _sharedManager;
}



- (void)showDatePicker:(UIViewController *)parentController WithCurrentDate:(BOOL)isCurrent andUIDateAndTimePickerMode:(NSString *)mode completionBlock:(void (^)(NSDate *date))block {
    
     [self showDatePicker:parentController withBoolVal:isCurrent withTitle:nil andUIDateAndTimePickerMode:mode completionBlock:block];
}

- (void)showDatePicker:(UIViewController *)parentController withBoolVal:(BOOL)isCurr withTitle:(NSString *)title andUIDateAndTimePickerMode:(NSString *)mode completionBlock:(void (^)(NSDate *date))block {
    
    self.parentController = parentController;
    
    RMActionControllerStyle style = RMActionControllerStyleWhite;
    
    RMAction<RMActionController<UIDatePicker *> *> *selectAction = [RMAction<RMActionController<UIDatePicker *> *> actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController<UIDatePicker *> *controller) {
        //NSLog(@"Successfully selected date: %@", controller.contentView.date);
        block(controller.contentView.date);
    }];
    
    RMAction<RMActionController<UIDatePicker *> *> *cancelAction = [RMAction<RMActionController<UIDatePicker *> *> actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController<UIDatePicker *> *controller) {
        //NSLog(@"Date selection was cancelled");
        //block(nil);
    }];
    
    RMDateSelectionViewController *dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:style];
    dateSelectionController.title = title;
    //dateSelectionController.message = @"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'.";
    
    [dateSelectionController addAction:selectAction];
    [dateSelectionController addAction:cancelAction];
    
    if (self.showCurrentDateOption) {
        RMAction<RMActionController<UIDatePicker *> *> *nowAction = [RMAction<RMActionController<UIDatePicker *> *> actionWithTitle:@"Now" style:RMActionStyleAdditional andHandler:^(RMActionController<UIDatePicker *> * _Nonnull controller) {
            controller.contentView.date = [NSDate date];
            NSLog(@"Now button tapped");
        }];
        nowAction.dismissesActionController = NO;
        
        [dateSelectionController addAction:nowAction];
    }
    
    //You can enable or disable blur, bouncing and motion effects
    dateSelectionController.disableBouncingEffects = YES;
    dateSelectionController.disableMotionEffects = NO;
    dateSelectionController.disableBlurEffects = YES;
    
    //You can access the actual UIDatePicker via the datePicker property
    if ([mode isEqualToString:@"date"])
        dateSelectionController.datePicker.datePickerMode = UIDatePickerModeDate;
    else if([mode isEqualToString:@"time"])
        dateSelectionController.datePicker.datePickerMode = UIDatePickerModeTime;
    else if ([mode isEqualToString:@"dateAndTime"])
        dateSelectionController.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    // UIDatePickerModeDateAndTime
    //dateSelectionController.datePicker.minuteInterval = 5;
    dateSelectionController.datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        
    if (isCurr == YES)
        [dateSelectionController.datePicker setMinimumDate:[NSDate date]];
    else
        [dateSelectionController.datePicker setMinimumDate:nil];
    
    
    NSLog(@"%@", [NSDate date]);
    
    [parentController presentViewController:dateSelectionController animated:YES completion:nil];
    
}


@end
