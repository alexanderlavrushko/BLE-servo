#include "sdk_common.h"
#include "ble_service_servo.h"
#include "ble_srv_common.h"

static void on_connect(ble_servo_t* p_servo, ble_evt_t* p_ble_evt)
{
    p_servo->conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
}

static void on_disconnect(ble_servo_t* p_servo, ble_evt_t* p_ble_evt)
{
    UNUSED_PARAMETER(p_ble_evt);
    p_servo->conn_handle = BLE_CONN_HANDLE_INVALID;
}

static void on_write(ble_servo_t* p_servo, ble_evt_t* p_ble_evt)
{
    ble_gatts_evt_write_t* p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;

    if ((p_evt_write->handle == p_servo->pos_char_handles.value_handle) &&
        (p_servo->pos_write_handler != NULL))
    {
        p_servo->pos_write_handler(p_servo, p_evt_write->len, p_evt_write->data);
    }
}

void ble_servo_on_ble_evt(ble_servo_t* p_servo, ble_evt_t* p_ble_evt)
{
    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
            on_connect(p_servo, p_ble_evt);
            break;

        case BLE_GAP_EVT_DISCONNECTED:
            on_disconnect(p_servo, p_ble_evt);
            break;

        case BLE_GATTS_EVT_WRITE:
            on_write(p_servo, p_ble_evt);
            break;

        default:
            // No implementation needed.
            break;
    }
}

static uint32_t pos_char_add(ble_servo_t* p_servo, const ble_servo_init_t* p_servo_init)
{
    ble_gatts_char_md_t char_md;
    ble_gatts_attr_t    attr_char_value;
    ble_uuid_t          ble_uuid;
    ble_gatts_attr_md_t attr_md;

    memset(&char_md, 0, sizeof(char_md));

    char_md.char_props.read   = 1;
    char_md.char_props.write  = 1;
    char_md.p_char_user_desc  = NULL;
    char_md.p_char_pf         = NULL;
    char_md.p_user_desc_md    = NULL;
    char_md.p_cccd_md         = NULL;
    char_md.p_sccd_md         = NULL;

    ble_uuid.type = p_servo->uuid_type;
    ble_uuid.uuid = SERVO_UUID_POS_CHAR;

    memset(&attr_md, 0, sizeof(attr_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);
    attr_md.vloc       = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth    = 0;
    attr_md.wr_auth    = 0;
    attr_md.vlen       = 0;

    memset(&attr_char_value, 0, sizeof(attr_char_value));

    attr_char_value.p_uuid       = &ble_uuid;
    attr_char_value.p_attr_md    = &attr_md;
    attr_char_value.init_len     = p_servo_init->channels_count * sizeof(uint8_t);
    attr_char_value.init_offs    = 0;
    attr_char_value.max_len      = p_servo_init->channels_count * sizeof(uint8_t);
    attr_char_value.p_value      = (uint8_t*)p_servo_init->pos_initial_data;

    return sd_ble_gatts_characteristic_add(p_servo->service_handle,
                                           &char_md,
                                           &attr_char_value,
                                           &p_servo->pos_char_handles);
}

static uint32_t count_char_add(ble_servo_t* p_servo, const ble_servo_init_t* p_servo_init)
{
    ble_gatts_char_md_t char_md;
    ble_gatts_attr_t    attr_char_value;
    ble_uuid_t          ble_uuid;
    ble_gatts_attr_md_t attr_md;

    memset(&char_md, 0, sizeof(char_md));

    char_md.char_props.read   = 1;
    char_md.char_props.write  = 0;
    char_md.p_char_user_desc  = NULL;
    char_md.p_char_pf         = NULL;
    char_md.p_user_desc_md    = NULL;
    char_md.p_cccd_md         = NULL;
    char_md.p_sccd_md         = NULL;

    ble_uuid.type = p_servo->uuid_type;
    ble_uuid.uuid = SERVO_UUID_COUNT_CHAR;

    memset(&attr_md, 0, sizeof(attr_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_NO_ACCESS(&attr_md.write_perm);
    attr_md.vloc       = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth    = 0;
    attr_md.wr_auth    = 0;
    attr_md.vlen       = 0;

    memset(&attr_char_value, 0, sizeof(attr_char_value));

    attr_char_value.p_uuid       = &ble_uuid;
    attr_char_value.p_attr_md    = &attr_md;
    attr_char_value.init_len     = sizeof(uint8_t);
    attr_char_value.init_offs    = 0;
    attr_char_value.max_len      = sizeof(uint8_t);
    attr_char_value.p_value      = (uint8_t*)&p_servo_init->channels_count;

    return sd_ble_gatts_characteristic_add(p_servo->service_handle,
                                           &char_md,
                                           &attr_char_value,
                                           &p_servo->count_char_handles);
}

uint32_t ble_servo_init(ble_servo_t* p_servo, const ble_servo_init_t* p_servo_init)
{
    uint32_t   err_code;
    ble_uuid_t ble_uuid;

    // Initialize service structure
    p_servo->conn_handle       = BLE_CONN_HANDLE_INVALID;
    p_servo->pos_write_handler = p_servo_init->pos_write_handler;

    // Add service
    ble_uuid128_t base_uuid = { SERVO_UUID_BASE };
    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_servo->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_servo->uuid_type;
    ble_uuid.uuid = SERVO_UUID_SERVICE;

    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &ble_uuid, &p_servo->service_handle);
    VERIFY_SUCCESS(err_code);

    // Add characteristics
    err_code = count_char_add(p_servo, p_servo_init);
    VERIFY_SUCCESS(err_code);

    err_code = pos_char_add(p_servo, p_servo_init);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}
