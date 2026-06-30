package com.alexanderlavrushko.bleservo.protocol

import java.util.UUID

/**
 * BLE protocol mirrored from the iOS app (iOS-application/BLEServo/BLEServo/Models/BLEServo.swift)
 * and firmware service definition (nRF51-servo/ble_service_servo.h):
 *
 * Service UUID: 88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D
 * Position characteristic UUID: 88F3AA11-5ACB-4CDD-9C9E-9B122D3ED93D
 * Count characteristic UUID: 88F3AA12-5ACB-4CDD-9C9E-9B122D3ED93D (read-only, optional)
 *
 * Write/read flow parity:
 * 1) Central scans by service UUID and connects.
 * 2) Central discovers service + AA11 characteristic.
 * 3) Central reads AA11 once to get initial servo positions.
 * 4) AA11 is written with response; payload is raw byte array where each byte maps to channel value.
 *    For this firmware, channels are [0]=driving, [1]=steering.
 */
object ServoBleProtocol {
    val serviceUuid: UUID = UUID.fromString("88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D")
    val positionCharUuid: UUID = UUID.fromString("88F3AA11-5ACB-4CDD-9C9E-9B122D3ED93D")
    val countCharUuid: UUID = UUID.fromString("88F3AA12-5ACB-4CDD-9C9E-9B122D3ED93D")

    const val expectedChannelCount = 2

    fun encodePositions(positions: List<Int>): ByteArray {
        require(positions.isNotEmpty()) { "positions must not be empty" }
        return positions.map { value -> value.coerceIn(0, 255).toByte() }.toByteArray()
    }

    fun decodePositions(data: ByteArray): List<Int> {
        return data.map { it.toInt() and 0xFF }
    }
}
