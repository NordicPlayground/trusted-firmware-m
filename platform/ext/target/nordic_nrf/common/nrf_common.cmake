#-------------------------------------------------------------------------------
# Copyright (c) 2020, Nordic Semiconductor ASA. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#-------------------------------------------------------------------------------

set(NRF_COMMON_DIR ${CMAKE_CURRENT_LIST_DIR})
set(NRFX_DIR "${NRF_COMMON_DIR}/nrfx")

embedded_include_directories(PATH "${NRF_COMMON_DIR}" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}/drivers/include" ABSOLUTE)
embedded_include_directories(PATH "${NRFX_DIR}/mdk" ABSOLUTE)

list(APPEND ALL_SRC_C "${NRF_COMMON_DIR}/nrfx_glue.c")
