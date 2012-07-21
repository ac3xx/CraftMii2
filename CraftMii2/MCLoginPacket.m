//
//  MCLoginPacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCLoginPacket.h"
#import "MCBuffer.h"
#ifndef __MC_SMP_13
#endif
@implementation MCLoginPacket
#ifndef __MC_SMP_13
@synthesize version;
#endif
+(MCLoginPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCLoginPacket* ret = [MCLoginPacket new];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0x01];
    version = OSSwapInt32([socket version]);
    m_char_t* __name_msg= [[[socket auth] username] minecraftString];
    [[socket outputBuffer] write:(uint8_t*)&version length:4];
    [[socket outputBuffer] write:(uint8_t*)__name_msg length:m_char_t_sizeof(__name_msg)];
    [[socket outputBuffer] writeZeroes:13];
    free(__name_msg);
}
-(void)dealloc
{
    [super dealloc];
}
@end
