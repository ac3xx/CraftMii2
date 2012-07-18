//
//  MCPingPacket.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCSendPacket.h"

@interface MCPingPacket : MCSendPacket
{
    unsigned int eid;
}
@property(assign) unsigned int eid;
+(MCPingPacket*)packetWithInfo:(NSDictionary *)infoDict;
-(void)sendToSocket:(MCSocket *)socket;
@end
