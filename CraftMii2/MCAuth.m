//
//  MCAuth.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCAuth.h"
@interface NSData (SHA1)
- (NSString*)sha1DigestString;
- (NSData*)encryptWithPublicKey:(NSData*)pubKey;
@end
@class MCSocket;
@implementation MCAuth
@synthesize username, password, isKeepingAlive;
+(MCAuth*)authWithUsername:(NSString*)user andPassword:(NSString*)pass
{
    MCAuth* ret = [[[MCAuth alloc] init] autorelease];
    [ret setUsername:user];
    [ret setPassword:pass];
    [ret setIsKeepingAlive:NO];
    return ret;
}
-(MCAuth*)initWithUsername:(NSString*)user andPassword:(NSString*)pass
{
    [self setUsername:user];
    [self setPassword:pass];
    [self setIsKeepingAlive:NO];
    return self;
}
-(void)keepAlive
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    while (sleep(280)&&[self isKeepingAlive]) {
        [pool drain];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://login.minecraft.net/session?name=%@&session=%@", [self username], [[self login] objectForKey:kMCAuthToken]]]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        [request release];
        pool = [NSAutoreleasePool new];
    }
    [pool drain];
}
-(BOOL)joinToServerWithPubKey:(NSData*)pkey andSID:(NSString*)serverid andSSecret:(NSData*)secret
{
    NSString* hash = serverid;
    if ([serverid isEqualToString:@"-"] || [serverid isEqualToString:@"+"]) {
        goto end;
    }
    NSMutableData* dt = [NSMutableData new];
    [dt appendBytes:[serverid UTF8String] length:[serverid length]];
    [dt appendData:pkey];
    [dt appendData:secret];
    hash = [dt sha1DigestString];
    [dt release];
end:
    return [self joinToServer:hash];
}
-(BOOL)joinToServer:(NSString*)token
{
    if ([token isEqualToString:@"-"] || [token isEqualToString:@"+"]) {
        NSLog(@"Offline mode server. [%@]", token);
        return YES;
    }
    NSDictionary* logData=[self login];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://session.minecraft.net/game/joinserver.jsp?user=%@&sessionId=%@&serverId=%@", [self username], [logData objectForKey:kMCAuthToken], token]]] autorelease];
    NSString *serverResponse = [[[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] encoding:NSUTF8StringEncoding] autorelease];
    if ([serverResponse isEqualToString:@"OK"]) {
        return YES;
    }
    [[self login] setValue:serverResponse forKey:kMCAuthError];
    return NO;
}
-(NSDictionary*)login
{
    if (!loginDict) {
        loginDict = [[NSMutableDictionary alloc] init];
        [loginDict setValue:[NSNull null] forKey:kMCAuthError];
        [loginDict setValue:[NSNull null] forKey:kMCAuthResult];
        [loginDict setValue:[NSNull null] forKey:kMCAuthToken];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://login.minecraft.net/?user=%@&password=%@&version=12", [self username], [self password]]]] autorelease];
        NSString *serverResponse = [[[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] encoding:NSUTF8StringEncoding] autorelease];
        NSArray* kr=[serverResponse componentsSeparatedByString:@":"];
        if ([kr count]==4) {
            [self setUsername:[kr objectAtIndex:2]];
            [loginDict setValue:[kr objectAtIndex:3] forKey:kMCAuthToken];
            [loginDict setValue:@"Success" forKey:kMCAuthResult];
        } else {
            [loginDict setValue:serverResponse forKey:kMCAuthResult];
            [loginDict setValue:serverResponse forKey:kMCAuthError];
            [self setIsKeepingAlive:NO];
            return loginDict;
        }
        [self performSelectorInBackground:@selector(keepAlive) withObject:nil];
        [self setIsKeepingAlive:YES];
    }
    return loginDict;
}
-(oneway void)dealloc
{
    [self setPassword:nil];
    [self setUsername:nil];
    [super dealloc];
}
@end
