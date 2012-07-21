//
//  MCLoginPacket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSendPacket.h"
#import "NSString+Minecraft.h"

@interface MCLoginPacket : MCSendPacket
{
    int version;
}
@property(assign) int version;
+(MCLoginPacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
