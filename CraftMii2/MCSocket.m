//
//  MCSocket.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

// 4.27

#import "MCSocket.h"
#import "MCString.h"
#import "MCPacket.h"
#import "MCWindow.h"
#import "MCHandshakePacket.h"
#import "MCPingPacket.h"
#import "MCPlayerPositionLookPacket.h"
#import "MCFakePacket.h"
#import "MCBuffer.h"
#import "MCStream.h"
#import "MCChunk.h"
#import "MCPlayer.h"
#import "MCWorld.h"

static int currentIdentifier = 0;

@implementation MCSocket
@synthesize inputStream, outputStream, auth, player, server, delegate, buffer, dataBuffer, metadataArea, outputBuffer, ticks, identifier, world, isConnected;
-(MCSocket*)initWithServer:(NSString*)iserver andAuth:(MCAuth*)iauth
{
    NSLog(@"ID: %d", currentIdentifier);
    [self setIdentifier:currentIdentifier++];
    NSLog(@"ID: %d", currentIdentifier);
    [self setAuth:iauth];
    [self setServer:iserver];
    [self setWorld:[MCWorld new]];
    [[self world] setSocket:self];
    return self;
}
-(void)threadLoop
{
    ticks=0;
    lpingtick=0;
    id pool = [NSAutoreleasePool new];
    register id runLoop = [NSRunLoop currentRunLoop];
    [NSTimer scheduledTimerWithTimeInterval:1.0/20.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self __connect];
    while (isInUse) {
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:30.0]];
        [pool release];
        pool = [NSAutoreleasePool new];
    }
}
-(void)connect
{
    [self connect:YES];
}
-(void)connect:(BOOL)threaded
{
    if (threaded) {
        [self performSelectorInBackground:@selector(threadLoop) withObject:nil];
        return;
    }
    NSLog(@"## WARN! NON-THREADED PARSING MIGHT BE TOO FAST/SLOW, FORCING TO THREADED PARSING");
    [self connect:YES];
    return;
    [self __connect];
}
-(int)version
{
#ifdef __MC_SMP_13
    return 32;
#else
    return 29;
#endif
}
-(void)__connect
{
    isInUse = YES;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSArray* pieces = [server componentsSeparatedByString:@":"];
    NSString* target = @"";
    int port = 25565;
    if ([pieces count] == 1) {
        target = [pieces objectAtIndex:0];
    }
    else if ([pieces count] > 1) {
        target = [pieces objectAtIndex:0];
        port = [[pieces objectAtIndex:1] intValue];
    }
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)target, port
                                       , &readStream, &writeStream);
    self.inputStream = (NSInputStream *)readStream;
    self.outputStream = (NSOutputStream *)writeStream;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    NSInputStream* sin = (NSInputStream*)[MCStream streamWithStream:inputStream];
    NSOutputStream* sout = (NSOutputStream*)[MCStream streamWithStream:outputStream];
    [self setInputStream:sin];
    [self setOutputStream:sout];
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [self setDataBuffer:malloc(12800)];
    [self setMetadataArea:malloc(1024)];
    [self setOutputBuffer:[MCBuffer bufferWithSocket:self]];
}
- (void)tick
{
    if ((ticks-lpingtick)>600) {
        if (isInUse) {
            [self disconnectWithReason:@"Read timed out"];
        }
    }
    if (isInUse && [outputStream streamStatus] == NSStreamStatusOpen) {
        if (isConnected) {
            NSDictionary* dicts = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:  [[self player] x]]        , @"X",
                               [NSNumber numberWithDouble:  [[self player] stance]]   , @"Stance",
                               [NSNumber numberWithDouble:  [[self player] y]]        , @"Y",
                               [NSNumber numberWithDouble:  [[self player] z]]        , @"Z",
                               [NSNumber numberWithFloat:   [[self player] yaw]]      , @"Yaw",
                               [NSNumber numberWithFloat:   [[self player] pitch]]    , @"Pitch",
                               [NSNumber numberWithBool:    [[self player] onGround]] , @"On Ground",
                               nil];
            [[MCPlayerPositionLookPacket packetWithInfo:dicts] sendToSocket:self];
            ticks++;
        }
        [outputBuffer tick];
        if ([delegate respondsToSelector:@selector(socketDidTick:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate socketDidTick:self];
            });
        }
    }
}
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict
{
    if ([delegate respondsToSelector:@selector(slot:hasFinishedParsing:)]) {
        if ([NSThread isMainThread])
            [delegate slot:slot hasFinishedParsing:infoDict];
        else
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate slot:slot hasFinishedParsing:infoDict];
            });
    }
}
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray
{
    if ([delegate respondsToSelector:@selector(metadata:hasFinishedParsing:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate metadata:metadata hasFinishedParsing:infoArray];
            });
    }
}
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict
{
    [infoDict retain];
    if ([packet identifier] == 0x0D)
    {
        [[self player] setX:          [[infoDict objectForKey:@"X"] doubleValue]];
        [[self player] setY:          [[infoDict objectForKey:@"Y"] doubleValue]];
        [[self player] setZ:          [[infoDict objectForKey:@"Z"] doubleValue]];
        [[self player] setStance:     [[infoDict objectForKey:@"Stance"] doubleValue]];
        [[self player] setYaw:        [[infoDict objectForKey:@"Yaw"] floatValue]];
        [[self player] setPitch:      [[infoDict objectForKey:@"Pitch"] floatValue]];
        [[self player] setOnGround:   [[infoDict objectForKey:@"On Ground"] boolValue]];
        isConnected = YES;
    }
    else if ([packet identifier] == 0xFF) {
        [outputStream setDelegate:nil];
        [inputStream setDelegate:nil];
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [inputStream close];
        [outputStream close];
        self.outputStream = nil;
        self.inputStream = nil;
        isInUse = NO;
        [self autorelease];
    } else if ([packet identifier] == 0x01)
    {
        player = (MCPlayer*)[MCPlayer entityWithIdentifier:[[infoDict objectForKey:@"EntityID"] intValue]];
        [player setGamemode:[infoDict objectForKey:@"GameMode"]];
    }

    if ([delegate respondsToSelector:@selector(packet:gotParsed:)]) { 
            dispatch_async(dispatch_get_main_queue(), ^{
                /*NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                 [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"Z",
                 [NSNumber numberWithBool:((*(char*)(data+8)))], @"GroundUpContinuous",
                 [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+9)))], @"PrimaryBit",
                 [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+11)))], @"AddBit",
                 [NSData dataWithBytes:(data+21) length:OSSwapInt32(*(int*)(data+13))], @"ChunkData",
                 @"ChunkUpdate", @"PacketType",
                 nil];
                 NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                 [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+4))], @"Z",
                 ((*(char*)(data+8)) == 0) ? @"DellocateColumn" : @"AllocateColumn", @"PacketType",
                 nil];*/
                if ([packet identifier] == 0x33)
                {
                    [world updateChunk:infoDict];
                }
                else if ([packet identifier] == 0x32)
                {
                    if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"AllocateColumn"]) {
                        [world allocateChunk:infoDict];
                    }
                    else {
                        [world deallocateChunk:infoDict];
                    }
                } else if ([packet identifier] == 0x34)
                {
                    [world updateChunk:infoDict];
                }
                else if ([packet identifier] == 0x35)
                {
                    /*
                     [NSNumber numberWithInt:OSSwapInt32((*(int*)(data)))], @"X",
                     [NSNumber numberWithChar:*(char*)(data+4)], @"Y",
                     [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+5)))], @"Z",
                     [NSNumber numberWithChar:*(char*)(data+9)], @"BlockType",
                     [NSNumber numberWithChar:*(char*)(data+10)], @"BlockMetadata",
                     @"BlockChange", @"PacketType",
                     */
                    [world setBlock:MCBlockCoordMake([[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Y"] charValue], [[infoDict objectForKey:@"Z"] intValue]) to:(MCBlock){[[infoDict objectForKey:@"BlockType"] shortValue], [[infoDict objectForKey:@"BlockMetadata"] charValue], 0,0}];
                }
                else if ([packet identifier] == 0x09)
                {
                    [world deallocateChunks];
                    [player setGamemode:[infoDict objectForKey:@"GameMode"]];
                }
                else if ([packet identifier] == 0x46)
                {
                    if ([[infoDict objectForKey:@"Reason"] isEqualToString:@"Change Gamemode"]) {
                        [player setGamemode:[infoDict objectForKey:@"GameMode"]];
                    }
                }
                else if ([packet identifier] == 0x00)
                {
                    NSLog(@"%d", [world getBlock:MCBlockCoordMake(-228, 69, 200)].typedata);
                    lpingtick = ticks;
                    [[MCPingPacket packetWithInfo:infoDict] sendToSocket:self];
                }
                [delegate packet:packet gotParsed:infoDict];
                [infoDict release];
            });
    } else {
        [infoDict release];
    }
}
- (void)disconnect
{
    [self disconnectWithReason:@"Disconnected"];
}
- (void)disconnectWithReason:(NSString*)reason
{
    NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray arrayWithObjects:[NSArray arrayWithObjects:[UIColor whiteColor], reason, nil], nil], @"Message",
                              @"Disconnect", @"PacketType",
                              nil];
    [self packet:(MCPacket*)[MCFakePacket fakePacketWithSocket:self andIdentifier:0xFF] gotParsed:infoDict];
}
- (void)writeBuffer
{
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
        case NSStreamEventErrorOccurred:
        {
            if (errno) {
                [self disconnectWithReason:[NSString stringWithUTF8String:strerror(errno)]];
                return;
            }
            [self disconnectWithReason:@"Stream error"];
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self disconnectWithReason:@"End of stream"];
            break;
        }
		case NSStreamEventHasSpaceAvailable:
            [self writeBuffer];
			break;
		case NSStreamEventOpenCompleted:
            if ([[(MCStream*)theStream origStream] isKindOfClass:[NSOutputStream class]]) {
                [[MCHandshakePacket packetWithInfo:nil] sendToSocket:self];
            }
			break;
		case NSStreamEventHasBytesAvailable:
            ;;
            unsigned char packetIdentifier=0x00;
            [(NSInputStream *)theStream read:&packetIdentifier maxLength:1];
            lPacket = packetIdentifier;
            [MCPacket packetWithID:packetIdentifier andSocket:self]; 
            break;
        default:
        {
            NSLog(@"Unknown Stream Event.");
            [self disconnectWithReason:@"Unknown Stream Event"];            
        }
            break;    
    }
}
- (void)chunkDidUpdate:(MCChunk*)chunk
{
    if ([delegate respondsToSelector:@selector(chunkDidUpdate:)]) { 
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate chunkDidUpdate:chunk];
        });
    }
}
-(void)dealloc
{
    NSLog(@"== BAIL ==");
    currentIdentifier--;
    free((void*)[self dataBuffer]);
    free((void*)[self metadataArea]);
    [self setBuffer:nil];
    [self setAuth:nil];
    [self setWorld:nil];
    [super dealloc];
}
@end
