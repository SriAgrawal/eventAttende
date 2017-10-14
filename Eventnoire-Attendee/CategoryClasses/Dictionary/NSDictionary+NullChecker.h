
#import <Foundation/Foundation.h>

@interface NSDictionary (NullChecker)

-(id)objectForKeyNotNull:(id)object expectedObj:(id)obj;
-(id)objectForKeyNotNull:(id)key;

+(id)dictionaryWithContentsOfJSONURLData:(NSData *)JSONData;
-(NSData*)toJSON;

@end
