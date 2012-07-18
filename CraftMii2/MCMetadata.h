//
//  MCMetadata.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEntity.h"
@class MCSocket;
@class MCEntity;
@interface MCMetadata : NSObject <NSStreamDelegate>
{
    id oldDelegate;
    id stream;
    MCEntity* entity;
    char* buffer;
    char* kbuffer;
    int blen;
    int dlen;
    NSMutableArray* metadata;
    int bytestoread;
    NSString* etype;
}
@property(retain) id oldDelegate;
@property(retain) id stream;
@property(retain) NSMutableArray* metadata;
@property(retain) NSString* etype;
@property(retain) MCEntity* entity;
@property(assign) MCSocket* socket;
@property(assign) char* buffer;
@property(assign) char* kbuffer;
+(MCMetadata*)metadataWithSocket:(MCSocket*)socket andEntity:(MCEntity*)aentity andType:(NSString*)etype;
-(void)initValues;
@end
