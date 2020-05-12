#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

set(PLATFORM_DIR ${CMAKE_CURRENT_LIST_DIR})

embedded_include_directories(PATH "${PLATFORM_DIR}/target/nordic_nrf/boards/${TARGET_PLATFORM}")
include("${PLATFORM_DIR}/target/nordic_nrf/nrf9160/nrf9160.cmake")
