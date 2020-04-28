/*
 * Copyright (c) 2018-2020 Arm Limited. All rights reserved.
 * Copyright (c) 2020 Nordic Semiconductor ASA.
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

#include "target_cfg.h"
#include "region_defs.h"
#include "tfm_plat_defs.h"
#include "region.h"

#include <spu.h>
#include <nrfx.h>


/* The section names come from the scatter file */
REGION_DECLARE(Load$$LR$$, LR_NS_PARTITION, $$Base);
REGION_DECLARE(Load$$LR$$, LR_VENEER, $$Base);
REGION_DECLARE(Load$$LR$$, LR_VENEER, $$Limit);
#ifdef BL2
REGION_DECLARE(Load$$LR$$, LR_SECONDARY_PARTITION, $$Base);
#endif /* BL2 */

const struct memory_region_limits memory_regions = {
    .non_secure_code_start =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_NS_PARTITION, $$Base) +
        BL2_HEADER_SIZE,

    .non_secure_partition_base =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_NS_PARTITION, $$Base),

    .non_secure_partition_limit =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_NS_PARTITION, $$Base) +
        NS_PARTITION_SIZE - 1,

    .veneer_base =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_VENEER, $$Base),

    .veneer_limit =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_VENEER, $$Limit),

#ifdef BL2
    .secondary_partition_base =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_SECONDARY_PARTITION, $$Base),

    .secondary_partition_limit =
        (uint32_t)&REGION_NAME(Load$$LR$$, LR_SECONDARY_PARTITION, $$Base) +
        SECONDARY_PARTITION_SIZE - 1,
#endif /* BL2 */
};

/* To write into AIRCR register, 0x5FA value must be write to the VECTKEY field,
 * otherwise the processor ignores the write.
 */
#define SCB_AIRCR_WRITE_MASK ((0x5FAUL << SCB_AIRCR_VECTKEY_Pos))

enum tfm_plat_err_t enable_fault_handlers(void)
{
    /* Explicitly set secure fault priority to the highest */
    NVIC_SetPriority(SecureFault_IRQn, 0);

    /* Enables BUS, MEM, USG and Secure faults */
    SCB->SHCSR |= SCB_SHCSR_USGFAULTENA_Msk
                  | SCB_SHCSR_BUSFAULTENA_Msk
                  | SCB_SHCSR_MEMFAULTENA_Msk
                  | SCB_SHCSR_SECUREFAULTENA_Msk;
    return TFM_PLAT_ERR_SUCCESS;
}

enum tfm_plat_err_t system_reset_cfg(void)
{
    uint32_t reg_value = SCB->AIRCR;
	
    /* Clear SCB_AIRCR_VECTKEY value */
    reg_value &= ~(uint32_t)(SCB_AIRCR_VECTKEY_Msk);

    /* Enable system reset request only to the secure world */
    reg_value |= (uint32_t)(SCB_AIRCR_WRITE_MASK | SCB_AIRCR_SYSRESETREQS_Msk);

    SCB->AIRCR = reg_value;

    return TFM_PLAT_ERR_SUCCESS;
}

enum tfm_plat_err_t init_debug(void)
{
#if defined(DAUTH_NONE)
    /* Disable debugging */
    NRF_CTRLAP->APPROTECT.DISABLE = 0;
    NRF_CTRLAP->SECUREAPPROTECT.DISABLE = 0;
#elif defined(DAUTH_NS_ONLY)
    /* Allow debugging Non-Secure only */
    NRF_CTRLAP->APPROTECT.DISABLE = CTRLAPPERI_APPROTECT_DISABLE_KEY_Msk;
    NRF_CTRLAP->SECUREAPPROTECT.DISABLE = 0;
#elif defined(DAUTH_FULL)
    /* Allow debugging */
    NRF_CTRLAP->APPROTECT.DISABLE = CTRLAPPERI_APPROTECT_DISABLE_KEY_Msk;
    NRF_CTRLAP->SECUREAPPROTECT.DISABLE = CTRLAPPERI_SECUREAPPROTECT_DISABLE_KEY_Msk;
#elif !defined(DAUTH_CHIP_DEFAULT)
#error "No debug authentication setting is provided."
#endif
    /* Lock access to APPROTECT, SECUREAPPROTECT */
    NRF_CTRLAP->APPROTECT.LOCK = CTRLAPPERI_APPROTECT_LOCK_LOCK_Locked <<
        CTRLAPPERI_APPROTECT_LOCK_LOCK_Msk;
    NRF_CTRLAP->SECUREAPPROTECT.LOCK = CTRLAPPERI_SECUREAPPROTECT_LOCK_LOCK_Locked <<
        CTRLAPPERI_SECUREAPPROTECT_LOCK_LOCK_Msk;

    return TFM_PLAT_ERR_SUCCESS;
}

/*----------------- NVIC interrupt target state to NS configuration ----------*/
enum tfm_plat_err_t nvic_interrupt_target_state_cfg(void)
{
    /* Target every interrupt to NS; unimplemented interrupts will be Write-Ignored */
    for (uint8_t i = 0; i < sizeof(NVIC->ITNS) / sizeof(NVIC->ITNS[0]); i++) {
        NVIC->ITNS[i] = 0xFFFFFFFF;
    }

    /* Make sure that the SPU is targeted to S state */
    NVIC_ClearTargetState(SPU_IRQn);

    return TFM_PLAT_ERR_SUCCESS;
}

/*----------------- NVIC interrupt enabling for S peripherals ----------------*/
enum tfm_plat_err_t nvic_interrupt_enable(void)
{
    /* SPU interrupt enabling */
    spu_enable_interrupts();

    NVIC_ClearPendingIRQ(SPU_IRQn);
    NVIC_EnableIRQ(SPU_IRQn);

    return TFM_PLAT_ERR_SUCCESS;
}

/*------------------- SAU/IDAU configuration functions -----------------------*/

void sau_and_idau_cfg(void)
{
    /* IDAU (SPU) is always enabled. SAU is non-existent.
     * Allow SPU to have precedence over (non-existing) ARMv8-M SAU.
     */
    TZ_SAU_Disable();
    SAU->CTRL |= SAU_CTRL_ALLNS_Msk;
}

int32_t spu_init_cfg(void)
{
    /*
     * Configure SPU Regions for Non-Secure Code and SRAM (Data)
     * Configure SPU for Peripheral Security
     * Configure Non-Secure Callable Regions
     * Configure Secondary Image Partition for BL2
     */

    /* Explicitly reset Flash and SRAM configuration to all-Secure,
     * in case this has been overwritten by earlier images e.g.
     * bootloader.
     */
    spu_regions_reset_all_secure();

    /* Configures SPU Code and Data regions to be non-secure */
    spu_regions_flash_config_non_secure(memory_regions.non_secure_partition_base,
        memory_regions.non_secure_partition_limit);
    spu_regions_sram_config_non_secure(NS_DATA_START, NS_DATA_LIMIT);

    /* Configures veneers region to be non-secure callable */
    spu_regions_flash_config_non_secure_callable(memory_regions.veneer_base,
        memory_regions.veneer_limit);

#ifdef BL2
    /* Secondary image partition */
    spu_regions_flash_config_non_secure(memory_regions.secondary_partition_base,
        memory_regions.secondary_partition_limit);
#endif /* BL2 */

    return ARM_DRIVER_OK;
}

