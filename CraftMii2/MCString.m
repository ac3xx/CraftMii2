//
//  NSString+javaString.m
//  Minecraft
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//


#import "MCString.h"
#import "MCColor.h"
#include <iconv.h>

@implementation MCString
+(m_char_t*)MCStringFromString:(NSString*)str
{
    m_char_t* ret = (m_char_t*)malloc(sizeof(short) + [str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    memcpy(ret->data, [str cStringUsingEncoding:NSUTF16BigEndianStringEncoding], [str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    ret->len = flipshort([str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]/2);
    return ret;
}
+(NSString*)NSStringWithMinecraftString:(m_char_t*)string
{
    if (!(string&&flipshort(string->len))) {
        return nil;
    }
    NSData* data = [[NSData alloc] initWithBytes:string->data length:flipshort(string->len)*2];
    id ret = [[NSString alloc] initWithData:data encoding:NSUTF16BigEndianStringEncoding];
    [data release];
    return [ret autorelease];
}
+(NSString*)NSStringWithNBTString:(n_char_t*)string
{
    NSData* data = [[NSData alloc] initWithBytes:string->data length:flipshort(string->len)*2];
    id ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [data release];
    return [ret autorelease];
}
+(NSArray*)createColorandTextPairsForMinecraftFormattedString:(NSString*)string
{
    NSString* stringWithDefaultColor = [@"\u00A7f" stringByAppendingString:string];
    NSArray* pieces = [stringWithDefaultColor componentsSeparatedByString:@"\u00a7"];
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:[pieces count]];
    for(NSString* piece in pieces)
    {
        @try {
            [ret addObject:[NSArray arrayWithObjects:[MCColor colorWithCode:[piece characterAtIndex:0]], [piece substringFromIndex:1], nil]];
        }
        @catch (NSException *exception) {
        }
    }
    return [ret autorelease];
}
@end
