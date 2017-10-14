//
//  TutorialVC.m
//  Eventnoire-Attendee
//
//  Created by Aiman Akhtar on 23/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.
//

#import "TutorialVC.h"
#import "LoginVC.h"

@interface TutorialVC ()

@property (weak, nonatomic) IBOutlet UIButton        *skipButton;
@property (weak, nonatomic) IBOutlet UILabel         *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIPageControl   *pageControllor;
@property (weak, nonatomic) IBOutlet UIImageView     *imageView;

@property (strong, nonatomic)        NSMutableArray  *imageArray;
@property (assign, nonatomic)        NSInteger        selectedIndex;

@property (strong,nonatomic)         NSTimer         *myTimer;
@end

@implementation TutorialVC

#pragma mark - UIViewController Life Cycle & Memory Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (NSString *familyName in [UIFont familyNames])
    { NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
        }
    }
    [self initialSetup];
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (void)initialSetup {
    self.selectedIndex = 0;
    
    //Initialise array
    self.imageArray = [[NSMutableArray alloc]initWithObjects:@"mob",@"mob",@"mob",@"mob",@"mob", nil];
   
    [self.imageView setContentMode:UIViewContentModeRedraw];
    [self.imageView setImage:[UIImage imageNamed:[self.imageArray objectAtIndex:0]]];
    
    //UITap Gesture
    UISwipeGestureRecognizer *upGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [upGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:upGestureRecognizer];
    
    UISwipeGestureRecognizer *bottomGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [bottomGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:bottomGestureRecognizer];
    
    //set timer
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                    
                                                    target:self
                    
                                                  selector:@selector(loadNextController)
                    
                                                  userInfo:nil
                    
                                                   repeats:YES];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)sender{
    
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:{
            if (self.selectedIndex+1 < [self.imageArray count]) {
                if (self.selectedIndex==0) {
                }
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.7];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [self.imageView.layer addAnimation:animation forKey:@"SwitchToView"];
                self.selectedIndex += 1;
                self.pageControllor.currentPage = self.selectedIndex;
                
            }
        }
            break;
            
        case UISwipeGestureRecognizerDirectionRight:{
            if (self.selectedIndex-1 < 0 ) {
                return;
            }else{
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.7];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromLeft];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [self.imageView.layer addAnimation:animation forKey:@"SwitchToView"];
                self.selectedIndex -= 1;
                self.pageControllor.currentPage = self.selectedIndex;
            }
        }
            break;
        default:
            break;
    }
    [self.imageView setImage:[UIImage imageNamed:[self.imageArray objectAtIndex:self.selectedIndex]]];
}

- (void)loadNextController {
    
    if (self.selectedIndex == [self.imageArray count]-1){
        
        self.selectedIndex = 0;
        
    }else{
        
        self.selectedIndex += 1;
        
    }
    
    [self.imageView setImage:[UIImage imageNamed:[self.imageArray objectAtIndex:self.selectedIndex]]];
    
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:0.7];
    
    [animation setType:kCATransitionPush];
    
    [animation setSubtype:kCATransitionFromRight];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.imageView.layer addAnimation:animation forKey:@"SwitchToView"];
    
    self.pageControllor.currentPage = self.selectedIndex;
    
}

#pragma mark - UIButton Action Methods

- (IBAction)skipButtonAction:(UIButton *)sender {
    //stop timer
    [self.myTimer invalidate];
    
    LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:loginVC animated:YES];
}


@end
