
/* Size of a Secure and of a Non-secure image */
#define FLASH_S_PARTITION_SIZE                (0x40000)       /* S partition: 256 kB*/
#define FLASH_NS_PARTITION_SIZE               (0x30000)       /* NS partition: 192 kB*/
#define FLASH_MAX_PARTITION_SIZE        ((FLASH_S_PARTITION_SIZE >   \
                                          FLASH_NS_PARTITION_SIZE) ? \
                                         FLASH_S_PARTITION_SIZE :    \
                                         FLASH_NS_PARTITION_SIZE)

/* BL2 bootloader (MCUboot) */
#define FLASH_AREA_BL2_OFFSET      (0x0)
#define FLASH_AREA_BL2_SIZE        (0x10000) /* 64 KB */

/* Bootloader slots */
#define FLASH_PRI_SLOT_OFFSET      (FLASH_AREA_BL2_OFFSET + FLASH_AREA_BL2_SIZE)
#define FLASH_SEC_SLOT_OFFSET      (FLASH_PRI_SLOT_OFFSET + FLASH_S_PARTITION_SIZE + FLASH_NS_PARTITION_SIZE)
#define FLASH_AREA_SCRATCH_OFFSET  (FLASH_SEC_SLOT_OFFSET + FLASH_S_PARTITION_SIZE + FLASH_NS_PARTITION_SIZE)
#define FLASH_AREA_SCRATCH_SIZE    (0)
