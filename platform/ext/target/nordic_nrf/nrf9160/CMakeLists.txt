#-------------------------------------------------------------------------------
# Copyright (c) 2020, Arm Limited. All rights reserved.
# Copyright (c) 2020, Nordic Semiconductor ASA.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

cmake_policy(SET CMP0076 NEW)
set(CMAKE_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})

add_subdirectory(../common nrf_common)

#========================= Platform region defs ===============================#

target_include_directories(platform_region_defs
    INTERFACE
        partition
)

#========================= Platform common defs ===============================#

# Specify the location of platform specific build dependencies.
target_sources(tfm_s
    PRIVATE
    $<$<C_COMPILER_ID:ARMClang>:${CMAKE_CURRENT_SOURCE_DIR}/armclang/startup_nrf9160_s.s>
    $<$<C_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/gcc/startup_nrf9160_s.S>
    $<$<C_COMPILER_ID:IAR>:${CMAKE_CURRENT_SOURCE_DIR}/iar/startup_nrf9160_s.s>
)

if(NS)
    target_sources(tfm_ns
        PRIVATE
            $<$<C_COMPILER_ID:ARMClang>:${CMAKE_CURRENT_SOURCE_DIR}/armclang/startup_nrf9160_ns.s>
            $<$<C_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/gcc/startup_nrf9160_ns.S>
            $<$<C_COMPILER_ID:IAR>:${CMAKE_CURRENT_SOURCE_DIR}/iar/startup_nrf9160_ns.s>
    )
endif()

if(BL2)
    target_sources(bl2
        PRIVATE
            $<$<C_COMPILER_ID:ARMClang>:${CMAKE_CURRENT_SOURCE_DIR}/armclang/startup_nrf9160_bl2.s>
            $<$<C_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/gcc/startup_nrf9160_bl2.S>
            $<$<C_COMPILER_ID:IAR>:${CMAKE_CURRENT_SOURCE_DIR}/iar/startup_nrf9160_bl2.s>
    )
endif()

#========================= Platform Secure ====================================#

target_include_directories(platform_s
    PUBLIC
        .
        partition
)

target_sources(platform_s
    PRIVATE
        target_cfg.c
        ../common/nrfx/mdk/system_nrf9160.c
        $<$<BOOL:TFM_PARTITION_PLATFORM>:${CMAKE_CURRENT_SOURCE_DIR}/services/src/tfm_platform_system.c>
)

target_compile_definitions(platform_s
    PUBLIC
        NRF9160_XXAA
)

#========================= Platform Non-Secure ================================#

target_include_directories(platform_ns
    PUBLIC
        .
)

target_sources(platform_ns
    PRIVATE
        ../common/nrfx/mdk/system_nrf9160.c
)

target_compile_definitions(platform_ns
    PUBLIC
        NRF9160_XXAA
        NRF_TRUSTZONE_NONSECURE
        DOMAIN_NS=1
)

#========================= Platform BL2 =======================================#

if(BL2)
    target_include_directories(platform_bl2
        PUBLIC
            partition
        PRIVATE
            .
    )

    target_sources(platform_bl2
        PRIVATE
            ../common/nrfx/mdk/system_nrf9160.c
    )

    target_compile_definitions(platform_bl2
        PUBLIC
            NRF9160_XXAA
    )
endif()
