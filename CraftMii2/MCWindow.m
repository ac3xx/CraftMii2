//
//  MCWindow.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 25/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCWindow.h"

@implementation MCWindow
@synthesize wid, items, type, title, size;
+(MCWindow*)windowWithID:(unsigned char)identifier
{
    static NSMutableDictionary* windowPool;
    if (!windowPool) {
        windowPool=[NSMutableDictionary new];
    }
    NSNumber* nseid = [NSNumber numberWithUnsignedChar:identifier];
    MCWindow* window = [windowPool objectForKey:nseid];
    if (window) {
        return window;
    }
    window = [MCWindow new];
    [window setWid:identifier];
    [window setItems:[NSMutableArray new]];
    [windowPool setObject:window forKey:nseid];
    return [window autorelease];
}
@end
