//
//  MCWindow.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 25/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCWindow.h"
static NSMutableDictionary* windowPool=nil;

@implementation MCWindow
@synthesize wid, items, type, title, size;
+(MCWindow*)windowWithID:(unsigned char)identifier
{
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
    [window setItems:[[NSMutableArray new] autorelease]];
    [windowPool setObject:window forKey:nseid];
    return [window autorelease];
}
-(void)dealloc
{
    [windowPool removeObjectForKey:[NSNumber numberWithUnsignedInt:wid]];
    [self setItems:nil];
    [self setTitle:nil];
    [super dealloc];
}
@end
