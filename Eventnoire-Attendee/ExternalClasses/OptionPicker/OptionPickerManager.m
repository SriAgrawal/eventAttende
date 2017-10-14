//
//  OptionPickerManager.m
//  MeAndChange
//
//  Created by Raj Kumar Sharma on 27/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "OptionPickerManager.h"

@interface OptionPickerManager () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIViewController *parentController;
@property (nonatomic, strong) NSArray *arrayDataSource;


@end

@implementation OptionPickerManager

+ (OptionPickerManager *)pickerManagerManager {
    
    static OptionPickerManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[OptionPickerManager alloc] init];
    });
    return _sharedManager;
}

- (void)showOptionPicker:(UIViewController *)parentController withData:(NSArray *)data completionBlock:(void (^)(NSArray *selectedIndexes, NSArray *selectedValues))block {
    
    self.arrayDataSource = data;
    self.parentController = parentController;

    RMActionControllerStyle style = RMActionControllerStyleWhite;
    
    RMAction<RMActionController<UIPickerView *> *> *selectAction = [RMAction<RMActionController<UIPickerView *> *> actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController<UIPickerView *> *controller) {
        NSMutableArray *selectedRows = [NSMutableArray array];
        NSMutableArray *selectedValues = [NSMutableArray array];

        if (data.count) {
            for(NSInteger i=0 ; i<[controller.contentView numberOfComponents] ; i++) {
                [selectedRows addObject:@([controller.contentView selectedRowInComponent:i])];
                [selectedValues addObject:self.arrayDataSource[[controller.contentView selectedRowInComponent:i]]];
            }
            block([selectedRows mutableCopy], [selectedValues mutableCopy]);
        }
        
        
        
        
        //NSLog(@"Successfully selected rows: %@", selectedRows);
    }];
    
    RMAction<RMActionController<UIPickerView *> *> *cancelAction = [RMAction<RMActionController<UIPickerView *> *> actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController<UIPickerView *> *controller) {
        //NSLog(@"Row selection was canceled");
    }];
    
    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style];
    //pickerController.title = @"Choose";
    //pickerController.message = @"Please choose a row and press 'Select' or 'Cancel'.";
    pickerController.picker.dataSource = self;
    pickerController.picker.delegate = self;
    
    [pickerController addAction:selectAction];
    [pickerController addAction:cancelAction];
    
    //You can enable or disable blur, bouncing and motion effects
    pickerController.disableBouncingEffects = YES;
    pickerController.disableMotionEffects = YES;
    pickerController.disableBlurEffects = YES;
    
    //On the iPad we want to show the picker view controller within a popover. Fortunately, we can use iOS 8 API for this! :)
    //(Of course only if we are running on iOS 8 or later)
//    if([pickerController respondsToSelector:@selector(popoverPresentationController)] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        //First we set the modal presentation style to the popover style
//        pickerController.modalPresentationStyle = UIModalPresentationPopover;
//        
//        //Then we tell the popover presentation controller, where the popover should appear
//        pickerController.popoverPresentationController.sourceView = parentController.view;
//        pickerController.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    }
    
    //Now just present the picker view controller using the standard iOS presentation method
    [parentController presentViewController:pickerController animated:YES completion:nil];
    
}

#pragma mark - RMPickerViewController Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.arrayDataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.arrayDataSource[row];
}
@end
