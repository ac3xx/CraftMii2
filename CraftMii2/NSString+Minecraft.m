//
//  NSString+Minecraft.m
//  CraftMii2
//
//  Created by qwertyoruiop on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Minecraft.h"
#import <CoreText/CoreText.h>
#import "MCColor.h"
@implementation NSString (Minecraft)
+(NSString*) stringWithMinecraftString:(m_char_t*)string
{
    if (!(string&&OSSwapInt16(string->len))) {
        return nil;
    }
    NSData* data = [[NSData alloc] initWithBytes:string->data length:OSSwapInt16(string->len)*2];
    id ret = [[NSString alloc] initWithData:data encoding:NSUTF16BigEndianStringEncoding];
    [data release];
    return [ret autorelease];
}
-(m_char_t*) minecraftString
{
    m_char_t* ret = (m_char_t*)malloc(sizeof(short) + [self lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    memcpy(ret->data, [self cStringUsingEncoding:NSUTF16BigEndianStringEncoding], [self lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    ret->len = OSSwapInt16([self length]);
    return ret;
}
-(NSAttributedString*) attributedString
{
    NSString* stringWithDefaultColor = [@"\u00A7f" stringByAppendingString:self];
    NSArray* pieces = [stringWithDefaultColor componentsSeparatedByString:@"\u00a7"];
    NSMutableAttributedString* rt = [[NSMutableAttributedString alloc] init];
    for (NSString* piece in pieces) {
        if ([piece length] > 1) {
            [rt appendAttributedString:[[[NSAttributedString alloc] initWithString:[piece substringFromIndex:1] attributes:[NSDictionary dictionaryWithObjectsAndKeys:(id)[[UIColor colorWithCode:*[[piece substringToIndex:1] UTF8String]] CGColor], (NSString*)kCTForegroundColorAttributeName,nil]] autorelease]];
        }
    }
    return (NSAttributedString*) [rt autorelease];
}
@end
