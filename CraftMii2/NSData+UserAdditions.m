#import "NSData+UserAdditions.h"
#include <zlib.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>

@implementation NSData (libzadditions)

- (NSData *)zlibInflate
{
	if ([self length] == 0) return self;
    
	unsigned full_length = [self length];
	unsigned half_length = [self length] / 2;
    
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
    
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
    
	if (inflateInit (&strm) != Z_OK) return nil;
    
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
        
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
    
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	else return nil;
}

- (NSData *)zlibDeflate
{
	if ([self length] == 0) return self;
	
	z_stream strm;
    
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = [self length];
    
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
    
	if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) != Z_OK) return nil;
    
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chuncks for expansion
    
	do {
        
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData: compressed];
}

- (NSData *)gzipInflate
{
	if ([self length] == 0) return self;
	
	unsigned full_length = [self length];
	unsigned half_length = [self length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	else return nil;
}

- (NSData *)gzipDeflate
{
	if ([self length] == 0) return self;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = [self length];
	
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData:compressed];
}

- (NSData*)encryptWithPublicKey:(NSData*)pubKey
{
    char* pt = malloc([self length]);
    const unsigned char* pkdata = [pubKey bytes];
    EVP_PKEY* pk = d2i_PublicKey(EVP_PKEY_RSA, NULL, &pkdata, [pubKey length]);
    if (!pk) {
        puts(ERR_error_string(0,NULL));
        return nil;
    }
    RSA* rsa = EVP_PKEY_get1_RSA(pk);
    RSA_public_encrypt([self length], [self bytes], (unsigned char*)pt, rsa, RSA_NO_PADDING);
    return [NSData dataWithBytesNoCopy:pt length:[self length] freeWhenDone:YES];
}


@end

//
//  SHA-1 NSData 4 iPhone
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright (c) 2008 Geoff Garside
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Based on, believed to be public domain, source code available at
//  http://www.cocoadev.com/index.pl?NSDataCategory, though modified
//  to use the CommonCrypto API available on Mac OS and iPhone platforms.
//

#include <CommonCrypto/CommonDigest.h>

@implementation NSData (SHA1)

#pragma mark -
#pragma mark SHA1 Hashing macros
#define HEComputeDigest(method)                                         \
CC_##method##_CTX ctx;                                              \
unsigned char digest[CC_##method##_DIGEST_LENGTH];                  \
CC_##method##_Init(&ctx);                                           \
CC_##method##_Update(&ctx, [self bytes], [self length]);            \
CC_##method##_Final(digest, &ctx);

#define HEComputeDigestNSData(method)                                   \
HEComputeDigest(method)                                             \
return [NSData dataWithBytes:digest length:CC_##method##_DIGEST_LENGTH];

#define HEComputeDigestNSString(method)                                 \
static char __HEHexDigits[] = "0123456789abcdef";                   \
unsigned char digestString[2*CC_##method##_DIGEST_LENGTH + 1];      \
unsigned int i;                                                     \
HEComputeDigest(method)                                             \
for(i=0; i<CC_##method##_DIGEST_LENGTH; i++) {                      \
digestString[2*i]   = __HEHexDigits[digest[i] >> 4];            \
digestString[2*i+1] = __HEHexDigits[digest[i] & 0x0f];          \
}                                                                   \
digestString[2*CC_##method##_DIGEST_LENGTH] = '\0';                 \
return [NSString stringWithCString:(char *)digestString encoding:NSASCIIStringEncoding];

#pragma mark -
#pragma mark SHA1 Hashing routines
- (NSData*) sha1Digest
{
	HEComputeDigestNSData(SHA1);
}
- (NSString*) sha1DigestString
{
	HEComputeDigestNSString(SHA1);
}

@end
