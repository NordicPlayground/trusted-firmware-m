/*
 * Copyright (c) 2020 Nordic Semiconductor ASA. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __SPU_H__
#define __SPU_H__

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/**
 * \brief SPU interrupt enabling
 *
 * Enable security violations outside the Cortex-M33
 * to trigger SPU interrupts.
 */
void spu_enable_interrupts(void);

/**
 * \brief Reset all memory regions to being Secure
 *
 * Reset all (Flash or SRAM) memory regions to being Secure
 * and have default (i.e. Read-Write-Execute allow) access policy
 *
 * \note region lock is not applied to allow modifying the configuration.
 */
void spu_regions_reset_all_secure(void);

/**
 * \brief Configure Flash memory regions as Non-Secure
 *
 * Configure a range of Flash memory regions as Non-Secure
 *
 * \note region lock is applied to prevent further modification during
 * the current reset cycle.
 */
void spu_regions_flash_config_non_secure( uint32_t start_addr, uint32_t limit_addr);

/**
 * \brief Configure SRAM memory regions as Non-Secure
 *
 * Configure a range of SRAM memory regions as Non-Secure
 *
 * \note region lock is applied to prevent further modification during
 * the current reset cycle.
 */
void spu_regions_sram_config_non_secure( uint32_t start_addr, uint32_t limit_addr);

/**
 * \brief Configure Non-Secure Callable area
 *
 * Configure a single region in Secure Flash as Non-Secure Callable
 * (NSC) area.
 *
 * \note Any Secure Entry functions, exposing secure services to the
 * Non-Secure firmware, shall be located inside this NSC area.
 *
 * If the start address of the NSC area is hard-coded, it must follow
 * the HW restrictions: The size must be a power of 2 between 32 and
 * 4096, and the end address must fall on a SPU region boundary.
 *
 * \note region lock is applied to prevent further modification during
 *  the current reset cycle.
 */
void spu_regions_flash_config_non_secure_callable(uint32_t start_addr, uint32_t limit_addr);

#endif
