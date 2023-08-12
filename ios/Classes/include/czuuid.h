//
//  czuuid.h
//  Cryptor
//
//  Created by Sean Zhu on 2018/9/18.
//  Copyright © 2018 Chirpeur. All rights reserved.
//

#ifndef CZUUID_H
#define CZUUID_H

#ifdef __cplusplus
extern "C" {
#endif

#define CZUUID_HASH_LENGTH 40

unsigned char *czuuid_hash(const unsigned char *uuid, int len, unsigned char *hash);

unsigned char *czuuid_hash_r(const unsigned char *uuid, int len);

void czuuid_free(void *p);

#ifdef __cplusplus
}
#endif

#endif
