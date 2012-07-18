//
//  MCRespawn.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 12/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCRespawnPacket.h"
#import "MCBuffer.h"

@implementation MCRespawnPacket
+(MCSendPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCRespawnPacket* ret = [MCRespawnPacket new];
    return (MCSendPacket*)[ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0x09];
    [[socket outputBuffer] writeZeroes:10];
}
@end
