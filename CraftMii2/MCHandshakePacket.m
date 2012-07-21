//
//  MCHandshakePacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCHandshakePacket.h"
#import "MCBuffer.h"
#import "NSString+Minecraft.h"
@implementation MCHandshakePacket
+(MCHandshakePacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCHandshakePacket* ret = [MCHandshakePacket new];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0x02];
    m_char_t* text=[[NSString stringWithFormat:@"%@;%@", [[socket auth] username], [socket server], nil] minecraftString];
    [[socket outputBuffer] write:(uint8_t*)text length:m_char_t_sizeof(text)];
    free(text);
}
-(void)dealloc
{
    [super dealloc];
}

@end
