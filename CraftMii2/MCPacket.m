//
//  MCPacket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPacket.h"
#import "MCSocket.h"
#import "MCString.h"
#import "MCMetadata.h"
#import "MCSlot.h"
#import "MCWindow.h"
#import "MCLoginPacket.h"
#import "MCPingPacket.h"
#import "MCEncryptionResponse.h"
#import "NSData+UserAdditions.h"
@implementation MCPacket
@synthesize sock,identifier,buffer;
+(MCPacket*)packetWithID:(unsigned char)idt andSocket:(MCSocket*)sock
{
    MCPacket* kret=[MCPacket new];
    [kret setIdentifier:idt];
    [kret setSock:sock];
    [kret setBuffer:nil];
    [kret preload];
    [[sock inputStream] setDelegate:kret];
    return kret;
}
- (id)init
{
    self = [super init];
    cachedoffset = -1;
    cachedoffset1 = -1;
    cachedoffset2 = -1;
    cachedoffset3 = -1;
    cached_bflen = 0;
    bytestoread = 1;
    return self;
}
- (void)preload
{
    /*
     With Read buffering, this is not needed anymore, but may still save up some CPU cycles!
     */
    switch (identifier) {
        case 0x01:
#ifndef __MC_SMP_13
            bytestoread = 19;
#else
            bytestoread = 11;
#endif
#ifndef __MC_SMP_13
        case 0x02:
#endif
        case 0x46:
            bytestoread = 2;
            break;
#ifdef __MC_SMP_13
        case 0x02:
            bytestoread = 9;
            break;
#endif
        case 0x1D:
        case 0x1E:
        case 0x63:
        case 0xCA:
        case 0x64:
        case 0x00:
#ifdef __MC_SMP_13
        case 0xFD:
#endif
        case 0x28:
            bytestoread = 4;
            break;
        case 0x1F:
            bytestoread = 7;
            break;
        case 0x66:
            bytestoread = 7;
            break;
        case 0x20:
            bytestoread = 6;
            break;
        case 0x32:
        case 0x21:
            bytestoread = 9;
            break;
        case 0x16:
        case 0x08:
        case 0x27:
        case 0x2B:
        case 0x29:
        case 0x04:
            bytestoread = 8;
            break;
        case 0x05:
        case 0x09:
        case 0x1C:
            bytestoread = 10;
            break;
        case 0x06:
        case 0x36:
            bytestoread = 12;
            break;
        case 0x11:
        case 0x34:
            bytestoread = 14;
            break;
        case 0x26:
        case 0x23:
        case 0x2A:
        case 0x69:
        case 0x83:
        case 0xC9:
        case 0xC8:
        case 0x12:
            bytestoread = 5;
            break;
        case 0x14:
        case 0x19:
            bytestoread = 22;
            break;
        case 0x3C:
            bytestoread = 32;
            break;
        case 0x84:
            bytestoread = 23;
            break;
        case 0x35:
            bytestoread = 11;
            break;
        case 0x82:
            bytestoread = 10;
            break;
        case 0x17:
        case 0x33:
            bytestoread = 21;
            break;
        case 0x18:
            bytestoread = 20;
            break;
        case 0x15:
            bytestoread = 24;
            break;
        case 0x22:
        case 0x1A:
            bytestoread = 18;
            break;
        case 0x0D:
            bytestoread = 41;
            break;
        case 0x3D:
        case 0x47:
            bytestoread = 17;
            break;
        default:
            break;
    }
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    if (!data) {
        data=[sock dataBuffer];
    }
	switch (streamEvent) {
		case NSStreamEventHasBytesAvailable:
        {
            unsigned char byte = 0;
            if (bytestoread)
            {
                int rly_read_bytes=[(NSInputStream *)theStream read:(uint8_t*)(data + cached_bflen) maxLength:bytestoread];
                if (rly_read_bytes == -1) {
                    return;
                }
                byte = *(data + cached_bflen);
                cached_bflen+=rly_read_bytes;
                if (rly_read_bytes<bytestoread) {
                    bytestoread = bytestoread - rly_read_bytes;
                    return;
                }
            }
            bytestoread = 1;
            switch (identifier) {
#ifndef __MC_SMP_13
                case 0x02:
                    if (cached_bflen>=2) {
                        
                        if (cachedoffset==-1) {
                            cachedoffset = (flipshort(*(short*)data));
                        }
                        if (cached_bflen == cachedoffset * 2 + 2)
                        {
                            NSString* kdata=[MCString NSStringWithMinecraftString:(m_char_t*)data];
                            NSString* result = @"Unknown";
                            NSString* error = @"";
                            NSString* ekey = @"";
                            if(![[[self sock] auth] joinToServer:kdata])
                            {
                                NSLog(@"A wild error! <%@>", [[[[self sock] auth] login] objectForKey:kMCAuthResult]);
                                error = [[[[self sock] auth] login] objectForKey:kMCAuthResult];
                                result = @"Error";
                                ekey = @"ErrorCode";
                                [[self sock] disconnectWithReason:[[[[self sock] auth] login] objectForKey:kMCAuthResult]];
                            } else {
                                [[MCLoginPacket packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithInt:29], @"Version", nil]] sendToSocket:[self sock]];
                                result = @"Success";
                                error = kdata;
                                ekey = @"ServerHash";
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Handshake", @"PacketType",
                                                      result, @"Result",
                                                      error, ekey,
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
                    break;
#else
                case 0xFD:
                    if (cached_bflen>=4) {
                        if (cachedoffset==-1) {
                            cachedoffset = (flipshort(*(short*)data)) * 2 + 2;
                            bytestoread = cachedoffset - 2;
                        }
                        if (cached_bflen >= cachedoffset + 2)
                        {
                            if (cachedoffset1==-1) {
                                cachedoffset1 = (flipshort(*(short*)(data + cachedoffset)));
                                NSLog(@"len is 0x%02X", cachedoffset1);
                                bytestoread = cachedoffset1;
                            }
                            if (cached_bflen == cachedoffset1 + cachedoffset + 2)
                            {
                                NSString* sid = [MCString NSStringWithMinecraftString:(m_char_t*)data];
                                NSData* pubKey = [NSData dataWithBytes:((char*)(data + cachedoffset + 2))  length:cachedoffset1];
                                [[MCLoginPacket packetWithInfo:nil] sendToSocket:[self sock]];
                                unsigned char* ssecret = malloc(16);
                                for(int p = 0; p != 16; p++)
                                {
                                    *(ssecret + p) = arc4random() % 0xFF;
                                }
                                NSData* sharedsecret = [NSData dataWithBytesNoCopy:ssecret length:16 freeWhenDone:YES];
                                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"EncryptionKeyRequest", @"PacketType",
                                                          pubKey, @"PubKey",
                                                          sid, @"ServerID",
                                                          sharedsecret, @"SharedSecret",
                                                          nil];
                                NSLog(@"%@", infoDict);
                                NSData* cryptosecret = [sharedsecret encryptWithPublicKey:pubKey];
                                if(![[[self sock] auth] joinToServerWithPubKey:pubKey andSID:sid andSSecret:sharedsecret])
                                {
                                    NSLog(@"A wild error! <%@>", [[[[self sock] auth] login] objectForKey:kMCAuthResult]);
                                }
                                [[MCEncryptionResponse packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       cryptosecret, @"Data", nil]] sendToSocket:[self sock]];
                                [[[self sock] inputStream] setDelegate:[self sock]];
                                [[self sock] packet:self gotParsed:infoDict];
                                [self release];
                                return;
                            }
                        }
                    }
                    break;
#endif
                case 0x01:
#ifndef __MC_SMP_13
                    if (cached_bflen>=8) {
                        
                        if (cachedoffset==-1) {
                            cachedoffset = (flipshort(*(short*)(data+6)));
                            bytestoread = cachedoffset * 2;
                        }
                        if (cached_bflen == (cachedoffset * 2 + 19))
                        {
                            NSLog(@"Connected!");
                            int worldtype=(OSSwapInt32((*(int*)(data+12+cachedoffset*2))));
                            NSString* type = @"Unknown";
                            if (worldtype == -1) {
                                type = @"The Nether";
                            } else if (worldtype == 0) {
                                type = @"Overworld";
                            } else if (worldtype == 1) {
                                type = @"The End";
                            }
                            char difficulty=(*(char*)(data+16+cachedoffset*2));
                            NSString* diff = @"Unknown";
                            switch (difficulty) {
                                case 0:
                                    diff = @"Peaceful";
                                    break;
                                case 1:
                                    diff = @"Easy";
                                    break;
                                case 2:
                                    diff = @"Normal";
                                    break;
                                case 3:
                                    diff = @"Hard";
                                    break;
                                default:
                                    break;
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                      [MCString NSStringWithMinecraftString:(m_char_t*)(data+6)], @"WorldType",
                                                      (OSSwapInt32((*(int*)(data+8+cachedoffset*2)))) == 0 ? @"Survival" : @"Creative", @"GameMode",
                                                      @"Login", @"PacketType",
                                                      type, @"Dimension",
                                                      diff, @"Difficulty",
                                                      [NSNumber numberWithChar:(*(char*)(data+18+cachedoffset*2))], @"MaxPlayers",
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
#else
                    if (cached_bflen >= 11)
                    {
                        if (cachedoffset == -1)
                        {
                            cachedoffset = OSSwapInt16(*(short*)(data+4)) * 2;
                            bytestoread = cachedoffset;
                        }
                        if (cachedoffset + 11 == cached_bflen) {
                            NSLog(@"Connected!");
                            char worldtype = ((*(char*)(data+7+cachedoffset)));
                            NSString* type = @"Unknown";
                            if (worldtype == -1) {
                                type = @"The Nether";
                            } else if (worldtype == 0) {
                                type = @"Overworld";
                            } else if (worldtype == 1) {
                                type = @"The End";
                            }
                            char difficulty=(*(char*)(data+8+cachedoffset));
                            NSString* diff = @"Unknown";
                            switch (difficulty) {
                                case 0:
                                    diff = @"Peaceful";
                                    break;
                                case 1:
                                    diff = @"Easy";
                                    break;
                                case 2:
                                    diff = @"Normal";
                                    break;
                                case 3:
                                    diff = @"Hard";
                                    break;
                                default:
                                    break;
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                      [MCString NSStringWithMinecraftString:(m_char_t*)(data+4)], @"WorldType",
                                                      *(char*)((data+6+cachedoffset)) == 0 ? @"Survival" : @"Creative", @"GameMode",
                                                      @"Login", @"PacketType",
                                                      type, @"Dimension",
                                                      diff, @"Difficulty",
                                                      [NSNumber numberWithChar:(*(char*)(data+10+cachedoffset))], @"MaxPlayers",
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
#endif
                    break;
                case 0xFA:
                    if (cached_bflen>=2) {
                        
                        short len = flipshort(*(short*)data);
                        if (cached_bflen >= (len*2 + 4))
                        {
                            short lenk = flipshort(*(short*)(data+(len*2 + 2)));
                            if (cached_bflen == (len*2 + 2 + lenk + 2))
                            {
                                NSString* channel = [MCString NSStringWithMinecraftString:(m_char_t*)(data)];
                                NSData* kdata = [NSData dataWithBytes:(data+2+len*2+2) length:lenk];
                                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          channel, @"Channel",
                                                          kdata, @"Data",
                                                          @"PluginMessage", @"PacketType",
                                                          nil];
                                [[[self sock] inputStream] setDelegate:[self sock]];
                                [[self sock] packet:self gotParsed:infoDict];
                                [self release];
                            } else if (cached_bflen < (len*2 + 2 + lenk + 2)) {
                                bytestoread = (len*2 + 2 + lenk + 2) - cached_bflen;
                            }
                        } else {
                            bytestoread = (len*2 + 4) - cached_bflen;
                        }
                    }
                    break;
                case 0x06:
                    if (cached_bflen==12) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+8)))], @"Z",
                                                  @"SpawnPosition", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    } else if (cached_bflen < 12)
                        bytestoread = 12 - cached_bflen;
                    else
                        NSLog(@"There's something wrong here..!");
                    break;
                case 0x67:
                    if (cached_bflen==3) {
                        
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"SetSlot", @"PacketType",
                                                  [MCWindow windowWithID:*(char*)(data)], @"Window",
                                                  [MCSlot slotWithWindow:[MCWindow windowWithID:*(char*)(data)] atPosition:(OSSwapInt16((*(short*)(data+1))) == 65535) ? 0 : OSSwapInt16((*(short*)(data+1))) withSocket:[self sock]], @"Slot",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x65:;
                    if (cached_bflen == 1)
                    {
                        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithChar:byte], @"Identifier",
                                                         @"CloseWindow", @"PacketType",
                                                         nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x64:
                    if (cached_bflen>=5) {
                        
                        int cnt = 5+OSSwapInt16(*(short*)(data+2))*2;
                        if (cached_bflen == cnt) {
                            char wid = *(char*)data;
                            char ty = *(char*)(data+1);
                            char cnt = *(char*)(data+cached_bflen-1);
                            NSString* title = [MCString NSStringWithMinecraftString:(m_char_t*)(data+2)];
                            MCWindow* kw=[MCWindow windowWithID:wid];
                            [kw setWid:wid];
                            [kw setType:ty];
                            [kw setSize:cnt];
                            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             kw, @"Window",
                                                             [NSNumber numberWithChar:wid], @"Identifier",
                                                             [NSNumber numberWithChar:ty], @"Type",
                                                             [NSNumber numberWithChar:cnt], @"Count",
                                                             title, @"Title",
                                                             @"OpenWindow", @"PacketType",
                                                             nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                        else if (cached_bflen < cnt)
                            bytestoread = cached_bflen - cnt;
                        else NSLog(@"Something's srsly wrong here!");
                    }
                    break;
                case 0x68:
                    if (cached_bflen==3) {
                        
                        NSNumber *count = [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+1)))];
                        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [MCWindow windowWithID:*(char*)(data)], @"Window",
                                                         count, @"Count",
                                                         @"WindowItems", @"PacketType",
                                                         nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        int elements = [count intValue];
                        MCWindow* wn = [MCWindow windowWithID:*(char*)(data)];
                        int p = [[wn items] count];
                        while (p++ <= elements) {
                            [[wn items] addObject:[NSNull null]];
                        }
                        while (elements--) {
                            [MCSlot slotWithWindow:wn atPosition:elements withSocket:[self sock]];
                        }
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x69:
                    if (cached_bflen==5) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithChar:*(char*)(data)], @"WindowID",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+1)))], @"Property",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+3)))], @"Value",
                                                  @"WindowPropertyUpdate", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x6A:
                    if (cached_bflen==4) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithChar:*(char*)(data)], @"WindowID",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+1)))], @"ActionNumber",
                                                  [NSNumber numberWithBool:*(BOOL*)(data+3)], @"Accepted",
                                                  @"AcceptTransaction", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x6B:
                    if (cached_bflen==2) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [MCSlot slotWithWindow:nil atPosition:0 withSocket:[self sock]], @"ClickedItem",
                                                  [NSNumber numberWithShort:*(short*)data], @"SlotID",
                                                  @"CreativeInventoryAction", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0xCA:
                    if (cached_bflen == 4) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithChar:*(char*)(data)], @"Invulnerability",
                                                  [NSNumber numberWithChar:*(char*)(data+1)], @"IsFlying",
                                                  [NSNumber numberWithChar:*(char*)(data+2)], @"CanFly",
                                                  [NSNumber numberWithChar:*(char*)(data+3)], @"Instabreak",
                                                  @"PlayerAbilities", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x82:
                    
                    if (cached_bflen >= 12) { // Holy fsck.
                        if (cached_bflen == 12  && (short)cachedoffset == -1) {
                            cachedoffset = OSSwapInt16(*(short*)(data+10))*2+2;
                            bytestoread = ( (short)cachedoffset );
                        }
                        if (( cached_bflen == 12+(short)cachedoffset ) && (short)cachedoffset != -1 && (short)cachedoffset1 == -1) {
                            cachedoffset1 = OSSwapInt16(*(short*)(data+10+cachedoffset))*2+2;
                            bytestoread = ( (short)cachedoffset1 );
                        } 
                        if (( cached_bflen == 12+(short)cachedoffset+(short)cachedoffset1 ) && (short)cachedoffset != -1 && (short)cachedoffset1 != -1 && (short)cachedoffset2 == -1) {
                            cachedoffset2 = OSSwapInt16(*(short*)(data+10+cachedoffset+cachedoffset1))*2+2;
                            bytestoread = ( (short)cachedoffset2 );
                        }
                        if (( cached_bflen == 12+(short)cachedoffset+(short)cachedoffset1+(short)cachedoffset2 ) && (short)cachedoffset != -1 && (short)cachedoffset1 != -1 && (short)cachedoffset2 != -1 && (short)cachedoffset3 == -1) {
                            cachedoffset3 = OSSwapInt16(*(short*)(data+10+cachedoffset+cachedoffset1+cachedoffset2))*2+2;
                            bytestoread = ( (short)cachedoffset3-2 );
                        }                                    
                    }
                    if ((cached_bflen == 10+(short)cachedoffset+(short)cachedoffset1+(short)cachedoffset2+(short)cachedoffset3) && (short)cachedoffset != -1 && (short)cachedoffset1 != -1 && (short)cachedoffset2 != -1 && (short)cachedoffset3 != -1) {
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [MCString NSStringWithMinecraftString:(m_char_t*)(data+10)], @"Line1",
                                                  [MCString NSStringWithMinecraftString:(m_char_t*)(data+10+(short)cachedoffset)], @"Line2",
                                                  [MCString NSStringWithMinecraftString:(m_char_t*)(data+10+(short)cachedoffset+(short)cachedoffset1)], @"Line3",
                                                  [MCString NSStringWithMinecraftString:(m_char_t*)(data+10+(short)cachedoffset+(short)cachedoffset1+(short)cachedoffset2)], @"Line4",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"X",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+4))], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+6))], @"Z",
                                                  @"UpdateSign", @"PacketType",
                                                  nil];
                        NSLog(@"%@", infoDict);
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x04:
                    if (cached_bflen == 8) {
                        char* time=(char*)data;
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithLongLong:OSSwapInt64(*(uint64_t*)(time))], @"Time",
                                                  @"TimeUpdate", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x11:
                    if (cached_bflen == 14) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithChar:*(char*)(data+4)], @"Unknown1",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+5)))], @"X",
                                                  [NSNumber numberWithChar:*(char*)(data+9)], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+13)))], @"Z",
                                                  @"UseBed", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x1E:
                    if (cached_bflen == 4) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  @"Entity", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                    
                case 0x03:
                    if (cached_bflen >= 2) {
                        if (cached_bflen == 2) {
                            
                            cachedoffset = (flipshort(*(short*)data));
                            bytestoread = cachedoffset * 2;
                        } else
                            if (cachedoffset*2 + 2 >= cached_bflen)
                            {
                                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Message",
                                                          @"ChatMessage", @"PacketType",
                                                          nil];
                                [[self sock] packet:self gotParsed:infoDict];
                                [[[self sock] inputStream] setDelegate:[self sock]];
                                [self release];
                                return;
                            }
                    }
                    break;
                case 0xFF:
                    if (cached_bflen >= 2) {
                        
                        short len = flipshort(*(short*)data);
                        if (cached_bflen == (len*2 + 2))
                        {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Message",
                                                      @"Disconnect", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x46:
                    if (cached_bflen == 2) {
                        
                        NSString* reason=@"Unknown";
                        switch (*data) {
                            case 0:
                                reason=@"Invalid Bed";
                                break;
                                
                            case 1:
                                reason=@"Begin Raining";
                                break;
                                
                            case 2:
                                reason=@"End Raining";
                                break;
                                
                            case 3:
                                reason=@"Change Gamemode";
                                break;
                                
                            case 4:
                                reason=@"Credits";
                                break;
                                
                            default:
                                break;
                        }
                        NSString* gm=(*data == 3) ? ((*(data+1) == 0) ? @"Survival" : @"Creative") : @"Unknown";
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  reason , @"Reason",
                                                  gm, @"GameMode",
                                                  @"ChangeState", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                case 0x05:
                    if (cached_bflen == 10) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+4))], @"Slot",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+6))], @"ItemID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+8))], @"Damage",
                                                  @"EntityEquipement", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x27:
                    if (cached_bflen == 8) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"VehicleID",
                                                  @"AttachEntity", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x29:
                    if (cached_bflen == 8) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithChar:((*(char*)(data+4)))], @"EffectID",
                                                  [NSNumber numberWithChar:((*(char*)(data+5)))], @"Amplifier",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(short*)(data+6)))], @"EntityID",
                                                  @"EntityEffect", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x2A:
                    if (cached_bflen == 5) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithChar:((*(char*)(data+4)))], @"EffectID",
                                                  @"RemoveEntityEffect", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x2B:
                    if (cached_bflen == 8) {
                        int mk=OSSwapInt32((*(int*)data));
                        float* flt = (float*)&mk;
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithFloat:*flt], @"ExpBar",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(short*)(data+4)))], @"Level",
                                                  [NSNumber numberWithShort:OSSwapInt16((*(short*)(data+6)))], @"TotalExperience",
                                                  @"SetExperience", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x33:
                    //FIXME
                    if (cached_bflen >= 21) {
                        if (cachedoffset == -1) {
                            cachedoffset = OSSwapInt32(*(int*)(data+13));
                            bytestoread = cachedoffset;
                        } else
                        {
                            if (cached_bflen == 21+cachedoffset) {
                                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                                                          [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"Z",
                                                          [NSNumber numberWithBool:((*(char*)(data+8)))], @"GroundUpContinuous",
                                                          [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+9)))], @"PrimaryBit",
                                                          [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+11)))], @"AddBit",
                                                          [NSData dataWithBytes:(data+21) length:OSSwapInt32(*(int*)(data+13))], @"ChunkData",
                                                          @"ChunkUpdate", @"PacketType",
                                                          nil];
                                [[self sock] packet:self gotParsed:infoDict];
                                [[[self sock] inputStream] setDelegate:[self sock]];
                                [self release];
                                return;
                            }
                        }
                    }
                    break;
                case 0x34:
                    if (cached_bflen >= 14) {
                        
                        int dsize = OSSwapInt32(*(int*)(data+10));
                        if (cached_bflen == 14+dsize) {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"ChunkX",
                                                      [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"ChunkY",
                                                      [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+8)))], @"RecordCount",
                                                      [NSData dataWithBytes:(data+14) length:dsize], @"Records",
                                                      @"MultiBlockChange", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x83:
                    if (cached_bflen >= 5) {
                        
                        short itemtype =  OSSwapInt16(*(short*)(data));
                        short itemid =    OSSwapInt16(*(short*)(data+2));
                        char len =       (*(int*)(data+4));
                        if (cached_bflen == 5+len) {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithShort:itemtype], @"ItemType",
                                                      [NSNumber numberWithShort:itemid], @"ItemID",
                                                      [NSData dataWithBytes:((char*)(data+5)) length:len], @"Records",
                                                      @"ItemData", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x84:
                    if (cached_bflen == 23) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data))], @"X",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+4))], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+6))], @"Z",
                                                  [NSNumber numberWithChar:*(char*)(data+10)], @"BlockMetadata",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+11))], @"Custom1",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+15))], @"Custom2",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+19))], @"Custom3",
                                                  @"UpdateTileEntity", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x35:
                    if (cached_bflen == 11) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data)))], @"X",
                                                  [NSNumber numberWithChar:*(char*)(data+4)], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+5)))], @"Z",
                                                  [NSNumber numberWithChar:*(char*)(data+9)], @"BlockType",
                                                  [NSNumber numberWithChar:*(char*)(data+10)], @"BlockMetadata",
                                                  @"BlockChange", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x08:
                    if (cached_bflen == 8) {
                        
                        float fsv=OSSwapInt32(*(char*)(data+4));
                        if (OSSwapInt16(*(int*)data) == 0) {
                            NSLog(@"Bai, cruel world :(");
                        }
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)data)], @"Health",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+2))], @"Food",
                                                  [NSNumber numberWithFloat:(float)(fsv)], @"Food Saturation",
                                                  @"HealthUpdate", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                        
                    }
                    break;
                case 0x09:
                    if (cached_bflen>10) {
                        
                        short len = flipshort(*(short*)(data+8));
                        if (cached_bflen == (len*2+10))
                        {
                            int worldtype=OSSwapInt32(*(int*)data);
                            NSString* type = @"Unknown";
                            if (worldtype == -1) {
                                type = @"The Nether";
                            } else if (worldtype == 0) {
                                type = @"Overworld";
                            } else if (worldtype == 1) {
                                type = @"The End";
                            }
                            char difficulty=(*(char*)(data+4));
                            NSString* diff = @"Unknown";
                            switch (difficulty) {
                                case 0:
                                    diff = @"Peaceful";
                                    break;
                                case 1:
                                    diff = @"Easy";
                                    break;
                                case 2:
                                    diff = @"Normal";
                                    break;
                                case 3:
                                    diff = @"Hard";
                                    break;
                                default:
                                    break;
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Respawn", @"PacketType",
                                                      type, @"Dimension",
                                                      diff, @"Difficulty",
                                                      ((*(char*)(data+5)) == 0) ? @"Survival" : @"Creative" , @"GameMode",
                                                      [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+6))], @"WorldHeight",
                                                      [MCString NSStringWithMinecraftString:((m_char_t*)(data+8))], @"WorldType",
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x18:
                    if (cached_bflen == 20) {
                        
                        NSString* type = @"Unknown";
                        switch ((*(char*)(data+4))) {
                            case 50:
                                type = @"Creeper";
                                break;
                            case 51:
                                type = @"Skeleton";
                                break;
                            case 52:
                                type = @"Spider";
                                break;
                            case 53:
                                type = @"Giant Zombie";
                                break;
                            case 54:
                                type = @"Zombie";
                                break;
                            case 55:
                                type = @"Slime";
                                break;
                            case 56:
                                type = @"Ghast";
                                break;
                            case 57:
                                type = @"Zombie Pigman";
                                break;
                            case 58:
                                type = @"Enderman";
                                break;
                            case 59:
                                type = @"Cave Spider";
                                break;
                            case 60:
                                type = @"Silverfish";
                                break;
                            case 61:
                                type = @"Blaze";
                                break;
                            case 62:
                                type = @"Magma Cube";
                                break;
                            case 63:
                                type = @"Ender Dragon";
                                break;
                            case 90:
                                type = @"Pig";
                                break;
                            case 91:
                                type = @"Sheep";
                                break;
                            case 92:
                                type = @"Cow";
                                break;
                            case 93:
                                type = @"Chicken";
                                break;
                            case 94:
                                type = @"Squid";
                                break;
                            case 95:
                                type = @"Wolf";
                                break;
                            case 96:
                                type = @"Mooshroom";
                                break;
                            case 97:
                                type = @"Snowman";
                                break;
                            case 98:
                                type = @"Ocelot";
                                break;
                            case 99:
                                type = @"Iron Golem";
                                break;
                            case 120:
                                type = @"Villager";
                                break;
                            default:
                                break;
                        }
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        int x = (OSSwapInt32(*(int*)(data+5 )));
                        int y = (OSSwapInt32(*(int*)(data+9 )));
                        int z = (OSSwapInt32(*(int*)(data+13)));
                        MCMetadata* metadata = [MCMetadata metadataWithSocket:[self sock] andEntity:[MCEntity entityWithIdentifier:OSSwapInt32(*(int*)data)] andType:type];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"MobSpawn", @"PacketType", 
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"EntityID",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  [NSNumber numberWithChar:(*((char*)(data+17)))], @"Yaw",
                                                  [NSNumber numberWithChar:(*((char*)(data+18)))], @"Pitch",
                                                  [NSNumber numberWithChar:(*((char*)(data+19)))], @"Head Yaw",
                                                  type, @"Type",
                                                  metadata, @"Metadata",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x1C:
                    if (cached_bflen == 10) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+4))], @"VelocityX",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+6))], @"VelocityY",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+8))], @"VelocityZ",
                                                  @"EntityVelocity", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x32:
                    if (cached_bflen == 9) {
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+4))], @"Z",
                                                  ((*(char*)(data+8)) == 0) ? @"DellocateColumn" : @"AllocateColumn", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0xC9:
                    if (cached_bflen >= 2) {
                        
                        short len = flipshort(*(short*)data);
                        if (cached_bflen == (len*2 + 5))
                        {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Nick",
                                                      [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3+len*2))], @"Ping",
                                                      [NSNumber numberWithBool:(*(BOOL*)(data+len*2+2))], @"IsOnline",
                                                      @"PlayerListItem", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        } else {
                            bytestoread = (len*2 + 5) - cached_bflen;
                        }
                    }
                    break;
                case 0x0D:
                    if (cached_bflen == 41) {
                        
                        const uint64_t* sdata = (const uint64_t*)data;
                        // I officially hate the LLVM compiler for having to do this.
                        uint64_t xv = OSSwapInt64(*sdata++);
                        uint64_t *x = &xv;
                        uint64_t stancev = OSSwapInt64(*sdata++);
                        uint64_t *stance = &stancev;
                        uint64_t yv = OSSwapInt64(*sdata++);
                        uint64_t *y = &yv;
                        uint64_t zv = OSSwapInt64(*sdata++);
                        uint64_t *z = &zv;
                        const uint32_t* kdata = (const uint32_t*)sdata;
                        uint64_t yawv = OSSwapInt32(*kdata++);
                        uint64_t *yaw = &yawv;
                        uint64_t pitchv = OSSwapInt32(*kdata++);
                        uint64_t *pitch = &pitchv;
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithDouble:*(double*)x], @"X",
                                                  [NSNumber numberWithDouble:*(double*)stance], @"Stance",
                                                  [NSNumber numberWithDouble:*(double*)y], @"Y",
                                                  [NSNumber numberWithDouble:*(double*)z], @"Z",
                                                  [NSNumber numberWithFloat:*(float*)yaw], @"Yaw",
                                                  [NSNumber numberWithFloat:*(float*)pitch], @"Pitch",
                                                  [NSNumber numberWithBool:(*(BOOL*)(data+41))], @"On Ground",
                                                  @"PositionAndLook", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x15:
                    if (cached_bflen == 24) {
                        
                        int x=OSSwapInt32(*(int*)(data+9));
                        int y=OSSwapInt32(*(int*)(data+13));
                        int z=OSSwapInt32(*(int*)(data+17));
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"EntityID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+4))], @"Item",
                                                  [NSNumber numberWithChar:(*(char*)(data+6))], @"Count",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+7))], @"Damage",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  [NSNumber numberWithChar:*(char*)(data+21)], @"Rotation",
                                                  [NSNumber numberWithChar:*(char*)(data+22)], @"Pitch",
                                                  [NSNumber numberWithChar:*(char*)(data+23)], @"Roll",
                                                  @"SpawnDroppedItem", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x23:
                    if (cached_bflen == 5) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char headyaw = *(char*)(data+4);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithChar:headyaw], @"Yaw",
                                                  @"EntityHeadLook", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x20:
                    if (cached_bflen == 6) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char yaw = *(char*)(data+4);
                        char pitch = *(char*)(data+5);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithChar:yaw], @"Yaw",
                                                  [NSNumber numberWithChar:pitch], @"Pitch",
                                                  @"EntityLook", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x22:
                    if (cached_bflen == 18) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        int x = OSSwapInt32(*(int*)(data+4));
                        int y = OSSwapInt32(*(int*)(data+8));
                        int z = OSSwapInt32(*(int*)(data+12));
                        char yaw = *(char*)(data+16);
                        char pitch = *(char*)(data+17);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithChar:yaw], @"Yaw",
                                                  [NSNumber numberWithChar:pitch], @"Pitch",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  @"EntityTeleport", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x21:
                    if (cached_bflen == 9) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char dx = *(char*)(data+4);
                        char dy = *(char*)(data+5);
                        char dz = *(char*)(data+6);
                        char yaw = *(char*)(data+7);
                        char pitch = *(char*)(data+8);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithChar:yaw], @"Yaw",
                                                  [NSNumber numberWithChar:pitch], @"Pitch",
                                                  [NSNumber numberWithDouble:(double)dx/32.0], @"DeltaX",
                                                  [NSNumber numberWithDouble:(double)dy/32.0], @"DeltaY",
                                                  [NSNumber numberWithDouble:(double)dz/32.0], @"DeltaZ",
                                                  @"EntityLookRelativeMove", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x1D:
                    if (cached_bflen == 4) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  @"DestroyEntity", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x36:
                    if (cached_bflen == 12) {
                        
                        int x = OSSwapInt32(*(int*)data);
                        short y = OSSwapInt16(*(int*)(data+4));
                        int z = OSSwapInt32(*(int*)(data+6));
                        char a = *(char*)(data+10);
                        char b = *(char*)(data+11);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:x], @"X",
                                                  [NSNumber numberWithInt:y], @"Y",
                                                  [NSNumber numberWithInt:z], @"Z",
                                                  [NSNumber numberWithChar:a], @"ActionType",
                                                  [NSNumber numberWithChar:b], @"ActionInfo",
                                                  @"BlockAction", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x28:
                    if (cached_bflen == 4) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [MCMetadata metadataWithSocket:[self sock] andEntity:[MCEntity entityWithIdentifier:eid] andType:@""], @"Metadata",
                                                  @"EntityMetadata", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x12:
                    if (cached_bflen == 5) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char animation = *(char*)(data+4);
                        NSString* anim = @"Unknown";
                        switch (animation) {
                            case 0:
                                anim = @"No Animation";
                                break;
                            case 1:
                                anim = @"Swing";
                                break;
                            case 2:
                                anim = @"Damage";
                                break;
                            case 3:
                                anim = @"Leave Bed";
                                break;
                            case 5:
                                anim = @"Eat";
                                break;
                            case 104:
                                anim = @"Crouch";
                                break;
                            case 105:
                                anim = @"Uncrouch";
                                break;
                            default:
                                break;
                        }
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  anim, @"AnimationType",
                                                  @"Animation", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x1F:
                    if (cached_bflen == 7) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char deltax = *(char*)(data+4);
                        char deltay = *(char*)(data+5);
                        char deltaz = *(char*)(data+6);
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithDouble:(double)deltax/32.0], @"DeltaX",
                                                  [NSNumber numberWithDouble:(double)deltay/32.0], @"DeltaY",
                                                  [NSNumber numberWithDouble:(double)deltaz/32.0], @"DeltaZ",
                                                  @"EntityRelativeMove", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x3D:
                    if (cached_bflen == 17) {
                        
                        int effectid = OSSwapInt32(*(int*)data);
                        int x = OSSwapInt32(*(int*)(data+4));
                        char y = (*(char*)(data+8));
                        int z = OSSwapInt32(*(int*)(data+9));
                        int kdata = OSSwapInt32(*(int*)(data+13));
                        NSString* effectString = @"Unknown";
                        switch (effectid) {
                            case 1000:
                            case 1001:
                                effectString = @"Click";
                                break;
                            case 1002:
                                effectString = @"Bow";
                                break;
                            case 1003:
                                effectString = @"Door";
                                break;
                            case 1004:
                                effectString = @"Fizz";
                                break;
                            case 1005:
                                effectString = @"MusicDisc";
                                break;
                            case 1007:
                                effectString = @"GhastCharge";
                                break;
                            case 1008:
                                effectString = @"GhastFireball";
                                break;
                            case 1010:
                                effectString = @"ZombieWood";
                                break;
                            case 1011:
                                effectString = @"ZombieMetal";
                                break;
                            case 1012:
                                effectString = @"ZombieWoodBreak";
                                break;
                            case 2000:
                                effectString = @"Smoke";
                                break;
                            case 2001:
                                effectString = @"BlockBreak";
                                break;
                            case 2002:
                                effectString = @"SplashPotion";
                                break;
                            case 2003:
                                effectString = @"EyeOfEnder";
                                break;
                            case 2004:
                                effectString = @"MobSpawnEffect";
                                break;
                            default:
                                break;
                        }
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:effectid], @"EffectID",
                                                  effectString, @"Effect",
                                                  [NSNumber numberWithInt:x], @"X",
                                                  [NSNumber numberWithChar:y], @"Y",
                                                  [NSNumber numberWithInt:z], @"Z",
                                                  [NSNumber numberWithInt:kdata], @"Data",
                                                  @"SoundParticleEffect", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x3C:
                    if (cached_bflen >= 32) {
                        
                        int recount = OSSwapInt32(*(int*)(data+28));
                        if (cached_bflen == (32+(recount*3))) {
                            double x = OSSwapInt64(*(double*)(data));
                            double y = OSSwapInt64(*(double*)(data+8));
                            double z = OSSwapInt64(*(double*)(data+16));
                            NSMutableArray* records = [NSMutableArray arrayWithCapacity:recount];
                            int cn = recount;
                            const unsigned char* recordsarr = (const unsigned char*)(data+32);
                            while (cn--) {
                                [records addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithChar:*recordsarr++], @"X",
                                                    [NSNumber numberWithChar:*recordsarr++], @"Y",
                                                    [NSNumber numberWithChar:*recordsarr++], @"Z",
                                                    nil]];
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithDouble:x], @"X",
                                                      [NSNumber numberWithDouble:y], @"Y",
                                                      [NSNumber numberWithDouble:z], @"Z",
                                                      records, @"Records",
                                                      @"Explosion", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x16:
                    if (cached_bflen == 8) {
                        
                        int eida = OSSwapInt32(*(int*)data);
                        int eidc = OSSwapInt32(*(int*)(data+4));
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eida], @"CollectedEntityID",
                                                  [NSNumber numberWithInt:eidc], @"CollectorEntityID",
                                                  @"CollectItem", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x26:
                    if (cached_bflen == 5) {
                        
                        int eid = OSSwapInt32(*(int*)data);
                        char status = *(char*)(data+4);
                        NSString* statusstr = @"Unknown";
                        switch (status) {
                            case 2:
                                statusstr = @"EntityHurt";
                                break;
                            case 3:
                                statusstr = @"EntityDead";
                                break;
                            case 6:
                                statusstr = @"WolfTaming";
                                break;
                            case 7:
                                statusstr = @"WolfTamed";
                                break;
                            case 8:
                                statusstr = @"WolfShaking";
                                break;
                            case 9:
                                statusstr = @"EatingAccepted";
                                break;
                            case 10:
                                statusstr = @"SheepEatingGrass";
                                break;
                            default:
                                break;
                        }
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  statusstr, @"Status",
                                                  @"EntityStatus", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x17:
                    if (cached_bflen >= 21) {
                        
                        if (OSSwapInt32(*(int*)(data+17))) {
                            if (cached_bflen != 27) {
                                break;
                                return;
                            }
                        }
                        int eid = OSSwapInt32(*(int*)data);
                        char type = *(char*)(data+4);
                        int x = OSSwapInt32(*(int*)(data+5));
                        int y = OSSwapInt32(*(int*)(data+9));
                        int z = OSSwapInt32(*(int*)(data+13));
                        int fromEid = OSSwapInt32(*(int*)(data+17));
                        short speedX = 0;
                        short speedY = 0;
                        short speedZ = 0;
                        NSDictionary* infoDict = nil;
                        NSString* tstr = @"Unknown";
                        switch (type) {
                            case 1:
                                tstr = @"Boat";
                                break;
                            case 10:
                                tstr = @"Minecart";
                                break;
                            case 11:
                                tstr = @"StorageCart";
                                break;
                            case 12:
                                tstr = @"PoweredCart";
                                break;
                            case 50:
                                tstr = @"ActivatedTNT";
                                break;
                            case 51:
                                tstr = @"EnderCrystal";
                                break;
                            case 60:
                                tstr = @"Arrow";
                                break;
                            case 61:
                                tstr = @"Snowball";
                                break;
                            case 62:
                                tstr = @"Egg";
                                break;
                            case 70:
                                tstr = @"FallingSand";
                                break;
                            case 71:
                                tstr = @"FallingGravel";
                                break;
                            case 72:
                                tstr = @"EyeOfEnder";
                                break;
                            case 74:
                                tstr = @"FallingDragonEgg";
                                break;
                            case 90:
                                tstr = @"FishingFloat";
                                break;
                            default:
                                break;
                        }
                        if (fromEid) {
                            speedX = OSSwapInt16(*(short*)(data+21));
                            speedY = OSSwapInt16(*(short*)(data+23));
                            speedZ = OSSwapInt16(*(short*)(data+25));
                        }
                        infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:eid], @"EntityID",
                                    tstr, @"Type",
                                    [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                    [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                    [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                    [NSNumber numberWithInt:fromEid], @"ThrowerEntityID",
                                    [NSNumber numberWithDouble:(double)speedX/32.0], @"SpeedX",
                                    [NSNumber numberWithDouble:(double)speedY/32.0], @"SpeedY",
                                    [NSNumber numberWithDouble:(double)speedZ/32.0], @"SpeedZ",
                                    @"SpawnObject", @"PacketType",
                                    nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x14:
                    if (cached_bflen > 6) {
                        
                        short len = flipshort(*(short*)(data+4));
                        if (cached_bflen == (len*2 + 22))
                        {
                            int x=OSSwapInt32(*(int*)(data+len*2+6));
                            int y=OSSwapInt32(*(int*)(data+len*2+10));
                            int z=OSSwapInt32(*(int*)(data+len*2+14));
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"EntityID",
                                                      [MCString NSStringWithMinecraftString:(m_char_t*)(data+4)], @"Name",
                                                      [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                      [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                      [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                      [NSNumber numberWithChar:*(char*)(data+len*2+18)], @"Yaw",
                                                      [NSNumber numberWithChar:*(char*)(data+len*2+19)], @"Pitch",
                                                      [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+len*2+20))], @"Current Item",
                                                      @"SpawnNamedEntity", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        } else {
                            bytestoread = (len*2 + 22) - cached_bflen; 
                        }
                    }
                    break;
                case 0x19:
                    if (cached_bflen >= 6) {
                        
                        short len = flipshort(*(short*)(data+4));
                        if (cached_bflen == (len*2 + 22))
                        {
                            int x=OSSwapInt32(*(int*)(data+len*2+6));
                            int y=OSSwapInt32(*(int*)(data+len*2+10));
                            int z=OSSwapInt32(*(int*)(data+len*2+14));
                            int direct=OSSwapInt32(*(int*)(data+len*2+18));
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"EntityID",
                                                      [MCString NSStringWithMinecraftString:(m_char_t*)(data+4)], @"Name",
                                                      [NSNumber numberWithInt:x], @"X",
                                                      [NSNumber numberWithInt:y], @"Y",
                                                      [NSNumber numberWithInt:z], @"Z",
                                                      [NSNumber numberWithInt:direct], @"Direction",
                                                      @"SpawnPainting", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x47:
                    if (cached_bflen == 17) {
                        
                        int eid=OSSwapInt32(*(int*)(data));
                        int x=OSSwapInt32(*(int*)(data+5));
                        int y=OSSwapInt32(*(int*)(data+9));
                        int z=OSSwapInt32(*(int*)(data+13));
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  @"Thunderbolt", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x1A:
                    if (cached_bflen == 18) {
                        
                        int eid=OSSwapInt32(*(int*)(data));
                        int x=OSSwapInt32(*(int*)(data+4));
                        int y=OSSwapInt32(*(int*)(data+8));
                        int z=OSSwapInt32(*(int*)(data+12));
                        int count=OSSwapInt16(*(int*)(data+16));
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:eid], @"EntityID",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  [NSNumber numberWithShort:count], @"Count",
                                                  @"SpawnExperienceDrop", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0xC8:
                    if (cached_bflen == 5) {
                        
                        int idt=OSSwapInt32(*(int*)(data));
                        char amount = *(char*)(data+4);
                        NSString* stat = @"Unknown";
                        switch (idt) {
                            case 1000:
                                stat=@"Start Game";
                                break;
                            case 1001:
                                stat=@"Create World";
                                break;
                            case 1002:
                                stat=@"Load World";
                                break;
                            case 1003:
                                stat=@"Join Multiplayer Server";
                                break;
                            case 1004:
                                stat=@"Leave Multiplayer Server";
                                break;
                            case 1100:
                                stat=@"Play for a minute";
                                break;
                            case 2000:
                                stat=@"Walk one centimeter";
                                break;
                            case 2001:
                                stat=@"Swim one centimeter";
                                break;
                            case 2002:
                                stat=@"Fall one centimeter";
                                break;
                            case 2003:
                                stat=@"Climb one centimeter";
                                break;
                            case 2004:
                                stat=@"Fly one centimeter";
                                break;
                            case 2005:
                                stat=@"Dive one centimeter";
                                break;
                            case 2006:
                                stat=@"Drive one centimeter"; // DIFFERENT THAN 2005!
                                break;
                            case 2007:
                                stat=@"Sail one centimeter";
                                break;
                            case 2008:
                                stat=@"Ride a pig for one centimeter";
                                break;
                            case 2010:
                                stat=@"Jump";
                                break;
                            case 2011:
                                stat=@"Drop";
                                break;
                            case 2020:
                                stat=@"Damage Dealt";
                                break;
                            case 2021:
                                stat=@"Damage Taken";
                                break;
                            case 2022:
                                stat=@"Deaths";
                                break;
                            case 2023:
                                stat=@"Mob Kills";
                                break;
                            case 2024:
                                stat=@"Player Kills";
                                break;
                            case 2025:
                                stat=@"Fish Caught";
                                break;
                            default:
                                break;
                        }
                        if (16777216 <= idt <= 16842751) {
                            stat = [NSString stringWithFormat:@"Block Mined: %d", (idt-16777216)];
                        } else if (16842752 <= idt <= 16908287) {
                            stat = [NSString stringWithFormat:@"Item Crafted: %d", (idt-16842752)];
                        } else if (16908288 <= idt <= 16973823) {
                            stat = [NSString stringWithFormat:@"Item Used: %d", (idt-16908288)];
                        } else if (16973824 <= idt <= 17039359) {
                            stat = [NSString stringWithFormat:@"Item Broken: %d", (idt-16973824)];
                        }
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  stat, @"Statistic",
                                                  [NSNumber numberWithChar:amount], @"Unit",
                                                  @"IncrementStat", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x00:
                    if (cached_bflen == 4) {
                        
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithUnsignedInt:OSSwapInt32(*(unsigned int*)(data))], @"PingID",
                                                  @"Ping", @"PacketType",
                                                  nil];
                        NSLog(@"Ping Packet! %u", OSSwapInt32(*(unsigned int*)(data)));
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                    }
                    break;
                default:
                    NSLog(@"Unknown packet [%02X] - Disconnecting!", identifier);
                    NSDictionary* kinfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [MCString createColorandTextPairsForMinecraftFormattedString:@"Protocol Error"], @"Message",
                                               @"Disconnect", @"PacketType",
                                               nil];
                    [self setIdentifier:0xFF];
                    [[self sock] packet:self gotParsed:kinfoDict];
                    [[[self sock] outputStream] close];
                    [[[self sock] inputStream] close];
                    [[[self sock] inputStream] setDelegate:nil];
                    [self release];
                    break;
            }
            break;
        }
        default:
            [[self sock] stream:theStream handleEvent:streamEvent];
            break;
    }
}

- (oneway void)dealloc
{
    [self setSock:nil];
    [self setBuffer:nil];
    [super dealloc];
}
@end
