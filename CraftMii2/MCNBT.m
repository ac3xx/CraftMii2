//
//  MCNBT.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

/*
 MCNBT is part of the CraftMii project.
*/

#import "MCNBT.h"
#import "NSData+UserAdditions.h"
#import <objc/runtime.h>

char gzip_signature[] = {0x1F, 0x8B, 0x08};
NSString* kNBTError = @"kNBTError";
typedef enum MCNBTTag
{
MCNBTTagEnd         = 0,
MCNBTTagByte        = 1,
MCNBTTagShort       = 2,
MCNBTTagInt         = 3,
MCNBTTagLong        = 4,
MCNBTTagFloat       = 5,
MCNBTTagDouble      = 6,
MCNBTTagByteArray   = 7,
MCNBTTagString      = 8,
MCNBTTagList        = 9,
MCNBTTagCompound    = 10,
MCNBTTagIntArray    = 11
} MCNBTTag;

typedef union MCType32
{
float f;
int i;
} MCType32;

typedef union MCType64
{
double d;
long long l;
} MCType64;

@implementation MCNBT

+(id)NBTParseObjectForTag:(MCNBTTag)tag andData:(const unsigned char**)datap setNode:(id*)node andDepth:(int*)depth
{
    switch (tag) {
        case MCNBTTagList:
        {
            MCNBTTag oTags = **datap;
            int objects  = OSSwapInt32(*(int*)((*datap)+1));
            NSMutableArray* newArray = [[NSMutableArray alloc] initWithCapacity:objects];
            (*datap) += 5;
            while (objects--) {
                [newArray addObject:[self NBTParseObjectForTag:oTags andData:datap setNode:node andDepth:depth]];
            }
            return [newArray autorelease];
            break;
        }
        case MCNBTTagByte:
        {
            NSNumber* ret = [NSNumber numberWithChar:**datap];
            (*datap) += 1;
            return ret;
            break;
        }
        case MCNBTTagShort:
        {
            NSNumber* ret = [NSNumber numberWithShort:OSSwapInt16(*(short*)(*datap))];
            (*datap) += 2;
            return ret;
            break;
        }
        case MCNBTTagInt:
        {
            NSNumber* ret = [NSNumber numberWithInt:OSSwapInt32(*(int*)(*datap))];
            (*datap) += 4;
            return ret;
            break;
        }
        case MCNBTTagLong:
        {
            NSNumber* ret = [NSNumber numberWithLongLong:OSSwapInt64(*(long long*)(*datap))];
            (*datap) += 8;
            return ret;
            break;
        }
        case MCNBTTagFloat:
        {
            MCType32 f;
            f.i = OSSwapInt32(*(int*)(*datap));
            NSNumber* ret = [NSNumber numberWithFloat:f.f];
            (*datap) += 4;
            return ret;
            break;
        }
        case MCNBTTagDouble:
        {
            MCType64 f;
            f.l = OSSwapInt64(*(long long*)(*datap));
            NSNumber* ret = [NSNumber numberWithFloat:f.d];
            (*datap) += 8;
            return ret;
            break;
        }
        case MCNBTTagByteArray:
        {
            NSData* ret      = [NSData dataWithBytes:((*datap) + 4) length:OSSwapInt32(*(int*)(*datap))];
            (*datap)        += OSSwapInt32(*(int*)(*datap)) + 4;
            return ret;
            break;
        }
        case MCNBTTagString:
        {
            NSString* ret    = [[[NSString alloc] initWithBytes:((*datap) + 2) length:OSSwapInt16(*(short*)(*datap)) encoding:NSUTF8StringEncoding] autorelease];
            (*datap)        += OSSwapInt16(*(short*)(*datap)) + 2;
            return ret;
            break;
        }
        case MCNBTTagCompound:
        {
            id onode = *node;
            *node = [[NSMutableDictionary new] autorelease];
            objc_setAssociatedObject(*node, "Supernode", onode, OBJC_ASSOCIATION_ASSIGN);
            (*depth)++;
            return *node;
            break;
        }
        case MCNBTTagIntArray:
        {
            int ints = OSSwapInt32(*(int*)(*datap));
            NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:ints];
            *datap += 4;
            while (ints--) {
                [arr addObject:[NSNumber numberWithInt:OSSwapInt32(*(int*)(*datap))]];
                *datap += 4;
            }
            return [arr autorelease];
            break;
        }
        default:
            break;
    }
    return nil;
}

+(NSDictionary*)NBTWithBytes:(const unsigned char*)bytes andLen:(int)len
{
    const unsigned char* obytes = bytes;
    int depth = 0;
    id node = [[[NSMutableDictionary alloc] init] autorelease];
    while (bytes!=(obytes+len)) {
        MCNBTTag tag = *bytes++;
        switch (tag) {
            case MCNBTTagEnd:
            {
                depth--;
                node = objc_getAssociatedObject(node, "Supernode");
                if (depth <= 0) {
                    return node;
                }
                break;
            }
            case MCNBTTagByte:
            case MCNBTTagShort:
            case MCNBTTagInt:
            case MCNBTTagLong:
            case MCNBTTagFloat:
            case MCNBTTagDouble:
            case MCNBTTagByteArray:
            case MCNBTTagString:
            case MCNBTTagList:
            case MCNBTTagIntArray:
            case MCNBTTagCompound:
            {
                short namelen  = OSSwapInt16(*(short*)(bytes));
                NSString* name = [[[NSString alloc] initWithBytes:(bytes+2) length:namelen encoding:NSUTF8StringEncoding] autorelease];
                bytes += 2 + namelen;
                NSMutableDictionary* dct = node;
                [dct setObject:[self NBTParseObjectForTag:tag andData:&bytes setNode:&node andDepth:&depth] forKey:name];
                break;
            }
            default:
                NSLog(@"Unknown NBT tag.");
                return (NSDictionary*)kNBTError;
                break;
        }
    }
    return node;
}

+(NSDictionary*)NBTWithRawData:(NSData*)data
{
    return [self NBTWithBytes:[data bytes] andLen:[data length]];
}

+(NSDictionary*)NBTWithData:(NSData*)data
{
    if (memcmp([data bytes], gzip_signature, 3) == 0)
	{
		data = [data gzipInflate];
	}
    return [self NBTWithRawData:data];
}
@end
