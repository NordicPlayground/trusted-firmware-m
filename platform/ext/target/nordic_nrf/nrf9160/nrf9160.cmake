#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

# This file gathers all nRF9160 specific files in the application.

set (SECURE_UART1 ON)

# nRF9160 has a Cortex M33 CPU.
include("Common/CpuM33")

set(NRF9160_DIR ${CMAKE_CURRENT_LIST_DIR})

embedded_include_directories(PATH "${NRF9160_DIR}/partition" ABSOLUTE)

include("${NRF9160_DIR}/../common/nrf_common.cmake")
add_definitions(-DNRF9160_XXAA)

set (FLASH_LAYOUT           "${NRF9160_DIR}/partition/flash_layout.h")
set (PLATFORM_LINK_INCLUDES "${NRF9160_DIR}/partition/")

embedded_include_directories(PATH "${NRF9160_DIR}" ABSOLUTE)

if(NOT DEFINED BUILD_CMSIS_CORE)
  message(FATAL_ERROR "Configuration variable BUILD_CMSIS_CORE (true|false) is undefined!")
elseif(BUILD_CMSIS_CORE)
  list(APPEND ALL_SRC_C "${NRFX_DIR}/mdk/system_nrf9160.c")
endif()

if (NOT DEFINED BUILD_RETARGET)
  message(FATAL_ERROR "Configuration variable BUILD_RETARGET (true|false) is undefined!")
elseif(BUILD_RETARGET)
  # Nothing needed.
endif()

if (NOT DEFINED BUILD_STARTUP)
  message(FATAL_ERROR "Configuration variable BUILD_STARTUP (true|false) is undefined!")
elseif(BUILD_STARTUP)
  if(CMAKE_C_COMPILER_ID STREQUAL "ARMCLANG")
    message(WARNING "BUILD_STARTUP not implemented for ARMCLANG")
    #list(APPEND ALL_SRC_ASM_S "${NRF9160_DIR}/armclang/startup_nrf9160_s.S")
    #list(APPEND ALL_SRC_ASM_NS "${NRF9160_DIR}/armclang/startup_nrf9160_ns.S")
    #list(APPEND ALL_SRC_ASM_BL2 "${NRF9160_DIR}/armclang/startup_nrf9160_bl2.S")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "GNUARM")
    list(APPEND ALL_SRC_ASM_S "${NRF9160_DIR}/gcc/startup_nrf9160_s.S")
    list(APPEND ALL_SRC_ASM_NS "${NRF9160_DIR}/gcc/startup_nrf9160_ns.S")
    list(APPEND ALL_SRC_ASM_BL2 "${NRF9160_DIR}/gcc/startup_nrf9160_bl2.S")
    set_property(SOURCE "${ALL_SRC_ASM_S}" "${ALL_SRC_ASM_NS}" "${ALL_SRC_ASM_BL2}" APPEND
      PROPERTY COMPILE_DEFINITIONS "__STARTUP_CLEAR_BSS_MULTIPLE" "__STARTUP_COPY_MULTIPLE")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "IARARM")
    message(WARNING "BUILD_STARTUP not implemented for IARARM")
    #list(APPEND ALL_SRC_ASM_S "${NRF9160_DIR}/iar/startup_nrf9160_s.S")
    #list(APPEND ALL_SRC_ASM_NS "${NRF9160_DIR}/iar/startup_nrf9160_ns.S")
    #list(APPEND ALL_SRC_ASM_BL2 "${NRF9160_DIR}/iar/startup_nrf9160_bl2.S")
  else()
    message(FATAL_ERROR "No startup file is available for compiler '${CMAKE_C_COMPILER_ID}'.")
  endif()
endif()

if (NOT DEFINED BUILD_TARGET_CFG)
  message(FATAL_ERROR "Configuration variable BUILD_TARGET_CFG (true|false) is undefined!")
elseif(BUILD_TARGET_CFG)
  list(APPEND ALL_SRC_C_S "${NRF9160_DIR}/target_cfg.c")
  list(APPEND ALL_SRC_C_S "${NRF_COMMON_DIR}/spm_hal.c")
  list(APPEND ALL_SRC_C_S "${PLATFORM_DIR}/common/tfm_hal_its.c")
  list(APPEND ALL_SRC_C_S "${PLATFORM_DIR}/common/tfm_hal_ps.c")
  list(APPEND ALL_SRC_C_S "${PLATFORM_DIR}/common/template/attest_hal.c")
  if (TFM_PARTITION_PLATFORM)
    list(APPEND ALL_SRC_C_S "${NRF9160_DIR}/services/src/tfm_platform_system.c")
  endif()
  list(APPEND ALL_SRC_C_S "${PLATFORM_DIR}/common/tfm_platform.c")
  embedded_include_directories(PATH "${PLATFORM_DIR}/common" ABSOLUTE)
endif()
