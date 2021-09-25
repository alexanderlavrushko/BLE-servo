#include "servo_control_pwm.h"
#include "app_pwm.h"

APP_PWM_INSTANCE(PWM1,1);
static uint32_t m_pwmTicksMin = 0;
static uint32_t m_pwmTicksAmplitude = 10;

static void pwm_ready_callback(uint32_t pwm_id)    // PWM callback function
{
}

void servo_init(void)
{
    // All values in microseconds
    const uint32_t SERVO_PWM_PERIOD = 20000;
//    const uint32_t SERVO_SG90_MIN_PULSE = 544;
//    const uint32_t SERVO_SG90_MAX_PULSE = 2400;
    const uint32_t SERVO_MIN_PULSE = 1000;
    const uint32_t SERVO_MAX_PULSE = 2000;

    ret_code_t err_code = 0;

    app_pwm_config_t pwm1_cfg = APP_PWM_DEFAULT_CONFIG_2CH(SERVO_PWM_PERIOD, PIN_SERVO1, PIN_SERVO2);

    // Switch the polarity
    pwm1_cfg.pin_polarity[0] = APP_PWM_POLARITY_ACTIVE_HIGH;
    pwm1_cfg.pin_polarity[1] = APP_PWM_POLARITY_ACTIVE_HIGH;

    // Initialize and enable PWM
    err_code = app_pwm_init(&PWM1, &pwm1_cfg, pwm_ready_callback);
    APP_ERROR_CHECK(err_code);
    app_pwm_enable(&PWM1);

    uint32_t totalTicks = app_pwm_cycle_ticks_get(&PWM1);
    m_pwmTicksMin = totalTicks * SERVO_MIN_PULSE / SERVO_PWM_PERIOD;
    uint32_t pwmTicksMax = totalTicks * SERVO_MAX_PULSE / SERVO_PWM_PERIOD;
    m_pwmTicksAmplitude = pwmTicksMax - m_pwmTicksMin;
}

void servo_set_value(uint8_t channel_index, uint8_t value)
{
    uint32_t pwmTicks = m_pwmTicksMin + value * m_pwmTicksAmplitude / 255;
    while (app_pwm_channel_duty_ticks_set(&PWM1, channel_index, pwmTicks) == NRF_ERROR_BUSY);
}
