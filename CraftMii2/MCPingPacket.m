//
//  MCPingPacket.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPingPacket.h"
#import "MCBuffer.h"
@implementation MCPingPacket
@synthesize eid;
+(MCPingPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    NSNumber* eidl = [infoDict objectForKey:@"PingID"];
    if (!eidl) 
        return nil;
    MCPingPacket* ret = [MCPingPacket new];
    [ret setEid:OSSwapInt32([eidl unsignedIntValue])];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0];
    [[socket outputBuffer] write:(uint8_t*)&eid length:4];
}
-(void)dealloc
{
    [super dealloc];
}

@end
