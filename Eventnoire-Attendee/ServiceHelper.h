//
//  ServiceHelper.h
//  VendorApp
//
//  Created by Sunil Verma on 02/02/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceHelper.h"

typedef enum : NSUInteger {
    POST,
    GET,
    PUT
} ServiceType;

typedef void(^RequestCompletionBlock)(NSDictionary *result, NSError  *error);

//Pagination
typedef struct {
    int totalNumberOfRecord;
    int  pageLimit;
    int currentPage;
    int totalNumberOfPages;
} PAGE;

static float SCROLLUPREFRESHHEIGHT = 40.0;

@interface ServiceHelper : NSObject

+(id)sharedServiceHelper;

//Cancel Request at any time you want
-(void)cancelRequestSession;

// Use to call API with Request, APIName and Service Type
-(void)callApiWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  andApiType:(ServiceType)type andIsRequiredHud:(BOOL)isRequiredHud WithComptionBlock:(RequestCompletionBlock)block;

//Use to send request in multipart with POST type
-(void)multipartApiCallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  andIsRequiredHud:(BOOL)isRequiredHud WithComptionBlock:(RequestCompletionBlock)block;

@end
