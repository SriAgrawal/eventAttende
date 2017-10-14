//
//  AESCrypto.m
//  Mobiloitte
//
//  Created by Sunil Verma on 01/11/16.
//  Copyright © 2016 Sunil Verma. All rights reserved.
//

#import "AESCrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (AES256)

- (NSData *)AES128EncryptWithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES128DecryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

@end


@implementation AESCrypto


#pragma AES encryption

+ (NSString *) AES128EncryptString:(NSString*)plaintext withKey:(NSString*)key
{
    NSData *data = [[plaintext dataUsingEncoding:NSUTF8StringEncoding] AES128EncryptWithKey:key];
    return [data base64EncodedStringWithOptions:kNilOptions];
    
}
+ (NSString *) AES128DecryptString:(NSString *)ciphertext withKey:(NSString*)key
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:kNilOptions];
    return [[NSString alloc] initWithData:[data AES128DecryptWithKey:key] encoding:NSUTF8StringEncoding];
}



#pragma mark SHA

+ (NSString *)SHA256:(NSString *)key {
    
    // Allocate memory for out put
    NSMutableData *shaOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    NSData *dataIn  = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    // SHA conversion
    CC_SHA256(dataIn.bytes, (CC_LONG)dataIn.length, shaOut.mutableBytes);
    
    NSString *hash= [shaOut description];
    
    // Remove <, > and spacing
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    // Verified at:  http://passwordsgenerator.net/sha256-hash-generator/
    
    return hash;
}


#pragma MD5 hassing

+ (NSString *)MD5:(NSString *)key {
    const char* str = [key UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
    
    // verified at:  http://www.md5.cz/
}


@end

/* Call encryption decryption decrption method like belo
 
 NSString *ec =  [AESCrypto encryptString:@"sunil2" withKey:@"1234567890"];
 
 NSString *dc =  [AESCrypto decryptString:ec withKey:@"1234567890Encryption "];
 
 NSLog(@"   %@       %@",ec,dc);
 
 
 For MD5
 NSLog(@"......  %@",[AESCrypto MD5:@"Hello"]);
 
 for SHA 256
 
 NSLog(@"  %@    %@ ",ec ,[AESCrypto SHA256:@"Sunil"]);
 
 
 */
