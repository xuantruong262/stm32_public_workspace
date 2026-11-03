#include "boot_request.h"

#include "main.h"
#include "boot_request_contract.h"

static bool boot_request_backup_access_enable(void)
{
    HAL_PWR_EnableBkUpAccess();

    if ((RCC->BDCR & RCC_BDCR_RTCSEL) == 0U) {
        SET_BIT(RCC->CSR, RCC_CSR_LSION);
        uint32_t timeout = 1000000U;
        while (((RCC->CSR & RCC_CSR_LSIRDY) == 0U) && (timeout-- != 0U)) {
        }
        if ((RCC->CSR & RCC_CSR_LSIRDY) == 0U) {
            return false;
        }
        MODIFY_REG(RCC->BDCR, RCC_BDCR_RTCSEL, RCC_RTCCLKSOURCE_LSI);
    }
    __HAL_RCC_RTC_ENABLE();
    return true;
}

bool boot_request_consume_update(void)
{
    if (!boot_request_backup_access_enable()) {
        return false;
    }

    const bool update_requested =
        (RTC->BKP0R == BOOT_REQUEST_MAGIC) &&
        (RTC->BKP1R == BOOT_REQUEST_UPDATE_MODE) &&
        (RTC->BKP2R == BOOT_REQUEST_GUARD);

    /* Clear every value, including a corrupt partial request, before booting. */
    RTC->BKP0R = 0U;
    RTC->BKP1R = 0U;
    RTC->BKP2R = 0U;
    __DSB();
    return update_requested;
}
