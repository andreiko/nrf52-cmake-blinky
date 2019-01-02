#include <nrf52.h>
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"

uint32_t timestamp_func() {
    return 0;
}

int main() {
    NRF_P0->DIRSET = 1 << 17;

    uint32_t err_code;
    err_code = NRF_LOG_INIT(timestamp_func);
    NRF_LOG_DEFAULT_BACKENDS_INIT();

    if (err_code != NRF_SUCCESS) {
        NRF_P0->DIRSET = 1 << 17 | 1 << 18 | 1 << 19 | 1 << 20;
        return 1;
    }

    NRF_P0->DIRSET = 1 << 20;
    return 0;
}
