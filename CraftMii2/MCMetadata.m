//
//  MCMetadata.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCMetadata.h"
#import "MCSocket.h"
#import "MCFakePacket.h"
@implementation MCMetadata
@synthesize oldDelegate, stream, metadata, etype, entity, buffer, kbuffer, socket;
+(MCMetadata*)metadataWithSocket:(MCSocket*)asocket andEntity:(MCEntity*)aentity andType:(NSString *)etype
{
    id ret = [aentity metadata];
    if (!ret) {
        ret = [MCMetadata new];
        [ret setEtype:etype];
        [ret setKbuffer:(char*)[asocket metadataArea]];
        [ret setBuffer:[ret kbuffer]];
    }
    [aentity setMetadata:ret];
    [ret setStream:[asocket inputStream]];
    [ret setOldDelegate:[[asocket inputStream] delegate]];
    [((MCMetadata*)ret) setMetadata:[[NSMutableArray new] autorelease]];
    [ret initValues];
    [[asocket inputStream] setDelegate:ret];
    return ret;
}
- (void) initValues
{
    bytestoread = 1;
    blen = 1024;
    dlen = 0;
}
- (id)init
{
    self = [super init];
    return self;
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
        {
            if ((buffer+dlen) + bytestoread >= (kbuffer) + blen) {
                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSArray arrayWithObjects:[NSArray arrayWithObjects:[UIColor whiteColor], @"Heap Overflow", nil], nil], @"Message",
                                          @"Disconnect", @"PacketType",
                                          nil];
                [[self socket] packet:(MCPacket*)[MCFakePacket fakePacketWithSocket:[self socket] andIdentifier:0xFF] gotParsed:infoDict];
                return;
            }
            if (!bytestoread) {
                bytestoread=1;
            }
            if ([theStream streamStatus] == NSStreamStatusOpen) {
                int rly_read_bytes = [(NSInputStream *)theStream read:(uint8_t*)((kbuffer) + (int)dlen) maxLength:bytestoread];
                if (rly_read_bytes == -1) {
                    return;
                }
                dlen += rly_read_bytes;
                if (rly_read_bytes < bytestoread) {
                    bytestoread = bytestoread - rly_read_bytes;
                    return;
                }
            } else return;
            unsigned char pt = *buffer;
            if (pt==127) {
                [oldDelegate metadata:(MCMetadata*)self hasFinishedParsing:metadata];
                [stream setDelegate:oldDelegate];
                [self setOldDelegate:nil];
                [entity setMetadata:self];
                [self setEntity:nil];
                return;
            }
            bytestoread = 1;
            if (!dlen) return;
            char index=(pt) & 0x1F; 
            char type=(pt) >> 5;
            switch (type) {
                case 0:
                    if (dlen == 2) {
                        switch (index) {
                            case 0:;;
                                char ptz = * ((buffer) + 1);
                                BOOL isOnFire = ptz & 0x01;
                                BOOL isCrouched = ptz & 0x02;
                                BOOL isRiding = ptz & 0x04;
                                BOOL isSprinting = ptz & 0x08;
                                BOOL isRightClicking = ptz & 0x10;
                                [metadata addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithBool:isOnFire], @"isOnFire",
                                                     [NSNumber numberWithBool:isCrouched], @"isCrouched",
                                                     [NSNumber numberWithBool:isRiding], @"isRiding",
                                                     [NSNumber numberWithBool:isSprinting], @"isSprinting",
                                                     [NSNumber numberWithBool:isRightClicking], @"isRightClicking",
                                                     nil]
                                 ];
                                break;
                                
                            default:
                                break;
                        }
                        dlen = 0;
                    }
                    break;
                case 1:
                    if (dlen == 3) {
                        switch (index) {
                            default:
                                break;
                        }
                       dlen = 0;
                    } else {
                        bytestoread = 3 - dlen;
                    }
                    break;
                case 2:
                    if (dlen == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        dlen = 0;
                    } else {
                        bytestoread = 5 - dlen;
                    }
                    break;
                case 3:
                    if (dlen == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        dlen = 0;
                    } else {
                        bytestoread = 5 - dlen;
                    }
                    break;
                case 4:;
                    if (dlen >= 3) {
                        unsigned short flipped_len = *(short*)((char*)buffer+1);
                        flipped_len = OSSwapConstInt16(flipped_len) + 3;
                        if (dlen == flipped_len) {
                            switch (index) {
                                default:
                                    break;
                            }
                            dlen = 0;
                        } else {
                            bytestoread = flipped_len - dlen;
                        }
                    } else {
                        bytestoread = 3 - dlen;
                    }
                    break;
                case 5:
                    if (dlen == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        dlen = 0;
                    } else {
                        bytestoread = 5 - dlen;
                    }
                    break;
                case 6:
                    if (dlen == 13) {
                        switch (index) {
                            default:
                                break;
                        }
                        dlen = 0;
                    } 
                    else {
                        bytestoread = 13 - dlen;
                    }
                    break;
                default:
                    NSLog(@"THE HELL");
                    break;
            }
        }
            break;
        default:
            [oldDelegate stream:theStream handleEvent:streamEvent];
            break;
    }
}

-(void)dealloc
{
    [self setOldDelegate:nil];
    [super dealloc];
}
@end
