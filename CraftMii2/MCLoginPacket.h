//
//  MCLoginPacket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSendPacket.h"
#import "MCString.h"

@interface MCLoginPacket : MCSendPacket
{
#ifndef __MC_SMP_13
    int version;
}
@property(assign) int version;
#else
}
#endif
+(MCLoginPacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
