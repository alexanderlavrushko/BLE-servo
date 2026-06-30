package com.alexanderlavrushko.bleservo.protocol

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ServoProtocolTest {
    @Test
    fun encodeDecodePositions_roundTripsValues() {
        val raw = listOf(0, 127, 255)
        val encoded = ServoBleProtocol.encodePositions(raw)
        val decoded = ServoBleProtocol.decodePositions(encoded)
        assertEquals(raw, decoded)
    }

    @Test
    fun axisConverter_defaultConfigMapsCenter() {
        val converter = AxisConverter(AxisOutputConfig.default)
        assertEquals(127, converter.axisToServo(0f))
        assertTrue(converter.servoToAxis(127) in -0.01f..0.01f)
    }

    @Test
    fun axisConverter_myCarSteeringSupportsInvertedRange() {
        val converter = AxisConverter(AxisOutputConfig.myCarSteering)
        assertEquals(18, converter.axisToServo(1f))
        assertEquals(196, converter.axisToServo(-1f))
    }
}
