/*
 * Copyright (c) 2018-2019, Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 */

#include <stddef.h>
#include <stdint.h>

#include "tfm_mbedcrypto_include.h"

#include "tfm_crypto_api.h"
#include "tfm_crypto_defs.h"
#include "secure_fw/core/tfm_memory_utils.h"

/**
 * \def TFM_CRYPTO_CONC_OPER_NUM
 *
 * \brief This is the default value for the maximum number of concurrent
 *        operations that can be active (allocated) at any time, supported
 *        by the implementation
 */
#ifndef TFM_CRYPTO_CONC_OPER_NUM
#define TFM_CRYPTO_CONC_OPER_NUM (8)
#endif

struct tfm_crypto_operation_s {
    uint32_t in_use;                /*!< Indicates if the operation is in use */
    enum tfm_crypto_operation_type type; /*!< Type of the operation */
    union {
        psa_cipher_operation_t cipher;    /*!< Cipher operation context */
        psa_mac_operation_t mac;          /*!< MAC operation context */
        psa_hash_operation_t hash;        /*!< Hash operation context */
        psa_crypto_generator_t generator; /*!< Generator operation context */
    } operation;
};

static struct tfm_crypto_operation_s operation[TFM_CRYPTO_CONC_OPER_NUM] ={{0}};

/*
 * \brief Function used to clear the memory associated to a backend context
 *
 * \param[in] index Numerical index in the database of the backend contexts
 *
 * \return None
 *
 */
static void memset_operation_context(uint32_t index)
{
    uint32_t mem_size;

    uint8_t *mem_ptr = (uint8_t *) &(operation[index].operation);

    switch(operation[index].type) {
    case TFM_CRYPTO_CIPHER_OPERATION:
        mem_size = sizeof(psa_cipher_operation_t);
        break;
    case TFM_CRYPTO_MAC_OPERATION:
        mem_size = sizeof(psa_mac_operation_t);
        break;
    case TFM_CRYPTO_HASH_OPERATION:
        mem_size = sizeof(psa_hash_operation_t);
        break;
    case TFM_CRYPTO_GENERATOR_OPERATION:
        mem_size = sizeof(psa_crypto_generator_t);
        break;
    case TFM_CRYPTO_OPERATION_NONE:
    default:
        mem_size = 0;
        break;
    }

    /* Clear the contents of the backend context */
    (void)tfm_memset(mem_ptr, 0, mem_size);
}

/*!
 * \defgroup public Public functions
 *
 */

/*!@{*/
psa_status_t tfm_crypto_init_alloc(void)
{
    /* Clear the contents of the local contexts */
    (void)tfm_memset(operation, 0, sizeof(operation));
    return PSA_SUCCESS;
}

psa_status_t tfm_crypto_operation_alloc(enum tfm_crypto_operation_type type,
                                        uint32_t *handle,
                                        void **ctx)
{
    uint32_t i = 0;

    /* Init to invalid values */
    if (ctx == NULL) {
        return PSA_ERROR_INVALID_ARGUMENT;
    }
    *ctx = NULL;

    for (i=0; i<TFM_CRYPTO_CONC_OPER_NUM; i++) {
        if (operation[i].in_use == TFM_CRYPTO_NOT_IN_USE) {
            operation[i].in_use = TFM_CRYPTO_IN_USE;
            operation[i].type = type;
            *handle = i;
            *ctx = (void *) &(operation[i].operation);
            return PSA_SUCCESS;
        }
    }

    *handle = TFM_CRYPTO_INVALID_HANDLE;
    return PSA_ERROR_NOT_PERMITTED;
}

psa_status_t tfm_crypto_operation_release(uint32_t *handle)
{
    uint32_t h_val = *handle;

    if ( (h_val != TFM_CRYPTO_INVALID_HANDLE) &&
         (h_val < TFM_CRYPTO_CONC_OPER_NUM) &&
         (operation[h_val].in_use == TFM_CRYPTO_IN_USE) ) {

        memset_operation_context(h_val);
        operation[h_val].in_use = TFM_CRYPTO_NOT_IN_USE;
        operation[h_val].type = TFM_CRYPTO_OPERATION_NONE;
        *handle = TFM_CRYPTO_INVALID_HANDLE;
        return PSA_SUCCESS;
    }

    return PSA_ERROR_INVALID_ARGUMENT;
}

psa_status_t tfm_crypto_operation_lookup(enum tfm_crypto_operation_type type,
                                         uint32_t handle,
                                         void **ctx)
{
    if ( (handle != TFM_CRYPTO_INVALID_HANDLE) &&
         (handle < TFM_CRYPTO_CONC_OPER_NUM) &&
         (operation[handle].in_use == TFM_CRYPTO_IN_USE) &&
         (operation[handle].type == type) ) {

        *ctx = (void *) &(operation[handle].operation);
        return PSA_SUCCESS;
    }

    return PSA_ERROR_BAD_STATE;
}
/*!@}*/
