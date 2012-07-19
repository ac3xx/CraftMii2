//
//  MCSlot.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 25/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCSlot.h"
#import "MCSocket.h"
#import "MCNBT.h"
#import "NSData+UserAdditions.h"
#import "MCItem.h"

const NSString* MCEnchantmentLevelMatrix[] = 
{
    @"",
    @"I",
    @"II",
    @"III",
    @"IV",
    @"V",
    @"VI",
    @"VII",
    @"VIII",
    @"IX",
    @"X"
};

const NSString* MCEnchantmentMatrix[] =
{
    @"Protection",
    @"Fire Protection",
    @"Feather Falling",
    @"Blast Protection",
    @"Projectile Protection",
    @"Respiration",
    @"Aqua Affinity",
    @"Unknown Enchantment 7",
    @"Unknown Enchantment 8",
    @"Unknown Enchantment 9",
    @"Unknown Enchantment 10",
    @"Unknown Enchantment 11",
    @"Unknown Enchantment 12",
    @"Unknown Enchantment 13",
    @"Unknown Enchantment 14",
    @"Unknown Enchantment 15",
    @"Sharpness",
    @"Smite",
    @"Bane of Arthropods",
    @"Knockback",
    @"Fire Aspect",
    @"Looting",
    @"Unknown Enchantment 22",
    @"Unknown Enchantment 23",
    @"Unknown Enchantment 24",
    @"Unknown Enchantment 25",
    @"Unknown Enchantment 26",
    @"Unknown Enchantment 27",
    @"Unknown Enchantment 28",
    @"Unknown Enchantment 29",
    @"Unknown Enchantment 30",
    @"Unknown Enchantment 31",
    @"Efficiency",
    @"Silk Touch",
    @"Unbreaking",
    @"Fortune",
    @"Unknown Enchantment 36",
    @"Unknown Enchantment 37",
    @"Unknown Enchantment 38",
    @"Unknown Enchantment 39",
    @"Unknown Enchantment 40",
    @"Unknown Enchantment 41",
    @"Unknown Enchantment 42",
    @"Unknown Enchantment 43",
    @"Unknown Enchantment 44",
    @"Unknown Enchantment 45",
    @"Unknown Enchantment 46",
    @"Unknown Enchantment 47",
    @"Power",
    @"Punch",
    @"Flame",
    @"Infinity",
    @"Unknown Enchantment 52",
    @"Unknown Enchantment 53",
    @"Unknown Enchantment 54",
    @"Unknown Enchantment 55",
    @"Unknown Enchantment 56",
    @"Unknown Enchantment 57",
    @"Unknown Enchantment 58",
    @"Unknown Enchantment 59",
    @"Unknown Enchantment 60",
    @"Unknown Enchantment 61",
    @"Unknown Enchantment 62",
    @"Unknown Enchantment 63"
};


const NSString* MCEnchantmentLevelName(MCEnchantmentLevel ench)
{
    if (ench > 10) {
        return [NSString stringWithFormat:@"%u", ench];
    }
    return MCEnchantmentLevelMatrix[ench];
}
const NSString* MCEnchantmentName(MCEnchantment ench)
{
    if (ench >= MCInternalEnchantmentEnd) {
        return @"Invalid Enchantment";
    }
    return MCEnchantmentMatrix[ench];
}

#define canEnchant(value) (getItem(value,0).enchantable)

@implementation MCSlot
@synthesize window,socket,oldDelegate,index,slotData;
+(MCSlot*)slotWithWindow:(MCWindow *)awindow atPosition:(short)aindex withSocket:(MCSocket*)asocket
{
    MCSlot* ret=(MCSlot*)[NSNull null];
    if ([[awindow items] count] > aindex)
        ret=[[awindow items] objectAtIndex:aindex];
    if (ret == (MCSlot*)[NSNull null])
    {
        ret = [MCSlot new];
        [ret setWindow:awindow];
        [ret setIndex:aindex];
        if ([[awindow items] count] > aindex)
            [[awindow items] removeObjectAtIndex:aindex];
        [[awindow items] insertObject:ret atIndex:aindex];
    }
    [ret setSocket:asocket];
    [ret setOldDelegate:[[asocket inputStream] delegate]];
    [[asocket inputStream] setDelegate:ret];
    return [ret retain];
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if (!buffer) {
        buffer = [NSMutableData new];
    }
    if (!slotData) {
        [self setSlotData:[NSMutableDictionary new]];
    }
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            ;;
            unsigned char byte;
            [(NSInputStream *)theStream read:&byte maxLength:1];
            [buffer appendBytes:&byte length:1];
            const unsigned char* data = [buffer bytes];
            if ([buffer length] >= 2) {
                [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data))] forKey:@"ID"];
                if (*(short*)(data)==(short)-1) {
                    [slotData setObject:[NSNumber numberWithChar:0] forKey:@"Count"];
                    [slotData setObject:[NSNumber numberWithShort:0] forKey:@"Damage"];
                    [slotData removeObjectForKey:@"EnchantmentData"];
                    goto end;
                } else if ([buffer length] >= 5){
                    if (canEnchant(OSSwapInt16(*(short*)(data))) ) {
                        short len = OSSwapInt16(*(short*)(data+5));
                        if (len == -1)
                        {
                            [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                            [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                            [slotData removeObjectForKey:@"EnchantmentData"];
                            goto end;
                        }
                        if ([buffer length] == 7+len)
                        {
                            [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                            [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                            [slotData setObject:[MCNBT NBTWithData:[NSData dataWithBytes:(char*)(data+7) length:len]] forKey:@"EnchantmentData"];
                            goto end;
                        }
                    } else {
                        [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                        [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                        [slotData removeObjectForKey:@"EnchantmentData"];
                        goto end;
                    }
                }
            }
            break;
        default:
            break;
    }
    return;
end:
    [[self socket] slot:self hasFinishedParsing:slotData];
    [theStream setDelegate:oldDelegate];
    [buffer release];
    buffer=nil;
    [self setOldDelegate:nil];
    [self autorelease];
    return;
}
-(void)dealloc
{
    NSLog(@"Out!");
    [self setSlotData:nil];
    [super dealloc];
}
@end
