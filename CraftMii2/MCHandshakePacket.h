//
//  MCHandshakePacket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCSendPacket.h"

@interface MCHandshakePacket : MCSendPacket
{
}
+(MCHandshakePacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
