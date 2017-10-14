//
//  MeVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 29/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#import "NSDictionary+NullChecker.h"
#import "UIImage+Addition.h"
#import "UIImageView+WebCache.h"
#import "RequestTimeOutView.h"
#import "ServiceHelper.h"
#import "ActionSheet.h"
#import "InterestVC.h"
#import "SettingVC.h"
#import "HistoryVC.h"
#import "TicketVC.h"
#import "Macro.h"
#import "MeVC.h"

@interface MeVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation MeVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void)initialSetup {
	
	
	if (![[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pFirstName] length] && ![[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pLastName] length]) {
		self.userNameLabel.text = @"Your Name";
	}else{
		 self.userNameLabel.text = [[[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pFirstName] stringByAppendingString:@" "]stringByAppendingString:[[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pLastName]];
	}
	
    	NSDictionary *userDetail = [NSUSERDEFAULT valueForKey:pUserDetail];
	[self.userImageView sd_setImageWithURL:[NSURL URLWithString:[userDetail valueForKey:pProfilePic]] placeholderImage:[UIImage imageNamed:@"userPlaceholder"]];

	
	
    self.view.backgroundColor = UIColor.whiteColor;
    
    // Parallax Header
    self.segmentedPager.parallaxHeader.view = self.headerView;
    self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.segmentedPager.parallaxHeader.height = 250;
    self.segmentedPager.parallaxHeader.minimumHeight = 64;
    
    // Segmented Control customization
    self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedPager.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedPager.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.segmentedPager.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedPager.segmentedControl.selectionIndicatorColor = [UIColor blackColor];
    
    self.segmentedPager.segmentedControlEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 35.0f;
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didSelectViewWithTitle:(NSString *)title {
    NSLog(@"%@ page selected.", title);
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didScrollWithParallaxHeader:(MXParallaxHeader *)parallaxHeader {
    self.widthConstraint.constant = self.userImageView.frame.size.height;
    self.userNameLabel.hidden = (self.widthConstraint.constant == 0)? YES : NO;
    self.userImageView.layer.cornerRadius = self.widthConstraint.constant / 2;
    NSLog(@"progress %f", parallaxHeader.progress);
}

#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(MXPageSegue *)segue sender:(id)sender {
//    if (segue.pageIndex == 1) {
//        TicketVC *ticketController = segue.destinationViewController;
//        ticketController.isFromSaved = YES;
//     }
}

#pragma mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 4;
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index {
    return @[@"Tickets", @"Saved", @"Interest", @"History"][index];
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager segueIdentifierForPageAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            return @"ticket";
           
        case 1:
            return @"saved";
            
        case 2:
            return @"interest";
            
        case 3:
            return @"history";
            
        default:
            return @"ticket";
    }
}

#pragma mark - UIButton Action Methods

- (IBAction)settingButtonAction:(id)sender {
    [self.view endEditing:YES];
   
    SettingVC *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (IBAction)cameraButtonAction:(id)sender {
	[self.view endEditing:YES];
	
	[self.view endEditing:YES];
	
	
	
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	
	picker.delegate = self;
	
	picker.allowsEditing = YES;
	
	
	
	[[ActionSheet sheetManager] presentSheetWithTitle:nil message:nil cancelBttonTitle:@"Cancel" destrictiveButtonTitle:nil andButtonsWithTitle:@[@"Camera",@"Gallery"] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle){
		
		if(index == 0)
			
			{
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
				
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				
				[self.navigationController presentViewController:picker animated:YES completion:nil];
				
			}else
				
				[RequestTimeOutView showWithMessage:@"Device has no camera" forTime:5.0];
			
			}
		
		if(index == 1)
			
			{
			
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			
			[self presentViewController:picker animated:YES completion:nil];
			
			}
		
	}];
	
	
}


#pragma mark - UIImagePicker Delegate method



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	
	[self dismissViewControllerAnimated:YES completion:^{
		[self.userImageView setImage:image];
		NSDictionary *userDetail = [NSUSERDEFAULT valueForKey:pUserDetail];
		NSMutableDictionary *userDetailDictionary = [NSMutableDictionary dictionary];
		[userDetailDictionary setValue:[userDetail objectForKey:pFirstName] forKey:pFirstName];
		[userDetailDictionary setValue:[userDetail objectForKey:pLastName] forKey:pLastName];
		[userDetailDictionary setValue:[userDetail objectForKey:pEmailID] forKey:pEmailID];
		[userDetailDictionary setValue:[userDetail objectForKey:pLogInType] forKey:pLogInTypeUpdate];
		[userDetailDictionary setValue:[image getBase64String] forKey:pProfilePic];
		[userDetailDictionary setValue:@"" forKey:pPhoneNumber];


		[self apiCallForUserProfileUpdate:userDetailDictionary];
		
	}];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissViewControllerAnimated:YES completion:nil];
}



-(void)apiCallForUserProfileUpdate:(NSMutableDictionary *)request {
	
	[[ServiceHelper sharedServiceHelper] callApiWithParameter:request apiName:updateProfileApi andApiType:POST andIsRequiredHud:YES WithComptionBlock:^(NSDictionary *result, NSError *error){
		
		if (!error) {
				//Success and 200 responseCode
			NSMutableDictionary *userDict = [[NSUSERDEFAULT valueForKey:pUserDetail] mutableCopy];
			[NSUSERDEFAULT removeObjectForKey:pUserDetail];
			
			NSDictionary *userDetail = [result objectForKeyNotNull:pUserDetail expectedObj:[NSDictionary dictionary]];
			
			[userDict setValue:[userDetail objectForKeyNotNull:pProfilePic expectedObj:[NSString string]] forKey:pProfilePic];
			[NSUSERDEFAULT setValue:userDict forKey:pUserDetail];

			
		}else if (error.code == 100) {
				//Success but other than 200 responseCode
			NSString *errorMessage = [result objectForKeyNotNull:pResponseMessage expectedObj:[NSString string]];
			[RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
		}else {
				//Error
            NSString *errorMessage = error.localizedDescription;
            [RequestTimeOutView showWithMessage:errorMessage forTime:2.0];
		}
	}];
}




@end
