#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

# This file gathers all nRF5340 specific files in the application.

# nRF5340 has a Cortex M33 CPU.
include("Common/CpuM33")

set(NRF5340_DIR ${CMAKE_CURRENT_LIST_DIR})

include("${NRF5340_DIR}/../common/common.cmake")
add_definitions(-DNRF5340_XXAA_APPLICATION)

if(NOT DEFINED BUILD_CMSIS_CORE)
  message(FATAL_ERROR "Configuration variable BUILD_CMSIS_CORE (true|false) is undefined!")
elseif(BUILD_CMSIS_CORE)
  list(APPEND ALL_SRC_C "${NRFX_DIR}/mdk/system_nrf5340_application.c")
endif()
