//
//  MCChatPacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCChatPacket.h"
#import "MCBuffer.h"
#import "NSString+Minecraft.h"
@implementation MCChatPacket
@synthesize message;
+(MCChatPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCChatPacket* ret = [[MCChatPacket new] autorelease];
    NSString* msg = [infoDict objectForKey:@"Message"];
    if (!msg) return nil;
    if ([msg isEqualToString:@""]) return nil;
    [ret setMessage:msg];
    return ret;
}
-(void)sendToSocket:(MCSocket *)socket
{
    m_char_t* text=[[self message] minecraftString];
    [[socket outputBuffer] writeByte:0x03];
    [[socket outputBuffer] write:(uint8_t*)text length:m_char_t_sizeof(text)];
    free(text);
}
-(void)dealloc
{
    [self setMessage:nil];
    [super dealloc];
}
@end
