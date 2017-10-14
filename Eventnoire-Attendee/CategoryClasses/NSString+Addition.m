//
//  NSString+Addition.m
//  VoiceSociety
//
//  Created by Raj Kumar Sharma on 04/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "NSString+Addition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Addition)

- (CGFloat)getEstimatedHeightWithFont:(UIFont*)font withWidth:(CGFloat)width withExtraHeight:(CGFloat)ht{
    
    if (!self || !self.length)
        return 0;
    
    CGFloat labelSize;
    CGRect rect = [self boundingRectWithSize : (CGSize){width, CGFLOAT_MAX}
                                     options : NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes : @{ NSFontAttributeName: font }
                                     context : nil];
    labelSize = rect.size.height;
    
    return labelSize + ht;
}
/*
 method to remove white spaces
 */

- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

// Checking if String is Empty
-(BOOL)isBlank {
    
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""]) ? YES : NO;
}

//Checking if String is empty or nil
-(BOOL)isValid {
    
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""] || self == nil || [self isEqualToString:@"(null)"]) ? NO :YES;
}

// remove white spaces from String
- (NSString *)removeWhiteSpacesFromString {
    
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

// Counts number of Words in String
- (NSUInteger)countNumberOfWords {
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSUInteger count = 0;
    while ([scanner scanUpToCharactersFromSet: whiteSpace  intoString: nil])
        count++;
    
    return count;
}

// If string contains substring
- (BOOL)containsString:(NSString *)subString {
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

// If my string starts with given string
- (BOOL)isBeginsWith:(NSString *)string {
    return ([self hasPrefix:string]) ? YES : NO;
}

// If my string ends with given string
- (BOOL)isEndssWith:(NSString *)string {
    return ([self hasSuffix:string]) ? YES : NO;
}


// Replace particular characters in my string with new character
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar {
    return  [self stringByReplacingOccurrencesOfString:olderChar withString:newerChar];
}

// Get Substring from particular location to given lenght
- (NSString*)getSubstringFrom:(NSInteger)begin to:(NSInteger)end {
    
    NSRange r;
    r.location = begin;
    r.length = end - begin;
    return [self substringWithRange:r];
}

// Add substring to main String
- (NSString *)addString:(NSString *)string {
    
    if(!string || string.length == 0)
        return self;
    
    return [self stringByAppendingString:string];
}

// Remove particular sub string from main string
-(NSString *)removeSubString:(NSString *)subString {
    
    if ([self containsString:subString]) {
        NSRange range = [self rangeOfString:subString];
        return  [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

// If my string contains ony letters
- (BOOL)containsOnlyLetters {
    
    NSCharacterSet *letterCharacterset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:letterCharacterset].location == NSNotFound);
}

// If my string contains only numbers
- (BOOL)containsOnlyNumbers {
    
    NSCharacterSet *numbersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbersCharacterSet].location == NSNotFound);
}

// If my string contains letters and numbers
- (BOOL)containsOnlyNumbersAndLetters {
    
    NSCharacterSet *numAndLetterCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:numAndLetterCharSet].location == NSNotFound);
}

// If my string is available in particular array
- (BOOL)isInThisarray:(NSArray*)array {
    
    for(NSString *string in array) {
        if([self isEqualToString:string])
            return YES;
    }
    return NO;
}

// Get String from array
+ (NSString *)getStringFromArray:(NSArray *)array {
    return [array componentsJoinedByString:@" "];
}

// Convert Array from my String
- (NSArray *)getArray {
    return [self componentsSeparatedByString:@" "];
}

// Get My Application Version number
+ (NSString *)getMyApplicationVersion {
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleVersion"];
    return version;
}

// Get My Application name
+ (NSString *)getMyApplicationName {
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleDisplayName"];
    return name;
}

// Convert string to NSData
- (NSData *)convertToData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

// Get String from NSData
+ (NSString *)getStringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
}

// Is Valid First Name
- (BOOL)isValidFirstName {
    NSCharacterSet *letterCharacterset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:letterCharacterset].location == NSNotFound);
}


// Is Valid Email
- (BOOL)isValidEmail {
    
    NSString *emailRegex = @"^(\\w[.]?)*\\w+[@](\\w[.]?)*\\w+[.][a-z]{2,4}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

// Is Valid Phone
- (BOOL)isValidPhoneNumber {
    
    NSString *regex = @"\\+?[0-9]{10,15}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

// Is Valid URL
- (BOOL)isValidUrl {
    
    NSString *regex =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

// Is Valid Full name
- (BOOL)isValidFullName {
    
    NSString *regex = @"[A-Za-z]+[[\\s][A-Za-z]+]*";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [nameTest evaluateWithObject:self];
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Getting Attributed String <<<<<<<<<<<<<<<<<<<<<<<<*/

- (NSAttributedString *)getAttributedString:(NSString *)string withColor:(UIColor *)color withFont:(UIFont *)font {
    
    NSString *effectedStr1 = [NSString stringWithFormat:@"(%@)",string];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:effectedStr1 options:kNilOptions error:nil];
    NSRange range = NSMakeRange(0, self.length);
    [regex enumerateMatchesInString:self options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:font range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:subStringRange];
    }];
    
    return mutableAttributedString;
}

- (NSAttributedString *)getSimpleMultiAttributedStringWithFirstStr:(NSString *)firstStr withColor :(UIColor *)firstStrColor withFont :(UIFont *)firstStrFont secondStr:(NSString *)secondStr withColor:(UIColor *)secondStrColor withFont :(UIFont *)secondStrFont {
    
    NSString *effectedStr1 = [NSString stringWithFormat:@"(%@)",firstStr];
    NSString *effectedStr2 = [NSString stringWithFormat:@"(%@)",secondStr ];
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:effectedStr1 options:kNilOptions error:nil];
    NSRange range = NSMakeRange(0,self.length);
    [regex enumerateMatchesInString:self options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:firstStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:firstStrColor range:subStringRange];
    }];
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:effectedStr2 options:kNilOptions error:nil];
    NSRange range1 = NSMakeRange(0,self.length);
    [regex1 enumerateMatchesInString:self options:kNilOptions range:range1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:secondStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:secondStrColor range:subStringRange];
    }];
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    return mutableAttributedString;
}

- (NSAttributedString *)getMultiAttributedStringWithCompleteStrColor:(UIColor *)completeStrColor withFont:(UIFont *)completeStrFont firstStr:(NSString *)firstStr withColor :(UIColor *)firstStrColor withFont :(UIFont *)firstStrFont secondStr:(NSString *)secondStr withColor:(UIColor *)secondStrColor withFont :(UIFont *)secondStrFont {
    
    NSString *effectedStr1 = [NSString stringWithFormat:@"(%@)",firstStr];
    NSString *effectedStr2 = [NSString stringWithFormat:@"(%@)",secondStr];
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //replacing "AND" to "and" and coloring white
    //NSString *text = [initialStr stringByReplacingOccurrencesOfString:@"AND" withString:@"and"];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:completeStrColor range:NSMakeRange(0,self.length)];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:effectedStr1 options:kNilOptions error:nil];
    NSRange range = NSMakeRange(0,self.length);
    [regex enumerateMatchesInString:self options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:firstStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:firstStrColor range:subStringRange];
    }];
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:effectedStr2 options:kNilOptions error:nil];
    NSRange range1 = NSMakeRange(0,self.length);
    [regex1 enumerateMatchesInString:self options:kNilOptions range:range1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:secondStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:secondStrColor range:subStringRange];
    }];
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    return mutableAttributedString;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Getting Attributed String Based on Seperation <<<<<<<<<<<<<<<<<<<<<<<<*/

- (NSAttributedString*)getAttributedStringSeperatedBy:(NSString *)seperationStr firstHalfColor :(UIColor *)color1 firstHalfFont :(UIFont *)font1 secondHalfColor:(UIColor *)color2 secondHalfFont :(UIFont *)font2 {
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self];
    
    if (!seperationStr.length || ![self containsString:seperationStr]) {
        return attrString;
    }
    
    [attrString beginEditing];
    
    // validating that string contails white space or not
    //NSRange whiteSpaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    //if (whiteSpaceRange.location != NSNotFound) {
    NSArray *components = [self componentsSeparatedByString:seperationStr];
    NSRange whiteRange = [self rangeOfString:[components objectAtIndex:0]];
    NSRange darkRange = [self rangeOfString:[components objectAtIndex:1]];
    
    [attrString addAttribute: NSForegroundColorAttributeName
                       value:color1
                       range:whiteRange];
    [attrString addAttribute:NSFontAttributeName
                       value:font1
                       range:whiteRange];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:color2
                       range:darkRange];
    
    [attrString addAttribute:NSFontAttributeName
                       value:font2
                       range:darkRange];
    
    
    [attrString endEditing];
    
    return attrString;
    //}
    
    //return attrString;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Matching Two Strings Ignoring Case <<<<<<<<<<<<<<<<<<<<<<<<*/

- (BOOL)matchStringWhileIgnoringCase:(NSString *)string {
    
    if ([self caseInsensitiveCompare:string] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

BOOL matchStringWhileIgnoringCase(NSString *string1, NSString *string2) {
    if ([string1 caseInsensitiveCompare:string2] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (NSString*)ordinalNumberFormat:(NSNumber *)numObj {
    NSString *ending;
    NSInteger num = [numObj integerValue];
    
    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    
    if(tens == 1){
        ending = @"th";
    } else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%ld%@", (long)num, ending];
}

/*>>>>>>>>>>>>>>>>>>>>> Encryption Method <<<<<<<<<<<<<<<<<*/

//- (NSString *)MD5String {
//    const char *cstr = [self UTF8String];
//    unsigned char result[16];
//    CC_MD5(cstr, (int)strlen(cstr), result);
//    
//    return [NSString stringWithFormat:
//            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];
//}

//- (NSString*)MD5String
//{
//    // Create pointer to the string as UTF8
//    //const char *ptr = [self UTF8String];
//    
//    // Create byte array of unsigned chars
//    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
//    
//    // Create 16 byte MD5 hash value, store in buffer
//   // CC_MD5(ptr, (long)strlen(ptr), md5Buffer);
//    
//    // Convert MD5 value in the buffer to NSString of hex values
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
//        [output appendFormat:@"%02x",md5Buffer[i]];
//    
//    return output;
//}

@end
