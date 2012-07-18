//
//  MCChatPacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCChatPacket.h"
#import "MCString.h"
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
    m_char_t* text=[MCString MCStringFromString:[self message]];
    unsigned char pckid=0x02;
    [[socket outputStream] write:(uint8_t*)&pckid   maxLength:1];
    [[socket outputStream] write:(uint8_t*)text     maxLength:m_char_t_sizeof(text)];
    free(text);
}
-(void)dealloc
{
    [self setMessage:nil];
    [super dealloc];
}
@end
