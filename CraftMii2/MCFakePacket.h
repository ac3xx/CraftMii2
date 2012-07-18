//
//  NSFakePacket.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 30/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSocket;
@interface MCFakePacket : NSObject
{
    MCSocket* sock;
    unsigned char identifier;
    NSMutableData* buffer;
}
@property(retain) MCSocket* sock;
@property(assign) unsigned char identifier;
@property(retain) NSMutableData* buffer;
+(MCFakePacket*)fakePacketWithSocket:(MCSocket*)esocket andIdentifier:(unsigned char)eid;
@end
