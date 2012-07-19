//
//  NSFakePacket.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 30/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCFakePacket.h"

@implementation MCFakePacket
@synthesize sock, identifier, buffer;
+(MCFakePacket*)fakePacketWithSocket:(MCSocket *)esocket andIdentifier:(unsigned char)eid
{
    id ret = [self new];
    [ret setSock:esocket];
    [ret setIdentifier:eid];
    [ret setBuffer:nil];
    return [ret autorelease];
}
- (oneway void)dealloc
{
    NSLog(@"kthx");
    [self setSock:nil];
    [super dealloc];
}

@end
