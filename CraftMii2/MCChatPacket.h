//
//  MCChatPacket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSendPacket.h"
#import "MCString.h"

@interface MCChatPacket : MCSendPacket
{
    NSString* message;
}
@property(retain) NSString* message;
+(MCChatPacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
