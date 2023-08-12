//
//  imcorealg.h
//  ews
//
//  Created by Sean Zhu on 2019/12/6.
//  Copyright © 2019 Chirpeur. All rights reserved.
//

#ifndef IMCOREALG_H_
#define IMCOREALG_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * imcore_compose("1234@cn", "2345@cn") will output: 1234@cn...2345@cn
 * imcore_compose("2345@cn", "1234@cn") will output: 1234@cn...2345@cn
 * 
 * note that the returned buffer needs to be release by imcore_free().
 * */
unsigned char *imcore_compose(const unsigned char *peopleA, const unsigned char *peopleB);
void imcore_free(void *ptr);

/**
 * imcore_is_email("demo@chirpeur.com") will output 1
 * imcore_is_email("1234@cn") will output 0
 * imcore_is_email("1234") will output 0
 * imcore_is_im("demo@chirpeur.com") will output 0
 * imcore_is_im("1234@cn") will output 1
 * imcore_is_im("1234") will output 0
 * */
int32_t imcore_is_email(const unsigned char *address);
int32_t imcore_is_im(const unsigned char *address);

/**
 * extract the diuu from a chirp_id.
 * imcore_diuu_of("2345@cn") outputs 2345
 * imcore_diuu_of("2345") outputs 2345
 * imcore_diuu_of("2345@abc.com") outputs 0
 * imcore_diuu_of("23ab45@cn") outputs 0
 * imcore_diuu_of(nullptr) outputs 0
 * */
int64_t imcore_diuu_of(const unsigned char *chirp_id);

#ifdef __cplusplus
}
#endif

#endif /* IMCOREALG_H_ */
