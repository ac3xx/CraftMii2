#import <Foundation/Foundation.h>


@interface NSData (libzadditions)

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

// RSA

- (NSData*)encryptWithPublicKey:(NSData*)pubKey;

@end
