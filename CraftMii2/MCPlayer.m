//
//  MCPlayer.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPlayer.h"
#import "MCItem.h"
#define MCSlipperiness(block) ((block == MCBlock

/*
 return worldObj.isMaterialInBB(boundingBox.expand(-0.10000000149011612D, -0.40000000596046448D, -0.10000000149011612D), Material.lava);
 return worldObj.isMaterialInBB(boundingBox.expand(-0.10000000149011612D, -0.40000000596046448D, -0.10000000149011612D), Material.water);
 protected void fall(float par1)
 {
 super.fall(par1);
 int i = (int)Math.ceil(par1 - 3F);
 
 if (i > 0)
 {
 if (i > 4)
 {
 worldObj.playSoundAtEntity(this, "damage.fallbig", 1.0F, 1.0F);
 }
 else
 {
 worldObj.playSoundAtEntity(this, "damage.fallsmall", 1.0F, 1.0F);
 }
 
 attackEntityFrom(DamageSource.fall, i);
 int j = worldObj.getBlockId(MathHelper.floor_double(posX), MathHelper.floor_double(posY - 0.20000000298023224D - (double)yOffset), MathHelper.floor_double(posZ));
 
 if (j > 0)
 {
 StepSound stepsound = Block.blocksList[j].stepSound;
 worldObj.playSoundAtEntity(this, stepsound.getStepSound(), stepsound.getVolume() * 0.5F, stepsound.getPitch() * 0.75F);
 }
 }
 }
 
 public void moveFlying(float par1, float par2, float par3)
 {
 float f = MathHelper.sqrt_float(par1 * par1 + par2 * par2);
 
 if (f < 0.01F)
 {
 return;
 }
 
 if (f < 1.0F)
 {
 f = 1.0F;
 }
 
 f = par3 / f;
 par1 *= f;
 par2 *= f;
 float f1 = MathHelper.sin((rotationYaw * (float)Math.PI) / 180F);
 float f2 = MathHelper.cos((rotationYaw * (float)Math.PI) / 180F);
 motionX += par1 * f2 - par2 * f1;
 motionZ += par2 * f2 + par1 * f1;
 }
 
 public void moveEntityWithHeading(float par1, float par2)
 {
 if (isInWater())
 {
 double d = posY;
 moveFlying(par1, par2, isAIEnabled() ? 0.04F : 0.02F);
 moveEntity(motionX, motionY, motionZ);
 motionX *= 0.80000001192092896D;
 motionY *= 0.80000001192092896D;
 motionZ *= 0.80000001192092896D;
 motionY -= 0.02D;
 
 if (isCollidedHorizontally && isOffsetPositionInLiquid(motionX, ((motionY + 0.60000002384185791D) - posY) + d, motionZ))
 {
 motionY = 0.30000001192092896D;
 }
 }
 else if (handleLavaMovement())
 {
 double d1 = posY;
 moveFlying(par1, par2, 0.02F);
 moveEntity(motionX, motionY, motionZ);
 motionX *= 0.5D;
 motionY *= 0.5D;
 motionZ *= 0.5D;
 motionY -= 0.02D;
 
 if (isCollidedHorizontally && isOffsetPositionInLiquid(motionX, ((motionY + 0.60000002384185791D) - posY) + d1, motionZ))
 {
 motionY = 0.30000001192092896D;
 }
 }
 else
 {
 float f = 0.91F;
 
 if (onGround)
 {
 f = 0.5460001F;
 int i = worldObj.getBlockId(MathHelper.floor_double(posX), MathHelper.floor_double(boundingBox.minY) - 1, MathHelper.floor_double(posZ));
 
 if (i > 0)
 {
 f = Block.blocksList[i].slipperiness * 0.91F;
 }
 }
 
 float f1 = 0.1627714F / (f * f * f);
 float f2;
 
 if (onGround)
 {
 if (isAIEnabled())
 {
 f2 = getAIMoveSpeed();
 }
 else
 {
 f2 = landMovementFactor;
 }
 
 f2 *= f1;
 }
 else
 {
 f2 = jumpMovementFactor;
 }
 
 moveFlying(par1, par2, f2);
 f = 0.91F;
 
 if (onGround)
 {
 f = 0.5460001F;
 int j = worldObj.getBlockId(MathHelper.floor_double(posX), MathHelper.floor_double(boundingBox.minY) - 1, MathHelper.floor_double(posZ));
 
 if (j > 0)
 {
 f = Block.blocksList[j].slipperiness * 0.91F;
 }
 }
 
 if (isOnLadder())
 {
 float f3 = 0.15F;
 
 if (motionX < (double)(-f3))
 {
 motionX = -f3;
 }
 
 if (motionX > (double)f3)
 {
 motionX = f3;
 }
 
 if (motionZ < (double)(-f3))
 {
 motionZ = -f3;
 }
 
 if (motionZ > (double)f3)
 {
 motionZ = f3;
 }
 
 fallDistance = 0.0F;
 
 if (motionY < -0.14999999999999999D)
 {
 motionY = -0.14999999999999999D;
 }
 
 boolean flag = isSneaking() && (this instanceof EntityPlayer);
 
 if (flag && motionY < 0.0D)
 {
 motionY = 0.0D;
 }
 }
 
 moveEntity(motionX, motionY, motionZ);
 
 if (isCollidedHorizontally && isOnLadder())
 {
 motionY = 0.20000000000000001D;
 }
 
 motionY -= 0.080000000000000002D;
 motionY *= 0.98000001907348633D;
 motionX *= f;
 motionZ *= f;
 }
 
 field_705_Q = field_704_R;
 double d2 = posX - prevPosX;
 double d3 = posZ - prevPosZ;
 float f4 = MathHelper.sqrt_double(d2 * d2 + d3 * d3) * 4F;
 
 if (f4 > 1.0F)
 {
 f4 = 1.0F;
 }
 
 field_704_R += (f4 - field_704_R) * 0.4F;
 field_703_S += field_704_R;
 }
*/
/*
 @property(assign) BOOL crouched;
 @property(assign) BOOL sprinting;
 - (double)stance;
 - (double)speedPerTick;
*/
/*
 Every tick, most living entities (players, non-flying mobs) have their vertical speed decreased by 0.08 (blocks per tick), then multiplied by 0.98
 */

@implementation MCPlayer
@synthesize crouched, sprinting, flying;
- (double)stance
{
    return [self y] + (crouched ? 1.5399f : 1.6200f);
}
- (void)moveWithYaw:(double)yaw_
{
    if ([self isOnWater]) {
        [self moveFlying:yaw_ andFactor:0.02f];
    }
    return;
}
- (void)moveVector:(MCVector)vector
{
    if ([self isOnWeb]) {
        vector.x *= 0.25f;
        vector.y *= 0.05f;
        vector.z *= 0.25f;
        vx = 0.0f;
        vy = 0.0f;
        vz = 0.0f;
    }
}
- (void)moveFlying:(float)yaw_ andFactor:(float)factor
{
    float f = sqrtf(yaw_ * yaw_ + pitch + pitch);
    if (f < 0.01f) {
        return;
    }
    if (f < 1.0F) {
        f = 1.0F;
    }
    f = factor / f;
    yaw *= f;
    pitch *= f;
    float f1 = sinf((yaw * M_PI) / 180.0f);
    float f2 = cosf((yaw * M_PI) / 180.0f);
    vx = yaw * f2 - pitch * f1;
    vz = pitch * f2 + yaw * f1;
}
- (BOOL)isOnWeb
{
    return NO;
}
- (BOOL)isOnWater
{
    return NO;
}
- (BOOL)isOnLava
{
    return NO;
}
- (BOOL)isOnLadder
{
    return NO;
}
- (BOOL)isFalling
{
    return NO;
}
- (BOOL)onGround
{
    return onGround;
}
- (void)onServerTick
{
    
}
@end
