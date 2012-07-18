//
//  MCSlot.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 25/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCWindow.h"
#import "MCSocket.h"

typedef unsigned int MCEnchantmentLevel;

typedef enum MCEnchantment
{
    /*
     Armor Enchantments
     */
    MCEnchantmentProtection             = 0,
    MCEnchantmentFireProtection         = 1,
    MCEnchantmentFeatherFalling         = 2,
    MCEnchantmentBlastProtection        = 3,
    MCEnchantmentProjectileProtection   = 4,
    MCEnchantmentRespiration            = 5,
    MCEnchantmentAquaAffinity           = 6,
    MCInvalidEnchantment7               = 7,
    MCInvalidEnchantment8               = 8,
    MCInvalidEnchantment9               = 9,
    MCInvalidEnchantment10              = 10,
    MCInvalidEnchantment11              = 11,
    MCInvalidEnchantment12              = 12,
    MCInvalidEnchantment13              = 13,
    MCInvalidEnchantment14              = 14,
    MCInvalidEnchantment15              = 15,
    /*
     Sword Enchantments
     */
    MCEnchantmentSharpness              = 16,
    MCEnchantmentSmite                  = 17,
    MCEnchantmentBaneOfArthropods       = 18,
    MCEnchantmentKnockback              = 19,
    MCEnchantmentFireAspect             = 20,
    MCEnchantmentLooting                = 21,
    MCInvalidEnchantment22              = 22,
    MCInvalidEnchantment23              = 23,
    MCInvalidEnchantment24              = 24,
    MCInvalidEnchantment25              = 25,
    MCInvalidEnchantment26              = 26,
    MCInvalidEnchantment27              = 27,
    MCInvalidEnchantment28              = 28,
    MCInvalidEnchantment29              = 29,
    MCInvalidEnchantment30              = 30,
    MCInvalidEnchantment31              = 31,
    /*
     Tool Enchantments
     */
    MCEnchantmentEfficiency             = 32,
    MCEnchantmentSilkTouch              = 33,
    MCEnchantmentUnbreaking             = 34,
    MCEnchantmentFortune                = 35,
    MCInvalidEnchantment36              = 36,
    MCInvalidEnchantment37              = 37,
    MCInvalidEnchantment38              = 38,
    MCInvalidEnchantment39              = 39,
    MCInvalidEnchantment40              = 40,
    MCInvalidEnchantment41              = 41,
    MCInvalidEnchantment42              = 42,
    MCInvalidEnchantment43              = 43,
    MCInvalidEnchantment44              = 44,
    MCInvalidEnchantment45              = 45,
    MCInvalidEnchantment46              = 46,
    MCInvalidEnchantment47              = 47,
    /*
     Bow Enchantments
     */
    MCEnchantmentPower                  = 48,
    MCEnchantmentPunch                  = 49,
    MCEnchantmentFlame                  = 50,
    MCEnchantmentInfinity               = 51,
    MCInvalidEnchantment52              = 52,
    MCInvalidEnchantment53              = 53,
    MCInvalidEnchantment54              = 54,
    MCInvalidEnchantment55              = 55,
    MCInvalidEnchantment56              = 56,
    MCInvalidEnchantment57              = 57,
    MCInvalidEnchantment58              = 58,
    MCInvalidEnchantment59              = 59,
    MCInvalidEnchantment60              = 60,
    MCInvalidEnchantment61              = 61,
    MCInvalidEnchantment62              = 62,
    MCInvalidEnchantment63              = 63,
    /*
     Internal Values
     */
    MCInternalEnchantmentEnd            = 64
} MCEnchantment;

extern const NSString* MCEnchantmentLevelName(MCEnchantmentLevel ench);
extern const NSString* MCEnchantmentName(MCEnchantment ench);

@interface MCSlot : NSObject <NSStreamDelegate>
{
    MCWindow* window;
    int index;
    MCSocket* socket;
    id oldDelegate;
    NSMutableData* buffer;
    NSMutableDictionary* slotData;
}
@property(retain) MCWindow* window;
@property(assign) int index;
@property(retain) MCSocket* socket;
@property(retain) NSMutableDictionary* slotData;
@property(assign) id oldDelegate;
+(MCSlot*)slotWithWindow:(MCWindow*)awindow atPosition:(short)aindex withSocket:(MCSocket*)asocket;
@end
