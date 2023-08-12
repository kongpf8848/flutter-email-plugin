//
//  czcrypto.h
//
//  Created by Sean Zhu on 2018/9/17.
//  Copyright © 2018 Chan Zhi. All rights reserved.
//

#ifndef CZCRYPTO_H
#define CZCRYPTO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// must be called before czcrypto_init.
int czcrypto_set_runtime(int production);

void czcrypto_init();

void czcrypto_cleanup();

unsigned char *czcrypto_encrypt(const unsigned char *salt, const unsigned char *in, int len);

unsigned char *czcrypto_fingerprint_file(const unsigned char *previous_hash);

unsigned char *czcrypto_decrypt(const unsigned char *salt, const unsigned char *in, int len, int *ret_len);

unsigned char *czcrypto_obfuscate(const unsigned char *in, int len);

unsigned char *czcrypto_original(const unsigned char *in, int len);

unsigned char *czcrypto_passwd(const unsigned char *uuid, int len);

unsigned char *czcrypto_encrypt_file(const unsigned char *salt, const unsigned char *from_file, const unsigned char *to_file);

unsigned char *czcrypto_decrypt_file(const unsigned char *salt, const unsigned char *from_file, const unsigned char *to_file);

unsigned char *czcrypto_encrypt_to_file(const unsigned char *salt, const unsigned char *plain_data, uint64_t len, const unsigned char *to_file);

unsigned char *czcrypto_decrypt_from_file(const unsigned char *salt, const unsigned char *from_file, uint64_t *ret_len);

unsigned char *czcrypto_encrypt_binary(const unsigned char *salt, const unsigned char *plain_data, uint64_t len, uint64_t *ret_len);

unsigned char *czcrypto_decrypt_binary(const unsigned char *salt, const unsigned char *cipher_data, uint64_t len, uint64_t *ret_len);

unsigned char *czcrypto_cbc_encrypt(const unsigned char *salt, const unsigned char *plain_data, uint64_t len);

unsigned char *czcrypto_cbc_decrypt(const unsigned char *salt, const unsigned char *cipher_data, uint64_t len, uint64_t *ret_len);

void czcrypto_free(void *p);

#ifdef __cplusplus
}
#endif

#endif
