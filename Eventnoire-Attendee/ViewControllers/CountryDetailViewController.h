//
//  CountryDetailViewController.h
//  VendorApp
//
//  Created by Abhishek Agarwal on 07/04/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CountryDetailModal;

@protocol CountryListDeleagte <NSObject>

-(void)selectedCountryDetail:(CountryDetailModal *)country;

@end

@interface CountryDetailViewController : UIViewController

@property (weak, nonatomic) id<CountryListDeleagte> delegate;

@end

@interface CountryDetailModal : NSObject

@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *countryPhoneCode;
@property (strong, nonatomic) NSString *countryFlagLink;
@property (assign, nonatomic) BOOL isSelected;

+(CountryDetailModal *)fetchAllCountryDetail:(NSDictionary *)countryDictionary;

@end
