//
//  MCEncryptionResponse.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 07/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCSendPacket.h"

@interface MCEncryptionResponse : MCSendPacket
{
    NSData* data;
}
@property(retain) NSData* data;
+(MCEncryptionResponse*)packetWithInfo:(NSDictionary *)infoDict;
-(void)sendToSocket:(MCSocket *)socket;
@end
