#ifndef SERVO_CONTROL_PWM_H_INCLUDED
#define SERVO_CONTROL_PWM_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PIN_SERVO1 0
#define PIN_SERVO2 30
#define SERVO_COUNT 2
#define SERVO_POSITION_CENTER 127

void servo_init(void);
void servo_set_value(uint8_t channel_index, uint8_t value);
void servo_set_center(void);

#ifdef __cplusplus
}
#endif

#endif // SERVO_CONTROL_PWM_H_INCLUDED
