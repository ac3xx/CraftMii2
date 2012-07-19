//
//  MCItem.m
//  CraftMii2
//
//  Created by qwertyoruiop on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCItem.h"
/*
 cat /Users/qwertyoruiop/Documents/items.txt | awk '{print "{"$1",\t\t\t @\""$2"\",\t\t\t\t\t "$3",\t\t\t"$4",\t\t\t"$5",\t\t\t"$6",\t\t\t"$7",\t\t\t"$8",\t\t\t"$9",\t\t\t(float)"$10",\t\t\t"$11",\t\t\tMCMaterial"$12"},\t\t\t"}'|pbcopy
 */

MCItem itemTable[] =
{
    {-1,                                @"No Item",                     0,          1,			0,			0,			0,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeAir,                    @"Air",                         0,          1,			0,			0,			0,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeStone,                  @"Stone",                       64,         1,			0,			1,			1,			0,			0,			(float)1.5,			0,			MCMaterialStone},			
    {MCBlockTypeGrass,                  @"Grass",                       64,         1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialDirt},			
    {MCBlockTypeDirt,                   @"Dirt",                        64,         1,			0,			1,			1,			0,			0,			(float)0.5,			0,			MCMaterialDirt},			
    {MCBlockTypeCobblestone,			@"Cobblestone",                 64,         1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeWoodenPlank,			@"Wooden Plank",                64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeSapling,                @"Sapling",                     64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeBedrock,                @"Bedrock",                     64,			1,			0,			1,			1,			0,			0,			(float)-1,			0,			MCMaterialStone},			
    {MCBlockTypeWater,                  @"Water",                       64,			1,			0,			0,			0,			0,			1,			(float)100,			0,			MCMaterialWater},			
    {MCBlockTypeStationaryWater,		@"Stationary Water",            64,			1,			0,			0,			0,			0,			1,			(float)100,			0,			MCMaterialWater},			
    {MCBlockTypeLava,                   @"Lava",                        64,			1,			0,			0,			0,			0,			0,			(float)100,			0,			MCMaterialLava},			
    {MCBlockTypeStationaryLava,			@"Stationary Lava",             64,			1,			0,			0,			0,			0,			0,			(float)0.0,			0,			MCMaterialLava},			
    {MCBlockTypeSand,                   @"Sand",                        64,			1,			0,			1,			1,			0,			0,			(float)0.5,			0,			MCMaterialSand},			
    {MCBlockTypeGravel,                 @"Gravel",                      64,			1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialSand},			
    {MCBlockTypeGoldOre,                @"Gold Ore",                    64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeIronOre,                @"Iron Ore",                    64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeCoalOre,                @"Coal Ore",                    64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeWood,                   @"Wood",                        64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeLeaves,                 @"Leaves",                      64,			1,			0,			1,			1,			0,			0,			(float)0.2,			0,			MCMaterialLeaves},			
    {MCBlockTypeSponge,                 @"Sponge",                      64,			1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialSponge},			
    {MCBlockTypeGlass,                  @"Glass",                       64,			1,			0,			1,			1,			0,			0,			(float)0.3,			0,			MCMaterialGlass},			
    {MCBlockTypeLapisLazuliOre,         @"Lapislazuli Ore",             64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeLapisLazuliBlock,       @"Lapislazuli",                 64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeDispenser,              @"Dispenser",                   64,			1,			0,			1,			1,			1,			0,			(float)3.5,			0,			MCMaterialStone},			
    {MCBlockTypeSandstone,              @"Sandstone",                   64,			1,			0,			1,			1,			0,			0,			(float)0.8,			0,			MCMaterialStone},			
    {MCBlockTypeNoteBlock,              @"Note Block",                  64,			1,			0,			1,			1,			1,			0,			(float)0.8,			0,			MCMaterialWood},			
    {MCBlockTypeBed_placed,             @"Bed",                         1,          1,			0,			1,			1,			1,			0,			(float)0.2,			0,			MCMaterialWool},			
    {MCBlockTypePoweredRail,            @"Powered Rail",                64,			1,			0,			0,			1,			0,			1,			(float)0.7,			0,			MCMaterialRedstone},			
    {MCBlockTypeDetectorRail,           @"Detector Rail",               64,			1,			0,			0,			1,			0,			1,			(float)0.7,			0,			MCMaterialRedstone},			
    {MCBlockTypeStickyPiston,           @"Sticky Piston",               64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeCobweb,                 @"Cobweb",                      64,			1,			0,			1,			1,			0,			0,			(float)4,			0,			MCMaterialWool},			
    {MCBlockTypeTallGrass,              @"Grass",                       64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialCrops},			
    {MCBlockTypeDeadShrub,              @"Dead Shrub",                  64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialCrops},			
    {MCBlockTypePiston,                 @"Piston",                      64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypePistonHead,             @"Piston Head",                 64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeWool,                   @"Wool",                        64,			0,			0,			1,			1,			0,			0,			(float)0.8,			0,			MCMaterialWool},			
    {MCBlockTypeBlock36,                @"",                            64,			1,			0,			0,			1,			1,			1,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeYellowFlower,           @"Yellow Flower",               64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeRedRose,                @"Red Rose",                    64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeBrownMushroom,			@"Brown Mushroom",              64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeRedMushroom,			@"Red Mushroom",                64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeGoldBlock,              @"Gold Block",                  64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialIron},			
    {MCBlockTypeIronBlock,              @"Iron Block",                  64,			1,			0,			1,			1,			0,			0,			(float)5,			0,			MCMaterialIron},			
    {MCBlockTypeDoubleSlab,             @"Double Slab",                 64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeSlab,                   @"Slab",                        64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeBrick,                  @"Brick",                       64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeTnt,                    @"Tnt",                         64,			1,			0,			1,			1,			0,			0,			(float)0.0,			0,			MCMaterialTnt},			
    {MCBlockTypeBookshelf,              @"Bookshelf",                   64,			1,			0,			1,			1,			0,			0,			(float)1.5,			0,			MCMaterialWood},			
    {MCBlockTypeMossStone,              @"Mossy",                       64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeObsidian,               @"Obsidian",                    64,			1,			0,			1,			1,			0,			0,			(float)50,			0,			MCMaterialStone},			
    {MCBlockTypeTorch,                  @"Torch",                       64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeFire,                   @"Fire",                        64,			1,			0,			0,			0,			0,			0,			(float)0.0,			0,			MCMaterialFire},			
    {MCBlockTypeMonsterSpawner,         @"Monster Spawner",             64,			1,			0,			1,			1,			0,			0,			(float)5,			0,			MCMaterialStone},			
    {MCBlockTypeWoodenStairs,			@"Stairs",                      64,			1,			0,			1,			1,			0,			0,			(float)0,			0,			MCMaterialWood},			
    {MCBlockTypeChest,                  @"Chest",                       64,			1,			0,			1,			1,			1,			0,			(float)2.5,			0,			MCMaterialWood},			
    {MCBlockTypeRedstoneWire_placed,	@"Redstone Wire",               64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeDiamondOre,             @"Diamond Ore",                 64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeDiamondBlock,			@"Diamond Block",               64,			1,			0,			1,			1,			0,			0,			(float)5,			0,			MCMaterialIron},			
    {MCBlockTypeCraftingTable,			@"Crafting Table",              64,			1,			0,			1,			1,			1,			0,			(float)2.5,			0,			MCMaterialWood},			
    {MCBlockTypeCrops,                  @"Crops",                       64,			1,			0,			0,			1,			0,			0,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeFarmland,               @"Farmland",                    64,			1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialDirt},			
    {MCBlockTypeFurnace,                @"Furnace",                     64,			1,			0,			1,			1,			1,			0,			(float)3.5,			0,			MCMaterialStone},			
    {MCBlockTypeBurningFurnace,			@"Burning Furnace",             64,			1,			0,			1,			1,			1,			0,			(float)3.5,			0,			MCMaterialStone},			
    {MCBlockTypeSignPost_placed,        @"Sign",                        1,          1,			0,			0,			1,			0,			1,			(float)1.0,			0,			MCMaterialWood},			
    {MCBlockTypeWoodenDoor_placed,      @"Wooden Door",                 1,          1,			0,			1,			1,			1,			0,			(float)3,			0,			MCMaterialWood},			
    {MCBlockTypeLadder,                 @"Ladder",                      64,			1,			0,			1,			1,			0,			0,			(float)0.4,			0,			MCMaterialRedstone},			
    {MCBlockTypeMinecartTracks,			@"Rail",                        64,			1,			0,			0,			1,			0,			1,			(float)0.7,			0,			MCMaterialRedstone},			
    {MCBlockTypeCobblestoneStairs,		@"Cobblestone Stairs",          64,			1,			0,			1,			1,			0,			0,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeWallSign_placed,        @"Sign",                        1,          1,			0,			0,			1,			0,			1,			(float)1.0,			0,			MCMaterialWood},			
    {MCBlockTypeLever,                  @"Lever",                       64,			1,			0,			0,			1,			1,			1,			(float)0.5,			0,			MCMaterialRedstone},			
    {MCBlockTypeStonePressurePlate,     @"Pressure Plate",              64,			1,			0,			0,			1,			0,			1,			(float)0.5,			0,			MCMaterialStone},			
    {MCBlockTypeIronDoor_placed,        @"Iron Door",                   1,          1,			0,			1,			1,			1,			0,			(float)5,			0,			MCMaterialIron},			
    {MCBlockTypeWoodenPressurePlate,	@"Pressure Plate",              64,			1,			0,			0,			1,			0,			1,			(float)0.5,			0,			MCMaterialWood},			
    {MCBlockTypeRedstoneOre,			@"Redstone Ore",                64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeGlowingRedstoneOre,		@"Glowing Redstone Ore",        64,			1,			0,			1,			1,			0,			0,			(float)3,			0,			MCMaterialStone},			
    {MCBlockTypeRedstoneTorchOff_placed,@"Redstone Torch",              64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeRedstoneTorchOn,		@"Redstone Torch",              64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeStoneButton,			@"Stone Button",                64,			1,			0,			0,			1,			1,			1,			(float)0.5,			0,			MCMaterialRedstone},			
    {MCBlockTypeSnow,                   @"Snow",                        64,			1,			0,			0,			1,			0,			1,			(float)0.1,			0,			MCMaterialSnow},			
    {MCBlockTypeIce,                    @"Ice",                         64,			1,			0,			1,			1,			0,			0,			(float)0.5,			0,			MCMaterialIce},			
    {MCBlockTypeSnowBlock,              @"Snow Block",                  64,			1,			0,			1,			1,			0,			0,			(float)0.2,			0,			MCMaterialSnowBlock},			
    {MCBlockTypeCactus,                 @"Cactus",                      64,			1,			0,			1,			1,			0,			0,			(float)0.4,			0,			MCMaterialCactus},			
    {MCBlockTypeClay,                   @"Clay",                        64,			1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialClay},			
    {MCBlockTypeSugarCane_placed,       @"Sugar Cane",                  64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeJukebox,                @"Jukebox",                     64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeFence,                  @"Fence",                       64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypePumpkin,                @"Pumpkin",                     64,         1,			0,			1,			1,			0,			0,			(float)1.0,			0,			MCMaterialPumpkin},			
    {MCBlockTypeNetherrack,             @"Netherrack",                  64,			1,			0,			1,			1,			0,			0,			(float)0.4,			0,			MCMaterialStone},			
    {MCBlockTypeSoulSand,               @"SoulSand",                    64,			1,			0,			1,			1,			0,			0,			(float)0.5,			0,			MCMaterialSand},			
    {MCBlockTypeGlowstone,              @"Glowstone",                   64,			1,			0,			1,			1,			0,			0,			(float)0.3,			0,			MCMaterialGlass},			
    {MCBlockTypePortal,                 @"Portal",                      64,			1,			0,			0,			1,			0,			1,			(float)-1,			0,			MCMaterialPortal},			
    {MCBlockTypeJackOLantern,			@"Jack-O-Lantern",              64,			1,			0,			1,			1,			0,			0,			(float)1.0,			0,			MCMaterialPumpkin},			
    {MCBlockTypeCake_placed,			@"Cake",                        1,          1,			0,			1,			1,			1,			0,			(float)0.5,			0,			MCMaterialCake},			
    {MCBlockTypeRedstoneRepeaterOff_placed,@"Repeater",                 64,         1,			0,			1,			1,			1,			0,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeRedstoneRepeaterOn_placed,@"Repeater",                  64,         1,			0,			1,			1,			1,			0,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeLockedChest,			@"Locked Chest",                64,			1,			0,			1,			1,			1,			0,			(float)0,			0,			MCMaterialWood},			
    {MCBlockTypeTrapdoor,               @"Trapdoor",                    64,			1,			0,			1,			1,			1,			0,			(float)3.0,			0,			MCMaterialWood},			
    {MCBlockTypeHiddenSilverfish,		@"Hidden Silverfish",           64,			1,			0,			1,			1,			0,			0,			(float).75,			0,			MCMaterialStone},			
    {MCBlockTypeStoneBricks,			@"Stone Bricks",                64,			1,			0,			1,			1,			0,			0,			(float)1.5,			0,			MCMaterialStone},			
    {MCBlockTypeHugeBrownMushroom,		@"Huge Brown Mushroom",         64,			1,			0,			1,			1,			0,			0,			(float)0.2,			0,			MCMaterialPumpkin},			
    {MCBlockTypeHugeRedMushroom,		@"Huge Red Mushroom",           64,			1,			0,			1,			1,			0,			0,			(float)0.2,			0,			MCMaterialPumpkin},			
    {MCBlockTypeIronBars,               @"Iron Bars",                   64,			1,			0,			1,			1,			0,			0,			(float)5.0,			0,			MCMaterialIron},			
    {MCBlockTypeGlassPane,              @"Glass Pane",                  64,			1,			0,			1,			1,			0,			0,			(float)0.3,			0,			MCMaterialGlass},			
    {MCBlockTypeMelon,                  @"Melon",                       64,			1,			0,			1,			1,			0,			0,			(float)1.0,			0,			MCMaterialPumpkin},			
    {MCBlockTypePumpkinStem,			@"Pumpkin Stem",                64,			1,			0,			0,			1,			0,			0,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeMelonStem,              @"Melon Stem",                  64,			1,			0,			0,			1,			0,			0,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeVines,                  @"Vines",                       64,			1,			0,			0,			1,			0,			0,			(float)0.2,			0,			MCMaterialLeaves},			
    {MCBlockTypeFenceGate,              @"Fence Gate",                  64,			1,			0,			1,			1,			1,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeBrickStairs,            @"Brick Stairs",                64,			1,			0,			1,			1,			0,			0,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeStoneBrickStairs,		@"Stone Brick Stairs",          64,			1,			0,			1,			1,			0,			0,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeMycelium,               @"Mycelium",                    64,			1,			0,			1,			1,			0,			0,			(float)0.6,			0,			MCMaterialDirt},			
    {MCBlockTypeLilyPad,                @"Lily Pad",                    64,			1,			0,			0,			1,			0,			0,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeNetherBrick,			@"Nether Brick",                64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeNetherBrickFence,		@"Nether BrickFence",           64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeNetherBrickStairs,		@"Nether BrickStairs",          64,			1,			0,			1,			1,			0,			0,			(float)0,			0,			MCMaterialStone},			
    {MCBlockTypeNetherWart_placed,		@"Nether Wart",                 64,			1,			0,			0,			1,			0,			0,			(float)0.0,			0,			MCMaterialCrops},			
    {MCBlockTypeEnchantmentTable_placed,@"Enchantment Table",           64,			1,			0,			1,			1,			1,			0,			(float)5.0,			0,			MCMaterialStone},			
    {MCBlockTypeBrewingStand_placed,	@"Brewing Stand",               64,			1,			0,			1,			1,			1,			0,			(float)0.5,			0,			MCMaterialStone},			
    {MCBlockTypeCauldron_placed,		@"Calduron",                    64,			1,			0,			1,			1,			1,			0,			(float)2.0,			0,			MCMaterialStone},			
    {MCBlockTypeEndPortal,              @"End Portal",                  64,			1,			0,			0,			0,			0,			1,			(float)-1,			0,			MCMaterialPortal},			
    {MCBlockTypeEndPortalFrame,			@"End Portal Frame",            64,			1,			0,			1,			0,			1,			0,			(float)-1,			0,			MCMaterialWood},			
    {MCBlockTypeEndStone,               @"End Stone",                   64,			1,			0,			1,			1,			0,			0,			(float)3.0,			0,			MCMaterialStone},			
    {MCBlockTypeDragonEgg,              @"Dragon Egg",                  64,			1,			0,			1,			1,			0,			0,			(float)3.0,			0,			MCMaterialStone},			
    {MCBlockTypeRedstoneLamp_inactive,	@"Redstone Lamp",               64,			1,			0,			1,			1,			0,			0,			(float)0.3,			0,			MCMaterialGlass},			
    {MCBlockTypeRedstoneLamp_active,	@"Redstone Lamp",               64,			1,			0,			1,			1,			0,			0,			(float)0.3,			0,			MCMaterialGlass},			
    {MCBlockTypeWoodenDoubleSlab,		@"Wooden Double Slab",          64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeWoodenSlab,             @"Wooden Slab",                 64,			1,			0,			1,			1,			0,			0,			(float)2.0,			0,			MCMaterialWood},			
    {MCBlockTypeCocoaPlant,             @"Cocoa Plant",                 64,			1,			0,			1,			1,			0,			0,			(float)0.2,			0,			MCMaterialCrops},			
    {MCBlockTypeSandstoneStairs,		@"Sandstone Stairs",            64,			1,			0,			1,			1,			0,			0,			(float)0.0,			0,			MCMaterialStone},			
    {MCBlockTypeEmeraldOre,             @"Emerald Ore",                 64,			1,			0,			1,			1,			0,			0,			(float)3.0,			0,			MCMaterialStone},			
    {MCBlockTypeEnderChest,             @"Ender Chest",                 64,			1,			0,			1,			1,			1,			0,			(float)22.5,		0,			MCMaterialWood},			
    {MCBlockTypeTripwireHook,			@"Tripwire Hook",               64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeTripwire,               @"Tripwire",                    64,			1,			0,			0,			1,			0,			1,			(float)0.0,			0,			MCMaterialRedstone},			
    {MCBlockTypeEmeraldBlock,			@"Emerald Block",               64,			1,			0,			1,			1,			0,			0,			(float)5,			0,			MCMaterialIron},			
    {MCBlockTypeIronShovel,             @"Iron Shovel",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialIron},			
    {MCBlockTypeIronPickaxe,			@"Iron Pickaxe",                1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialIron},			
    {MCBlockTypeIronAxe,                @"Iron Axe",                    1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialIron},			
    {MCBlockTypeFlintAndSteel,			@"Flint And Steel",             1,          0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeApple,                  @"Apple",                       64,         0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBow,                    @"Bow",                         1,          0,			1,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeArrow,                  @"Arrow",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCoal,                   @"Coal",                        64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeDiamond,                @"Diamond",                     64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeIronIngot,              @"Iron Ingot",                  64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldIngot,              @"Gold Ingot",                  64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeIronSword,              @"Iron Sword",                  1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialIron},			
    {MCBlockTypeWoodenSword,			@"Wooden Sword",                1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialWood},			
    {MCBlockTypeWoodenShovel,			@"Wooden Shovel",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialWood},			
    {MCBlockTypeWoodenPickaxe,			@"Wooden Pickaxe",              1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialWood},			
    {MCBlockTypeWoodenAxe,              @"Wooden Axe",                  1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialWood},			
    {MCBlockTypeStoneSword,             @"Stone Sword",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialStone},			
    {MCBlockTypeStoneShovel,			@"Stone Shovel",                1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialStone},			
    {MCBlockTypeStonePickaxe,			@"Stone Pickaxe",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialStone},			
    {MCBlockTypeStoneAxe,               @"Stone Axe",                   1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialStone},			
    {MCBlockTypeDiamondSword,			@"Diamond Sword",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialDiamond},			
    {MCBlockTypeDiamondShovel,			@"Diamond Shovel",              1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialDiamond},			
    {MCBlockTypeDiamondPickaxe,			@"Diamond Pickaxe",             1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialDiamond},			
    {MCBlockTypeDiamondAxe,             @"Diamond Axe",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialDiamond},			
    {MCBlockTypeStick,                  @"Stick",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBowl,                   @"Bowl",                        64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMushroomStew,			@"Mushroom Stew",               1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldSword,              @"Gold Sword",                  1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialGold},			
    {MCBlockTypeGoldShovel,			    @"Gold Shovel",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialGold},			
    {MCBlockTypeGoldPickaxe,			@"Gold Pickaxe",                1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialGold},			
    {MCBlockTypeGoldAxe,                @"Gold Axe",                    1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialGold},			
    {MCBlockTypeString,                 @"String",                      64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeFeather,                @"Feather",                     64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGunpowder,              @"Gunpowder",                   64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWoodenHoe,              @"Wooden Hoe",                  1,          1,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialWood},			
    {MCBlockTypeStoneHoe,               @"Stone Hoe",                   1,          1,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialStone},			
    {MCBlockTypeIronHoe,                @"Iron Hoe",                    1,          1,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialIron},			
    {MCBlockTypeDiamondHoe,             @"Diamond Hoe",                 1,          1,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialDiamond},			
    {MCBlockTypeGoldHoe,                @"Gold Hoe",                    1,          1,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialGold},			
    {MCBlockTypeSeeds,                  @"Seeds",                       64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWheat,                  @"Wheat",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBread,                  @"Bread",                       64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeLeatherHelmet,			@"Leather Helmet",              1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeLeatherChestplate,		@"Leather Chestplate",          1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeLeatherLeggings,		@"Leather Leggings",            1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeLeatherBoots,			@"Leather Boots",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeChainmailHelmet,		@"Chainmail Helmet",            1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeChainmailChestplate,	@"Chainmail Chestplate",        1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeChainmailLeggings,		@"Chainmail Leggings",          1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeChainmailBoots,			@"Chainmail Boots",             1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeIronHelmet,             @"Iron Helmet",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeIronChestplate,         @"Iron Chestplate",             1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeIronLeggings,			@"Iron Leggings",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeIronBoots,              @"Iron Boots",                  1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeDiamondHelmet,			@"Diamond Helmet",              1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeDiamondChestplate,		@"Diamond Chestplate",          1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeDiamondLeggings,		@"Diamond Leggings",            1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeDiamondBoots,			@"Diamond Boots",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldHelmet,             @"Gold Helmet",                 1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldChestplate,			@"Gold Chestplate",             1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldLeggings,			@"Gold Leggings",               1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldBoots,              @"Gold Boots",                  1,          0,			0,			0,			1,			0,			1,			(float)0,			1,			MCMaterialNoMaterial},			
    {MCBlockTypeFlint,                  @"Flint",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRawPorkchop,			@"Raw Porkchop",                64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCookedPorkchop,			@"Cooked Porkchop",             64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypePainting,               @"Painting",                    64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldenApple,			@"Golden Apple",                64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSign,                   @"Sign",                        1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWoodenDoor,             @"Wooden Door",                 1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBucket,                 @"Bucket",                      1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWaterBucket,			@"Water Bucket",                1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeLavaBucket,             @"Lava Bucket",                 1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMinecart,               @"Minecart",                    1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSaddle,                 @"Saddle",                      1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeIronDoor,               @"Iron Door",                   1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRedstone,               @"Redstone",                    64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSnowball,               @"Snowball",                    16,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBoat,                   @"Boat",                        1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeLeather,                @"Leather",                     64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMilkBucket,             @"Milk Bucket",                 1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeClayBrick,              @"Clay Brick",                  64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeClayBall,               @"Clay Ball",                   64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSugarCane,              @"Sugar Cane",                  64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypePaper,                  @"Paper",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBook,                   @"Book",                        64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSlimeball,              @"Slimeball",                   64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeStorageMinecart,		@"Storage Minecart",            1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypePoweredMinecart,        @"Powered Minecart",            1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeEgg,                    @"Egg",                         16,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCompass,                @"Compass",                     64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeFishingRod,             @"Fishing Rod",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeClock,                  @"Clock",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGlowstoneDust,          @"Glowstone Dust",              64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRawFish,                @"Raw Fish",                    64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCookedFish,             @"Cooked Fish",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeInkSac,                 @"Ink Sac",                     64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBone,                   @"Bone",                        64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSugar,                  @"Sugar",                       64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCake,                   @"Cake",                        1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBed,                    @"Bed",                         1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRedstoneRepeater,		@"Redstone Repeater",           64,         1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCookie,                 @"Cookie",                      8,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMap,                    @"Map",                         1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeShears,                 @"Shears",                      1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMelonSlice,             @"Melon Slice",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypePumpkinSeeds,           @"Pumpkin Seeds",               64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMelonSeeds,             @"Melon Seeds",                 64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRawBeef,                @"Raw Beef",                    64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSteak,                  @"Steak",                       64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRawChicken,             @"Raw Chicken",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCookedChicken,          @"Cooked Chicken",              64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeRottenFlesh,			@"Rotten Flesh",                64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeEnderPearl,             @"Ender Pearl",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBlazeRod,               @"Blaze Rod",                   64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGhastTear,              @"Ghast Tear",                  64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGoldNugget,             @"Gold Nugget",                 64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeNetherWart,             @"Nether Wart",                 64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypePotion,                 @"Potion",                      1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGlassBottle,			@"Glass Bottle",                64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSpiderEye,              @"Spider Eye",                  64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeFermentedSpiderEye,		@"Fermented Spider Eye",        64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBlazePowder,			@"Blaze Powder",                64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMagmaCream,             @"Magma Cream",                 64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBrewingStand,			@"Brewing Stand",               64,			1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCauldron,               @"Cauldron",                    1,          1,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeEyeOfEnder,             @"Eye Of Ender",                64,         0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeGlisteringMelon,        @"Glistering Melon",            64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeSpawnEgg,               @"Spawn Egg",                   64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBottleOEnchanting,		@"Bottle-O-Enchanting",         64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeFireCharge,             @"Fire Charge",                 64,			0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBookAndQuill,			@"Book And Quill",              1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWrittenBook,			@"Written Book",                1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeEmerald,                @"Emerald",                     64,			0,			0,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeThirteenDisc,			@"Thirteen Disc",               1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeCatDisc,                @"Cat Disc",                    1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeBlocksDisc,             @"Blocks Disc",                 1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeChirpDisc,              @"Chirp Disc",                  1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeFarDisc,                @"Far Disc",                    1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMallDisc,               @"Mall Disc",                   1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeMellohiDisc,            @"Mellohi Disc",                1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeStalDisc,               @"Stal Disc",                   1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeStradDisc,              @"Strad Disc",                  1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeWardDisc,               @"Ward Disc",                   1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},			
    {MCBlockTypeElevenDisc,             @"Eleven Disc",                 1,          0,			1,			0,			1,			0,			1,			(float)0,			0,			MCMaterialNoMaterial},		
    {-2}
};

MCItem getItem(short value, char metadata)
{
    short index = 0;
    MCItem nowChecking = itemTable[0];
    while (nowChecking.value != -2) {
        nowChecking = itemTable[index];
        if (nowChecking.value == value) {
            return nowChecking;
        }
        index++;
    }
    return itemTable[0];
}

BOOL canHarvest(MCTool tool, MCItem block)
{
    if (block.material != MCMaterialStone && block.material != MCMaterialIron && block.material != MCMaterialSnow && block.material != MCMaterialSnowBlock) {
        return YES;
    }
    switch (tool.tool) {
        case MCBlockToolNone:
            return NO;
            break;
        case MCBlockToolShovel:
            switch (block.value) {
                case MCBlockTypeSnow:
                case MCBlockTypeSnowBlock:
                    return YES;
                    break;
                default:
                    break;
            }
            break;
        case MCBlockToolPickaxe:
            switch (tool.level) {
                case 3:
                    switch (block.value) {
                        case MCBlockTypeObsidian:
                            return YES;
                        default:
                            break;
                    }
                case 2:
                    switch (block.value) {
                        case MCBlockTypeDiamondBlock:
                        case MCBlockTypeDiamondOre:
                        case MCBlockTypeGoldBlock:
                        case MCBlockTypeGoldOre:
                        case MCBlockTypeRedstone:
                        case MCBlockTypeGlowingRedstoneOre:
                            return YES;
                            break;
                            
                        default:
                            break;
                    }
                case 1:
                    switch (block.value) {
                        case MCBlockTypeIronBlock:
                        case MCBlockTypeIronOre:
                        case MCBlockTypeLapisLazuliBlock:
                        case MCBlockTypeLapisLazuliOre:
                            return YES;
                            break;
                            
                        default:
                            break;
                    }
                    switch (block.material) {
                        case MCMaterialIron:
                        case MCMaterialStone:
                            return YES;
                        default:
                            break;
                    }
                default:
                    break;
            }
            break;
        case MCBlockToolShears:
        {
            switch (block.material) {
                case MCMaterialLeaves:
                case MCMaterialWool:
                    return YES;
                    break;
                    
                default:
                    break;
            }
        }
        case MCBlockToolSword:
        {
            if (block.value == MCBlockTypeCobweb) {
                return YES;
            }
        }
        default:
            break;
    }
    return NO;
}
BOOL isEffective(MCTool tool, MCItem block)
{
    switch (tool.tool) {
        case MCBlockToolShovel:
            switch (block.material) {
                case MCMaterialClay:
                case MCMaterialDirt:
                case MCMaterialSand:
                case MCMaterialSnow:
                case MCMaterialSnowBlock:
                    return YES;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case MCBlockToolAxe:
            switch (block.material) {
                case MCMaterialWood:
                    return YES;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case MCBlockToolPickaxe:
            switch (block.material) {
                case MCMaterialIron:
                case MCMaterialStone:
                    return YES;
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return NO;
}
float toolEffectiveness(MCTool tool, MCItem block)
{
    if (isEffective(tool, block)) {
        return (tool.level+1)*2.0f;
    }
    return 1.0f;
}
double blockStrengthPerTick(MCTool tool, MCItem block, BOOL onGround, BOOL underwater)
{
    double mult=1.0f;
    if (underwater || !onGround) {
        mult /= 5;
    }
    if (block.hardness < 0) {
        return 0;
    }
    if (!canHarvest(tool, block)) {
        return mult / block.hardness  / 100.0f;
    }
    if (isEffective(tool, block)) {
        mult *= toolEffectiveness(tool, block);
    }
    return mult / block.hardness / 30.0f;
    return 0;
}
