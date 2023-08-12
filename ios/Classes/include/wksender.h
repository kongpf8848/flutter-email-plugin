//
//  wksender.h
//  ews
//
//  Created by Sean Zhu on 2018/12/7.
//  Copyright © 2018 Chirpeur. All rights reserved.
//

#ifndef WKSENDER_H_
#define WKSENDER_H_
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * load well known address list:
 * yeetalk.net
 * apple.com
 * google.com
 * 
 * path_to_list: path to the wellknown file is stored.
 * note: all domains need to be in lowercased mode.
 * the real load operation happens in a separate thread.
 * */
void wellknown_load(const unsigned char *path_to_list);

/**
 * test if the given email_address is a well_known sender.
 * 
 * email_address: lowercased email address to be tested
 * 
 * returns: non-zero if email_address is a well_known sender, zero if false.
 * */
uint64_t wellknown_test(const unsigned char *email_address);

/**
 * dump wellknown list on stdout
 * */
uint64_t wellknown_dump();

#ifdef __cplusplus
}
#endif

#endif /* WKSENDER_H_ */
