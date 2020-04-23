#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

# This file gathers all nRF9160 specific files in the application.

# nRF9160 has a Cortex M33 CPU.
include("Common/CpuM33")

set(NRF9160_DIR ${CMAKE_CURRENT_LIST_DIR})

include("${NRF9160_DIR}/../common/nrf_common.cmake")
add_definitions(-DNRF9160_XXAA)

if(NOT DEFINED BUILD_CMSIS_CORE)
  message(FATAL_ERROR "Configuration variable BUILD_CMSIS_CORE (true|false) is undefined!")
elseif(BUILD_CMSIS_CORE)
  list(APPEND ALL_SRC_C "${NRFX_DIR}/mdk/system_nrf9160.c")
endif()
