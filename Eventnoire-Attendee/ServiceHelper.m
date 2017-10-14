//  ServiceHelper.m
//  VendorApp
//  Created by Sunil Verma on 02/02/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.


#import "Header.h"

NSString *const NO_INTERNATE_CONNECTION       =@"The Internet connection appears to be offline.";

//Staging url
//static NSString *BASE_URL =  @"http://ec2-52-221-54-107.ap-southeast-1.compute.amazonaws.com/PROJECTS/EventNoire/public/api/";

static NSString *BASE_URL =  @"http://ec2-52-35-43-247.us-west-2.compute.amazonaws.com/api/";


@interface ServiceHelper()<NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    //Required to Cancel at any time
    NSURLSession *requestSession;
}

@end

static ServiceHelper *serviceHelper = nil;

@implementation ServiceHelper

+(id)sharedServiceHelper
{
    if (!serviceHelper) {
        serviceHelper = [[ServiceHelper alloc] init];
    }
    return serviceHelper;
}

-(void)cancelRequestSession
{
    [requestSession invalidateAndCancel];
}

-(NSString *)getAuthHeader
{
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", @"helposity", @"!12@3#4$5%"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    return [NSString stringWithFormat:@"Basic %@", base64AuthCredentials];
}

-(void)callApiWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  andApiType:(ServiceType)type andIsRequiredHud:(BOOL)isRequiredHud WithComptionBlock:(RequestCompletionBlock)block
{
    //Copy Block
    RequestCompletionBlock completionBlock = [block copy];
    
    //Return When no network
    if(![APPDELEGATE isReachable])
    {
            [RequestTimeOutView showWithMessage:@"The Internet connection appears to be offline." forTime:2.0];
           // completionBlock(nil, [NSError errorWithDomain:@"com.helposity" code:100 userInfo:nil]);
        return;
    }
    
    if (isRequiredHud)
        [self startIndicator];
    
    NSMutableString *urlString;
    
    //Make URL
    if ([apiName isEqualToString:makePaymentApi]) {
        //http://172.16.0.101/PROJECTS/eventnoire/makePayment.php
        urlString = [NSMutableString stringWithString:@"http://ec2-52-221-54-107.ap-southeast-1.compute.amazonaws.com/PROJECTS/EventNoire/makePayment.php"];
    }else {
        urlString = [NSMutableString stringWithString:BASE_URL];
        [urlString appendFormat:@"%@",apiName];
    }
    
    
    //Add more parameter in request which used throughout the service
    [parameterDict setObject:@"0" forKey:pUserType];

    if ([NSUSERDEFAULT valueForKey:pUserDetail]) {
        NSDictionary *userInfoDict = [NSUSERDEFAULT valueForKey:pUserDetail];
        [parameterDict setValue:[userInfoDict objectForKey:pUserID] forKey:pUserID];
    }
    
    //Set Request In URL when service type is GET
    if (type == GET) {

        BOOL isFirst = YES;
        for (NSString *key in [parameterDict allKeys]) {
            
            id object = parameterDict[key];
            if ([object isKindOfClass:[NSArray class]]) {
                
                for (id eachObject in object) {
                    [urlString appendString: [NSString stringWithFormat:@"%@%@=%@", isFirst ? @"?": @"&", key, eachObject]];
                    isFirst = NO;
                }
            }
            else{
                [urlString appendString: [NSString stringWithFormat:@"%@%@=%@", isFirst ? @"?": @"&", key, parameterDict[key]]];
            }
            
            isFirst = NO;
        }
    }
    
    //Make Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    switch (type) {
        case GET:
            [request setHTTPMethod:@"GET"];

            break;
        case PUT:
            [request setHTTPMethod:@"PUT"];

            break;
        case POST:
            [request setHTTPMethod:@"POST"];

            break;
        default:
            break;
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if ([[NSUSERDEFAULT valueForKey:pUserDetail] valueForKey:pToken]) {
        NSDictionary *userInfoDict = [NSUSERDEFAULT valueForKey:pUserDetail];
        [request setValue:[NSString stringWithFormat:@"Bearer %@",[userInfoDict objectForKey:pToken]]  forHTTPHeaderField:pAuthorization];
    }
    //[request setValue:[self getAuthHeader] forHTTPHeaderField:@"Authorization"];

    //Set Request in BODY when request tyep is POST,PUT
    if (type != GET) {
        if ([apiName isEqualToString:loginApi] || [apiName isEqualToString:signUpApi] || [apiName isEqualToString:logoutApi] || [apiName isEqualToString:socialLoginApi]) {
            
            if ([[APPDELEGATE deviceToken] length]) {
                [parameterDict setValue: [APPDELEGATE deviceToken] forKey:pDeviceToken];
            }
            [parameterDict setValue: @"0" forKey:pDeviceType];
        }
        
        NSLog(@"Request URL :%@   Params:  %@",urlString,[[NSString alloc] initWithData:[parameterDict toJSON] encoding:NSUTF8StringEncoding]);
        
        [request setHTTPBody:[parameterDict toJSON]];
    }
    
    //Check Session if not exist then create
    if (!requestSession) {
        NSURLSessionConfiguration *sessionConfig =  [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setTimeoutIntervalForRequest:30.0];
        requestSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    
    //Send Request to the server
    [[requestSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (isRequiredHud)
            [self stopIndicator];
        
        if (!error) {
            //Success
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            NSLog(@" >>>>>>>   %@",res.allHeaderFields);
               NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            id result = [NSDictionary dictionaryWithContentsOfJSONURLData:data];
            
            NSLog(@" error : %@   Code: %ld  ResponseStr......   %@    ...  %@  ",error,(long)[res statusCode],result,responseStr);

            NSDictionary *resultDict ;
            if ([result isKindOfClass:[NSDictionary class]])
                resultDict = result;
            else
                resultDict = [NSDictionary dictionary];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([[resultDict objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 200) {
                    
                    if ([apiName isEqualToString:loginApi] || [apiName isEqualToString:signUpApi] || [apiName isEqualToString:socialLoginApi]) {
                        NSDictionary *userDetail = [resultDict objectForKeyNotNull:pUserDetail expectedObj:[NSDictionary dictionary]];

                        NSMutableDictionary *userDetailInfo = [NSMutableDictionary dictionary];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pUserID expectedObj:[NSString string]] forKey:pUserID];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pIsAnouncement expectedObj:[NSString string]] forKey:pIsAnouncement];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pIsFriendUpdate expectedObj:[NSString string]] forKey:pIsFriendUpdate];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pToken expectedObj:[NSString string]] forKey:pToken];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pEmailID expectedObj:[NSString string]] forKey:pEmailID];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pFirstName expectedObj:[NSString string]] forKey:pFirstName];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pLastName expectedObj:[NSString string]] forKey:pLastName];
                        [userDetailInfo setValue:[userDetail objectForKeyNotNull:pProfilePic expectedObj:[NSString string]] forKey:pProfilePic];
											
                        NSString *loginType = [userDetail objectForKeyNotNull:pLogInType expectedObj:[NSString string]];
										
                        if ([loginType length])
                            [userDetailInfo setValue:[userDetail objectForKeyNotNull:pLogInType expectedObj:[NSString string]] forKey:pLogInType];
                        else
                            [userDetailInfo setValue:@"normal" forKey:pLogInType];

											
                        NSArray *interestArray = [userDetail objectForKeyNotNull:pInterestData expectedObj:[NSArray array]];
                        
                        [userDetailInfo setValue:([interestArray count])?@"1":@"0" forKey:pInterestData];
                        
                        [NSUSERDEFAULT removeObjectForKey:pUserDetail];
                        [NSUSERDEFAULT setValue:userDetailInfo forKey:pUserDetail];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(resultDict, error);
                    });
                }else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{

                        if ([resultDict objectForKey:pResponseMessage]) {
                              completionBlock(resultDict, [NSError errorWithDomain:@"com.mobiloitte" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[resultDict objectForKeyNotNull:pResponseMessage expectedObj:@"Error"],NSLocalizedDescriptionKey, nil]]);
                        }else {
                              completionBlock([NSDictionary dictionaryWithObjectsAndKeys:@"Something went wrong. Please try again later.",pResponseMessage, nil], [NSError errorWithDomain:@"com.mobiloitte" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Something went wrong. Please try again later.",NSLocalizedDescriptionKey, nil]]);
                        }
                  
                    });
                }
            });
        }else{
            //Error
            NSLog(@"Error %@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSDictionary dictionaryWithObject:error.description forKey:pResponseMessage], error);
                
            });
        }
    }] resume];
}

-(void)multipartApiCallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName andIsRequiredHud:(BOOL)isRequiredHud WithComptionBlock:(RequestCompletionBlock)block
{
    
    if (isRequiredHud)
       [self startIndicator];
    
    NSMutableString *urlString = [NSMutableString stringWithString:BASE_URL];
    
    [urlString appendFormat:@"%@",apiName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[self getAuthHeader] forHTTPHeaderField:@"Authorization"];

    NSLog(@"URL   %@    %@",urlString, parameterDict);
  
    
    NSString *boundary = @"14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    [parameterDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"\r\n",key,@"file.png"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:obj];

        }else
        {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",obj] dataUsingEncoding:NSUTF8StringEncoding]];
 
        }
        
    }];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    RequestCompletionBlock completionBlock = [block copy];
    
    if(![APPDELEGATE isReachable])
    {
        
        // [RequestTimeOutView showWithMessage:NO_INTERNATE_CONNECTION forTime:3.0];
        block(nil,  [NSError errorWithDomain:@"com.thirtysix" code:100 userInfo:nil]);
        
        return;
    }
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
  
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (isRequiredHud)
           [self stopIndicator];

        if (!error) {
            // success response
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            //  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            id result = [NSDictionary dictionaryWithContentsOfJSONURLData:data];
            
            NSLog(@" error : %@   Code: %ld  ResponseStr......   %@     ",error,(long)[res statusCode],result);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result, error);
                
            });
            
            
        }
    }];
    [uploadTask resume];
}



-(NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    //    const char swf[3] = {'F', 'W', 'S'};
    //    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }
    
    return @"application/octet-stream"; // default type
    
}




#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    NSLog(@"");
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSLog(@"");
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"");
    
}


#pragma mark NSURLSessionTaskDelegate


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    NSLog(@"");
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSLog(@"");
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * __nullable bodyStream))completionHandler
{
    NSLog(@"");
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"");
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"");
    
}
    
#pragma mark - Start Hud

//static NSInteger indicatorTag = 100001;

-(void)startIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] withText:@"" animated:YES];
    });
    
    //    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    spinner.tag = indicatorTag;
    //   // [spinner setColor:[UIColor colorWithRed:72.0/256.0 green:176.0/256.0 blue:254.0/256.0 alpha:1]];
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        spinner.center = CGPointMake([APPDELEGATE window].bounds.size.width/2, [APPDELEGATE window].bounds.size.height/2);
    //        [spinner startAnimating];
    //
    //        [[APPDELEGATE window] addSubview:spinner];
    //    });
}

#pragma mark - Stop Hud

-(void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:[APPDELEGATE window] animated:YES];
    });
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[[APPDELEGATE window] viewWithTag:indicatorTag];
    //        [spinner stopAnimating];
    //
    //        [spinner removeFromSuperview];
    //    });
}
@end
