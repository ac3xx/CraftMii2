//
//  MCAuth.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMCAuthResult @"kMCAuthResult"
#define kMCAuthToken @"kMCAuthToken"
#define kMCAuthError @"kMCAuthError"

@interface MCAuth : NSObject
{
    NSString* username;
    NSString* password;
    BOOL isKeepingAlive;
    NSDictionary* loginDict;
}
@property(retain) NSString* username;
@property(retain) NSString* password;
@property(assign) BOOL isKeepingAlive;
+(MCAuth*)authWithUsername:(NSString*)user andPassword:(NSString*)pass;
-(MCAuth*)initWithUsername:(NSString*)user andPassword:(NSString*)pass;
-(NSDictionary*)login;
-(BOOL)joinToServer:(NSString*)lol;
-(BOOL)joinToServerWithPubKey:(NSData*)pkey andSID:(NSString*)serverid andSSecret:(NSData*)secret;
@end
