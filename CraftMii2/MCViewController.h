//
//  MCViewController.h
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MCSocket.h"

@interface MCViewController : GLKViewController <MCSocketDelegate>
{
    MCSocket* socket;
    BOOL canSendPackets;
    int tickCount;
    int add;
    UIProgressView* expview;
    UILabel* levelview;
    UIAlertView* respawnAlert;
    UIProgressView* lifeview;
    UIProgressView* foodview;
    UIProgressView* satview_;
    unsigned int joypadCenterX;
    unsigned int joypadCenterY;
    unsigned int joypadRadius;
    unsigned int joypadWidth;
    unsigned int joypadHeight;
    int touchHash;
    int touchHash2;
    CGPoint sPoint;
    float mAngle;
    float sAngle;
    float touchAngle;
    float touchDistance;
    UIImageView* joypadCap;
    UIImageView* joypad;
    BOOL joypadMoving;
    GLuint textures[1];
}
@property(retain)MCSocket* socket;

@end
