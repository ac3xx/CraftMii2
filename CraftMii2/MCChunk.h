//
//  MCChunk.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSocket.h"

typedef enum MCBiome
{
    MCBiomeOcean,
    MCBiomePlains,
    MCBiomeDesert,
    MCBiomeExtremeHills,
    MCBiomeForest,
    MCBiomeTaiga,
    MCBiomeSwampland,
    MCBiomeRiver,
    MCBiomeHell,
    MCBiomeSky,
    MCBiomeFrozenOcean,
    MCBiomeFrozenRiver,
    MCBiomeIcePlains,
    MCBiomeIceMountains,
    MCBiomeMushroomIsland,
    MCBiomeMushroomIslandShore,
    MCBiomeBeach,
    MCBiomeDesertHills,
    MCBiomeForestHills,
    MCBiomeTaigaHills,
    MCBiomeExtremeHillsEdge,
    MCBiomeJungle,
    MCBiomeJungleHills,
    __INTERNAL_MCBiomeEnumEnd
} MCBiome;
extern NSString* __INTERNAL_MCBiomeNameStringMatrix[];
extern NSString* MCBiomeToNSString(MCBiome biome);
typedef struct MCChunkCoord
{
    int x;
    int z;
} MCChunkCoord;
typedef struct MCCoord
{
    double x;
    double y;
    double z;
} MCCoord;
typedef struct MCBlockCoord
{
    int x;
    int y;
    int z;
} MCBlockCoord;
typedef struct MCRelativeCoord
{
    char x;
    char y;
    char z;
} MCRelativeCoord;

#define MCChunkCoordMake(x,z) (MCChunkCoord){x,z}
#define MCCoordMake(x, y, z) (MCCoord){x,y,z}
#define MCBlockCoordMake(x, y, z) (MCBlockCoord){x,y,z}
#define MCSectionReadBlockType(section, blockcoord) section.typedata

typedef struct MCSection
{
    unsigned char typedata[16*16*16];
    unsigned char metadata[16*16*8 ];
    unsigned char lightarr[16*16*8 ];
    unsigned char skylight[16*16*8 ];
    unsigned char addarray[16*16*8 ];
} MCSection;

#define __mod(a,b) ((a < 0) ? -a % b : a % b)
/*
 ((int)  (section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) << 8) & 0xFFF, \
*/

#define MCAnvilIndex(relativecoord) ((relativecoord.y << 4 | relativecoord.z) << 4 | relativecoord.x)
#define MCBlockInSection(section, relativecoord) \
    (MCBlock)\
    {\
        (       section->typedata[MCAnvilIndex(relativecoord)]) + \
        (((     (section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F) << 8),  \
        (       (section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, \
        (       (section->lightarr[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, \
        (       (section->skylight[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F,  \
    }

typedef struct MCBlock
{
    unsigned short typedata;
    unsigned char metadata;
    unsigned char light;
    unsigned char skylight;
} MCBlock;

MCBlockCoord absoluteCoordToSectionRelative(MCBlockCoord orig);
MCBlockCoord entityCoordToChunkSectionCoord(MCBlockCoord orig);
MCChunkCoord chunkCoordForEntityCoord(MCCoord orig);

@interface MCChunk : NSObject
{
    int x;
    int z;
    int sections_bitmask;
    MCSection* sections[16];
    MCBiome biomes[16*16];
    MCSocket* socket;
}
@property(assign) int x;
@property(assign) int z;
@property(assign) MCSocket* socket;
+(MCChunk*)chunkAtCoord:(MCChunkCoord)coord forSocket:(MCSocket*)socket;
+(MCChunk*)chunkAtCoord:(MCChunkCoord)coord forSocket:(MCSocket*)socket allocate:(BOOL)alloc;
+(void)deallocateAllChunksForSocket:(MCSocket*)socket;
-(void)updateChunk:(NSDictionary*)infoDict;
-(MCSection*)sectionForBlockCoord:(MCBlockCoord)coord;
-(MCSection*)sectionForYRel:(short)y;
@end
MCBlock getBlock(MCBlockCoord coord, MCSocket* socket);
