//
//  MCChunk.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCChunk.h"
#import "NSData+UserAdditions.h"

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
    dispatch_async(queue, ^{
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
        int read=0;
        for (short i=0;i<16;i++) {
            if ((primary >> i ) & 0x1) {
                sections_bitmask |= 1 << i;
                if (!sections[i]) {
                    sections[i] = (MCSection*) malloc(sizeof(MCSection));
                }
                if ((add >> i ) & 0x1) {
                    if (read+sizeof(MCSection) > [dt length]) {
                        NSLog(@"[Critical] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.");
                        [[world socket] disconnectWithReason:@"Chunk Error"];
                        return;
                    }
                    memcpy(sections[i], db+(read), sizeof(MCSection));
                    read += sizeof(MCSection);
                } else {
                    memcpy(sections[i], db+(read), sizeof(MCSection)-sizeof(sections[i]->addarray));
                    read += sizeof(MCSection)-sizeof(sections[i]->addarray);
                    bzero(&sections[i]->addarray, sizeof(sections[i]->addarray));
                }
            }
        }
        if(guc)
        {
            memcpy(biomes, db+read, sizeof(biomes));
        }
        [[world socket] chunkDidUpdate:self];
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
