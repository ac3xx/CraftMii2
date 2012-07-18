//
//  MCHandshakePacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCHandshakePacket.h"
#import "MCString.h"
#import "MCBuffer.h"
@implementation MCHandshakePacket
+(MCHandshakePacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCHandshakePacket* ret = [MCHandshakePacket new];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0x02];
#ifndef __MC_SMP_13
    m_char_t* text=[MCString MCStringFromString:[NSString stringWithFormat:@"%@;%@", [[socket auth] username], [socket server], nil]];
    [[socket outputBuffer] write:(uint8_t*)text length:m_char_t_sizeof(text)];
#else
    m_char_t* text=[MCString MCStringFromString:[[socket auth] username]];
    char version = (char) [socket version];
    NSArray* pieces = [[socket server] componentsSeparatedByString:@":"];
    NSString* target = @"";
    int port = 25565;
    if ([pieces count] == 1) {
        target = [pieces objectAtIndex:0];
    }
    else if ([pieces count] > 1) {
        target = [pieces objectAtIndex:0];
        port = [[pieces objectAtIndex:1] intValue];
    }
    port = OSSwapInt32(port);
    m_char_t* textt=[MCString MCStringFromString:target];
    [[socket outputBuffer] writeByte:version];
    [[socket outputBuffer] write:(uint8_t*)text length:m_char_t_sizeof(text)];
    [[socket outputBuffer] write:(uint8_t*)textt length:m_char_t_sizeof(textt)];
    [[socket outputBuffer] write:(uint8_t*)&port length:4];
    free(textt);
#endif
    free(text);
}
-(void)dealloc
{
    [super dealloc];
}

@end
