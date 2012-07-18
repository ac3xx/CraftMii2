//
//  NSString+javaString.h
//  Minecraft
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#define Endian16_Swap(value) (UInt16) (__builtin_constant_p(value) ? OSSwapConstInt16(value) : OSSwapInt16(value))
#define Endian32_Swap(value) (UInt32) (__builtin_constant_p(value) ? OSSwapConstInt32(value) : OSSwapInt32(value))
#define Endian64_Swap(value) (UInt64) (__builtin_constant_p(value) ? OSSwapConstInt64(value) : OSSwapInt64(value))
#define flipshort(x) Endian16_Swap(x)
#define m_char_t_sizeof(x) (flipshort(x->len)*2+sizeof(x->len))
typedef struct m_char
{
    short len;
    char data[];
} m_char_t;
typedef struct n_char
{
    short len;
    char data[];
} n_char_t;

@interface MCString : NSObject
{
    
}
+(m_char_t*)MCStringFromString:(NSString*)str;
+(NSString*)NSStringWithMinecraftString:(m_char_t*)string;
+(NSArray*)createColorandTextPairsForMinecraftFormattedString:(NSString*)string;
+(NSString*)NSStringWithNBTString:(n_char_t*)string;
@end
