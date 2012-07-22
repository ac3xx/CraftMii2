//
//  MCChunk.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSocket.h"
@class MCWorld;

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

struct MCVertex
{
    char x;
    char y;
    char z;
};

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

#define MCAnvilIndex(relativecoord) ((relativecoord.y * 16 + relativecoord.z) * 16 + relativecoord.x)
#define MCBlockInSection(section, relativecoord) MCGetBlockInSection(section, relativecoord)

typedef struct MCBlock
{
    unsigned short typedata;
    unsigned char metadata;
    unsigned char light;
    unsigned char skylight;
} MCBlock;
extern void MCSetBlockInSection(MCSection* section, MCBlockCoord relativecoord, MCBlock block);
extern MCBlockCoord absoluteCoordToSectionRelative(MCBlockCoord orig);
extern MCBlockCoord entityCoordToChunkSectionCoord(MCBlockCoord orig);
extern MCChunkCoord chunkCoordForEntityCoord(MCCoord orig);
extern MCBlock MCGetBlockInSection(MCSection* section, MCBlockCoord relativecoord);
@interface MCChunk : NSObject
{
    int x;
    int z;
    int sections_bitmask;
    MCSection* sections[16];
    char biomes[16*16];
    MCWorld* world;
    BOOL shouldBeRendered;
    BOOL hasBeenRendered;
    struct MCVertex* vertexData;
    int vertexSize;
    BOOL isRendering;
    BOOL isUpdating;
}
@property(assign) int x;
@property(assign) int z;
@property(assign) MCWorld* world;
@property(assign)  BOOL shouldBeRendered;
@property(readonly) BOOL hasBeenRendered;
-(struct MCVertex*)vertexData;
-(int)vertexSize;
-(void)updateChunk:(NSDictionary*)infoDict;
-(MCSection*)sectionForBlockCoord:(MCBlockCoord)coord;
-(MCSection*)sectionForYRel:(short)y;
-(MCSection*)allocateSection:(char)index;
-(void)refresh;
@end
MCBlock getBlock(MCBlockCoord coord, MCSocket* socket);
