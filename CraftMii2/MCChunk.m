//
//  MCChunk.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCChunk.h"
#import "MCSocket.h"
#import "MCWorld.h"
#import "NSData+UserAdditions.h"
void MCSetBlockInSection(MCSection* section, MCBlockCoord relativecoord, MCBlock block)
{
    section->typedata[MCAnvilIndex(relativecoord)] = block.typedata;
    section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.typedata & 0xF00 ) >> (__mod(relativecoord.x, 2) ? 8 : 4);
    section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.metadata & 0x00F ) << (__mod(relativecoord.x, 2) ? 0 : 4);
}

MCBlock MCGetBlockInSection(MCSection* section, MCBlockCoord relativecoord)
{
    return (MCBlock)
    {
        (       section->typedata[MCAnvilIndex(relativecoord)]) + 
        (((     (section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F) << 8),
        (       (section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
        (       (section->lightarr[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
        (       (section->skylight[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
    };
}

MCBlockCoord absoluteCoordToSectionRelative(MCBlockCoord orig)
{
    register int x = orig.x;
    register int y = orig.y;
    register int z = orig.z;
    register int modx = __mod(x, 16);
    register int mody = __mod(y, 16);
    register int modz = __mod(z, 16);
    return MCBlockCoordMake(modx,mody,modz);
}

MCBlockCoord entityCoordToChunkSectionCoord(MCBlockCoord orig)
{
    register int x = orig.x;
    register int y = orig.y;
    register int z = orig.z;/*
                             register int modx = __mod(x, 16);
                             register int mody = __mod(y, 16);
                             register int modz = __mod(z, 16);
                             x -= modx;
                             y -= mody;
                             z -= modz;*/
    return MCBlockCoordMake(x/16,y/16,z/16);
}

MCChunkCoord chunkCoordForEntityCoord(MCCoord orig)
{
    register int x = orig.x;
    register int z = orig.z;/*
                             register int modx = __mod(x, 16);
                             register int mody = __mod(y, 16);
                             register int modz = __mod(z, 16);
                             x -= modx;
                             y -= mody;
                             z -= modz;*/
    return MCChunkCoordMake(x/16, z/16);
}

NSString* MCBiomeToNSString(MCBiome biome)
{
    if (biome < __INTERNAL_MCBiomeEnumEnd) {
        return __INTERNAL_MCBiomeNameStringMatrix[biome];
    }
    return @"MCBiomeInvalid";
}
NSString* __INTERNAL_MCBiomeNameStringMatrix[__INTERNAL_MCBiomeEnumEnd] =
{
    @"MCBiomeOcean",
    @"MCBiomePlains",
    @"MCBiomeDesert",
    @"MCBiomeExtremeHills",
    @"MCBiomeForest",
    @"MCBiomeTaiga",
    @"MCBiomeSwampland",
    @"MCBiomeRiver",
    @"MCBiomeHell",
    @"MCBiomeSky",
    @"MCBiomeFrozenOcean",
    @"MCBiomeFrozenRiver",
    @"MCBiomeIcePlains",
    @"MCBiomeIceMountains",
    @"MCBiomeMushroomIsland",
    @"MCBiomeMushroomIslandShore",
    @"MCBiomeBeach",
    @"MCBiomeDesertHills",
    @"MCBiomeForestHills",
    @"MCBiomeTaigaHills",
    @"MCBiomeExtremeHillsEdge",
    @"MCBiomeJungle",
    @"MCBiomeJungleHills"
};

@implementation MCChunk
@synthesize x,z,world;

- (oneway void)dealloc
{
    NSLog(@"kthxbai");
    for (short i=0;i<16;i++) {
        if (((sections_bitmask >> i ) & 0x1) && sections[i]) {
            free(sections[i]);
            sections[i] = NULL;
        }
    }
    [super dealloc];
}
+(MCBlockCoord)absoluteCoordToSectionRelative:(MCBlockCoord)orig
{
    return absoluteCoordToSectionRelative(orig);
}
+(MCBlockCoord)entityCoordToChunkSectionCoord:(MCBlockCoord)orig
{
    return entityCoordToChunkSectionCoord(orig);
}

-(void)updateChunk:(NSDictionary*)infoDict
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    [infoDict retain];
    dispatch_async(queue, ^{
        @synchronized(self)
        {
            /*
             NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"ChunkX",
             [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"ChunkY",
             [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+8)))], @"RecordCount",
             [NSData dataWithBytes:(data+14) length:dsize], @"Records",
             @"MultiBlockChange", @"PacketType",
             nil];
             */
            if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"ChunkUpdate"]) {
                NSLog(@"%@", infoDict);
                short primary = [[infoDict objectForKey:@"PrimaryBit"] shortValue];
                short add = [[infoDict objectForKey:@"AddBit"] shortValue];
                NSData* dt = [[infoDict objectForKey:@"ChunkData"] zlibInflate];
                const char* db = [dt bytes];
                BOOL guc = [[infoDict objectForKey:@"GroundUpContinuous"] boolValue];
                if(guc)
                {
                    for (short i=0;i<16;i++) {
                        if (((sections_bitmask >> i ) & 0x1) && sections[i]) {
                            free(sections[i]);
                            sections[i] = NULL;
                        }
                    }
                    sections_bitmask = 0;
                }
                int rpoint=0;
                for (short i=0;i<16;i++) {
                    if ((primary >> i ) & 0x1) {
                        sections_bitmask |= 1 << i;
                        if (!(sections[i])) {
                            sections[i] = (MCSection*) malloc(sizeof(MCSection));
                        }
                        if ((add >> i ) & 0x1) {
                            if (rpoint+sizeof(MCSection) > [dt length]) {
                                NSLog(@"[Critical] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.");
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [[world socket] disconnectWithReason:@"Chunk Error"];                 
                                    [infoDict release];
                                });
                                return;
                            }
                            memcpy(sections[i], (char*)(int)[dt bytes]+(rpoint), sizeof(MCSection));
                            rpoint += sizeof(MCSection);
                        } else {
                            if (rpoint+sizeof(MCSection)-2048 > [dt length]) {
                                NSLog(@"[Critical] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.");
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [[world socket] disconnectWithReason:@"Chunk Error"];                 
                                    [infoDict release];
                                });
                                return;
                            }
                            bzero(sections[i]->addarray, 2048);
                            memcpy(sections[i], (char*)(int)[dt bytes]+(rpoint), sizeof(MCSection)-2048);
                            rpoint += sizeof(MCSection)-2048;
                        }
                    }
                }
                if(guc)
                {
                    if (rpoint+sizeof(biomes) > [dt length]) {
                        NSLog(@"[Critical] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.");
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [[world socket] disconnectWithReason:@"Chunk Error"];                 
                            [infoDict release];
                        });
                        return;
                    }
                    memcpy(biomes, db+rpoint, sizeof(biomes));
                    rpoint += sizeof(biomes);
                }
                if (rpoint != [dt length]) {
                    NSLog(@"[Critical] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.");
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [[world socket] disconnectWithReason:@"Chunk Error"];                 
                        [infoDict release];
                    });
                    return;
                }
                NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                [[world socket] chunkDidUpdate:self];
                [infoDict release];
            } else if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"MultiBlockChange"]) {
                NSData* dt = [[infoDict objectForKey:@"Records"] zlibInflate];
                const char* db = [dt bytes];
                int rpoint = 0;
                while ([dt length] != rpoint) {
                    int parse = *(int*)(db + rpoint);
                    char metadata = parse & 0x0000000F;
                    short blockid = ( parse & 0x0000FFF0 ) >> 4;
                    char   ycoord = ( parse & 0x00FF0000 ) >> 16;
                    char   zcoord = ( parse & 0x0F000000 ) >> 24;
                    char   xcoord = ( parse & 0xF0000000 ) >> 28;
                    char yrelcoord = abs(ycoord) % 16;
                    char ysection = ycoord / 16;
                    MCSection* sc = sections[ysection];
                    MCSetBlockInSection(sc, MCBlockCoordMake(xcoord, yrelcoord, zcoord), ((MCBlock){blockid, metadata, 0, 0}));
                    NSLog(@"MBC");
                    rpoint += 4;
                }
            }
        }
    });
}

-(MCSection*)sectionForBlockCoord:(MCBlockCoord)coord
{
    short y = entityCoordToChunkSectionCoord(coord).y;
    if (y > 16) {
        return NULL;
    }
    return sections[entityCoordToChunkSectionCoord(coord).y];
}

-(MCSection*)sectionForYRel:(short)y
{
    if (!((sections_bitmask >> y) & 0x1)) {
        return NULL;
    }
    return sections[y];
}

@end

MCBlock getBlock(MCBlockCoord coord, MCSocket* socket)
{
    /*
     MCBlockCoord chunkCoord = entityCoordToChunkSectionCoord(coord);
     MCBlockCoord relativeCoord = absoluteCoordToSectionRelative(coord);
     MCChunk* chunk = [MCChunk chunkAtCoord:MCChunkCoordMake(chunkCoord.x, chunkCoord.z)  forSocket:socket];
     MCSection* sect = [chunk sectionForYRel:chunkCoord.y];
     if (!sect) {
     return (MCBlock){0,0,0,0};
     }
     MCBlock ret = MCBlockInSection(sect, relativeCoord);
     NSLog(@"ID of (X: [%d|%d|%d] Y: [%d|%d|%d] Z: [%d|%d|%d]) is: %d [%ld]", relativeCoord.x, chunkCoord.x, coord.x, relativeCoord.y, chunkCoord.y, coord.y, relativeCoord.z, chunkCoord.z, coord.z, ret.typedata, sizeof(MCBlock));
     return ret;
     */
    return (MCBlock){0,0,0,0};
}
