#ifndef BLE_SERVICE_SERVO_H_INCLUDED
#define BLE_SERVICE_SERVO_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>
#include "ble.h"
#include "ble_srv_common.h"

#ifdef __cplusplus
extern "C" {
#endif

// 88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D

#define SERVO_UUID_BASE        {0x3D, 0xD9, 0x3E, 0x2D, 0x12, 0x9B, 0x9E, 0x9C, \
                                0xDD, 0x4C, 0xCB, 0x5A, 0x00, 0x00, 0xF3, 0x88}
#define SERVO_UUID_SERVICE     0xAA10
#define SERVO_UUID_POS_CHAR    0xAA11
#define SERVO_UUID_COUNT_CHAR  0xAA12

#define SERVO_MAX_CHANNELS     (8)

typedef struct ble_servo_s ble_servo_t;

typedef void (*ble_servo_pos_write_handler_t) (ble_servo_t* p_servo, uint8_t data_len, const uint8_t* p_data);

/** @brief Servo Service init structure. This structure contains all options and data needed for
 *        initialization of the service.*/
typedef struct
{
    ble_servo_pos_write_handler_t pos_write_handler; /**< Event handler to be called when the Position Characteristic is written. */
    uint8_t channels_count; /**< Number of servo motors available. */
    uint8_t pos_initial_data[SERVO_MAX_CHANNELS];
} ble_servo_init_t;

/**@brief Servo Service structure. This structure contains various status information for the service. */
struct ble_servo_s
{
    uint16_t                    service_handle;        /**< Handle of Servo Service (as provided by the BLE stack). */
    ble_gatts_char_handles_t    count_char_handles;    /**< Handles related to the Count Characteristic. */
    ble_gatts_char_handles_t    pos_char_handles;      /**< Handles related to the Position Characteristic. */
    uint8_t                     uuid_type;             /**< UUID type for the Servo Service. */
    uint16_t                    conn_handle;           /**< Handle of the current connection (as provided by the BLE stack). BLE_CONN_HANDLE_INVALID if not in a connection. */
    ble_servo_pos_write_handler_t pos_write_handler;   /**< Event handler to be called when the Position Characteristic is written. */
};

/**@brief Function for initializing the Servo Service.
 *
 * @param[out] p_servo      Servo Service structure. This structure must be supplied by
 *                        the application. It is initialized by this function and will later
 *                        be used to identify this particular service instance.
 * @param[in] p_servo_init  Information needed to initialize the service.
 *
 * @retval NRF_SUCCESS If the service was initialized successfully. Otherwise, an error code is returned.
 */
uint32_t ble_servo_init(ble_servo_t* p_servo, const ble_servo_init_t* p_servo_init);

/**@brief Function for handling the application's BLE stack events.
 *
 * @details This function handles all events from the BLE stack that are of interest to the Servo Service.
 *
 * @param[in] p_servo      Servo Service structure.
 * @param[in] p_ble_evt  Event received from the BLE stack.
 */
void ble_servo_on_ble_evt(ble_servo_t* p_servo, ble_evt_t* p_ble_evt);

#ifdef __cplusplus
}
#endif

#endif // BLE_SERVICE_SERVO_H_INCLUDED
