//
//  MCWindow.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 25/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MCWindowType_e {
    kTypeChest = 0,
    kTypeWorkbench = 1,
    kTypeFurnace = 2,
    kTypeDispenser = 3,
    kTypeEnchantment = 4
} MCWindowType;
@interface MCWindow : NSObject
{
    unsigned char wid;
    unsigned char size;
    NSMutableArray* items;
    NSString* title;
    MCWindowType type;
}
@property(assign) unsigned char wid;
@property(retain) NSMutableArray* items;
@property(retain) NSString* title;
@property(assign) MCWindowType type;
@property(assign) unsigned char size;
+(MCWindow*)windowWithID:(unsigned char)identifier;
@end
