#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

set(NRF_COMMON_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(NRFX_DIR "${NRF_COMMON_DIR}/nrfx")

#Specify the location of platform specific build dependencies.
if(COMPILER STREQUAL "ARMCLANG")
    set (S_SCATTER_FILE_NAME   "${PLATFORM_DIR}/common/armclang/tfm_common_s.sct")
    set (BL2_SCATTER_FILE_NAME "${NRF_COMMON_DIR}/armclang/nordic_nrf_bl2.sct")
    set (NS_SCATTER_FILE_NAME  "${NRF_COMMON_DIR}/armclang/nordic_nrf_ns.sct")
    if (DEFINED CMSIS_5_DIR)
      # not all project defines CMSIS_5_DIR, only the ones that use it.
      set (RTX_LIB_PATH "${CMSIS_5_DIR}/CMSIS/RTOS2/RTX/Library/ARM/RTX_V8MMN.lib")
    endif()
elseif(COMPILER STREQUAL "GNUARM")
    set (S_SCATTER_FILE_NAME   "${PLATFORM_DIR}/common/gcc/tfm_common_s.ld")
    set (BL2_SCATTER_FILE_NAME "${NRF_COMMON_DIR}/gcc/nordic_nrf_bl2.ld")
    set (NS_SCATTER_FILE_NAME  "${NRF_COMMON_DIR}/gcc/nordic_nrf_ns.ld")
    if (DEFINED CMSIS_5_DIR)
      # not all project defines CMSIS_5_DIR, only the ones that use it.
      set (RTX_LIB_PATH "${CMSIS_5_DIR}/CMSIS/RTOS2/RTX/Library/GCC/libRTX_V8MMN.a")
    endif()
elseif(COMPILER STREQUAL "IARARM")
    set (S_SCATTER_FILE_NAME   "${PLATFORM_DIR}/common/iar/tfm_common_s.icf")
    set (BL2_SCATTER_FILE_NAME "${NRF_COMMON_DIR}/iar/nordic_nrf_bl2.icf")
    set (NS_SCATTER_FILE_NAME  "${NRF_COMMON_DIR}/iar/nordic_nrf_ns.icf")
    if (DEFINED CMSIS_5_DIR)
      # not all project defines CMSIS_5_DIR, only the ones that use it.
      set (RTX_LIB_PATH "${CMSIS_5_DIR}/CMSIS/RTOS2/RTX/Library/IAR/RTX_V8MMN.a")
    endif()
else()
    message(FATAL_ERROR "No startup file is available for compiler '${CMAKE_C_COMPILER_ID}'.")
endif()

if (BL2)
  set (BL2_LINKER_CONFIG ${BL2_SCATTER_FILE_NAME})
  if (${MCUBOOT_UPGRADE_STRATEGY} STREQUAL "RAM_LOADING")
      message(FATAL_ERROR "ERROR: RAM_LOADING upgrade strategy is not supported on target '${TARGET_PLATFORM}'.")
  endif()
  #FixMe: MCUBOOT_SIGN_RSA_LEN can be removed when ROTPK won't be hard coded in platform/ext/common/template/tfm_rotpk.c
  #       instead independently loaded from secure code as a blob.
  if (${MCUBOOT_SIGNATURE_TYPE} STREQUAL "RSA-2048")
      add_definitions(-DMCUBOOT_SIGN_RSA_LEN=2048)
  endif()
  if (${MCUBOOT_SIGNATURE_TYPE} STREQUAL "RSA-3072")
      add_definitions(-DMCUBOOT_SIGN_RSA_LEN=3072)
  endif()
endif()

embedded_include_directories(PATH "${NRF_COMMON_DIR}" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}/drivers/include" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}/mdk" ABSOLUTE)
embedded_include_directories(PATH "${PLATFORM_DIR}/../include" ABSOLUTE)
embedded_include_directories(PATH "${NRF_COMMON_DIR}/native_drivers" ABSOLUTE)
embedded_include_directories(PATH "${PLATFORM_DIR}/cmsis" ABSOLUTE)


if (NOT DEFINED BUILD_UART_STDOUT)
  message(FATAL_ERROR "Configuration variable BUILD_UART_STDOUT (true|false) is undefined!")
elseif(BUILD_UART_STDOUT)
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/uart_stdout.c")
  embedded_include_directories(PATH "${PLATFORM_DIR}/common" ABSOLUTE)
  set(BUILD_NATIVE_DRIVERS true)
  set(BUILD_CMSIS_DRIVERS true)
endif()

if (NOT DEFINED BUILD_NATIVE_DRIVERS)
  message(FATAL_ERROR "Configuration variable BUILD_NATIVE_DRIVERS (true|false) is undefined!")
elseif(BUILD_NATIVE_DRIVERS)
  list(APPEND ALL_SRC_C "${NRFX_DIR}/drivers/src/nrfx_uarte.c"
                        "${NRFX_DIR}/drivers/src/nrfx_nvmc.c"
                        "${NRF_COMMON_DIR}/nrfx_glue.c"
                        #"${NRF_COMMON_DIR}/native_drivers/spu.c"
                        )
endif()

if (NOT DEFINED BUILD_TIME)
  message(FATAL_ERROR "Configuration variable BUILD_TIME (true|false) is undefined!")
elseif(BUILD_TIME)
  # TODO: Add sources.
endif()

if (NOT DEFINED BUILD_PLAT_TEST)
  message(FATAL_ERROR "Configuration variable BUILD_PLAT_TEST (true|false) is undefined!")
elseif(BUILD_PLAT_TEST)
  message(FATAL_ERROR "BUILD_PLAT_TEST not implemented.")
  #list(APPEND ALL_SRC_C "${NRF_COMMON_DIR}/plat_test.c")
endif()

if (NOT DEFINED BUILD_BOOT_HAL)
  message(FATAL_ERROR "Configuration variable BUILD_BOOT_HAL (true|false) is undefined!")
elseif(BUILD_BOOT_HAL)
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/boot_hal.c")
  list(APPEND ALL_SRC_C "${NRF_COMMON_DIR}/boot_hal.c")
endif()

if (NOT DEFINED BUILD_TARGET_HARDWARE_KEYS)
  message(FATAL_ERROR "Configuration variable BUILD_TARGET_HARDWARE_KEYS (true|false) is undefined!")
elseif(BUILD_TARGET_HARDWARE_KEYS)
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/template/tfm_initial_attestation_key_material.c")
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/template/tfm_rotpk.c")
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/template/crypto_keys.c")
endif()

if (NOT DEFINED BUILD_TARGET_NV_COUNTERS)
  message(FATAL_ERROR "Configuration variable BUILD_TARGET_NV_COUNTERS (true|false) is undefined!")
elseif(BUILD_TARGET_NV_COUNTERS)
  # NOTE: This non-volatile counters implementation is a dummy
  #       implementation. Platform vendors have to implement the
  #       API ONLY if the target has non-volatile counters.
  list(APPEND ALL_SRC_C "${PLATFORM_DIR}/common/template/nv_counters.c")
  set(TARGET_NV_COUNTERS_ENABLE ON)
  # Sets SST_ROLLBACK_PROTECTION flag to compile in the SST services
  # rollback protection code as the target supports nv counters.
  set (SST_ROLLBACK_PROTECTION ON)
endif()

if (NOT DEFINED BUILD_CMSIS_DRIVERS)
  message(FATAL_ERROR "Configuration variable BUILD_CMSIS_DRIVERS (true|false) is undefined!")
elseif(BUILD_CMSIS_DRIVERS)
  message(WARNING "BUILD_CMSIS_DRIVERS not implemented.")
  #list(APPEND ALL_SRC_C_S "${NRF_COMMON_DIR}/cmsis_drivers/Driver_MPC.c"
  #  "${NRF_COMMON_DIR}/cmsis_drivers/Driver_PPC.c")
  list(APPEND ALL_SRC_C "${NRF_COMMON_DIR}/cmsis_drivers/Driver_USART.c")
  embedded_include_directories(PATH "${NRF_COMMON_DIR}/cmsis_drivers" ABSOLUTE)
  embedded_include_directories(PATH "${PLATFORM_DIR}/driver" ABSOLUTE)
endif()

if (NOT DEFINED BUILD_FLASH)
  message(FATAL_ERROR "Configuration variable BUILD_FLASH (true|false) is undefined!")
elseif(BUILD_FLASH)
  message(WARNING "BUILD_FLASH not implemented.")
  list(APPEND ALL_SRC_C "${NRF_COMMON_DIR}/cmsis_drivers/Driver_Flash.c")
  set(SST_CREATE_FLASH_LAYOUT ON)
  set(ITS_CREATE_FLASH_LAYOUT ON)
  embedded_include_directories(PATH "${NRF_COMMON_DIR}/cmsis_drivers" ABSOLUTE)
endif()
