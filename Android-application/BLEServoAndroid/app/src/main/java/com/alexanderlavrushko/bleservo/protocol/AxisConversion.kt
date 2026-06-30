package com.alexanderlavrushko.bleservo.protocol

import kotlin.math.abs
import kotlin.math.roundToInt

data class AxisOutputConfig(
    val center: Int,
    val maxNegative: Int,
    val maxPositive: Int,
) {
    companion object {
        val default = AxisOutputConfig(center = 127, maxNegative = 0, maxPositive = 255)
        val myCarDriving = AxisOutputConfig(center = 127, maxNegative = 10, maxPositive = 245)
        val myCarSteering = AxisOutputConfig(center = 112, maxNegative = 196, maxPositive = 18)
    }
}

data class ChannelConfig(
    val channelIndex: Int,
    val outputConfig: AxisOutputConfig,
    val animationSpeed: Float,
)

data class ControlPreset(
    val name: String,
    val driving: ChannelConfig,
    val steering: ChannelConfig,
) {
    companion object {
        val defaults = ControlPreset(
            name = "Default",
            driving = ChannelConfig(0, AxisOutputConfig.default, 2f),
            steering = ChannelConfig(1, AxisOutputConfig.default, 2f),
        )
        val myCar = ControlPreset(
            name = "My Car",
            driving = ChannelConfig(0, AxisOutputConfig.myCarDriving, 2f),
            steering = ChannelConfig(1, AxisOutputConfig.myCarSteering, 2f),
        )

        val all = listOf(defaults, myCar)
    }
}

class AxisConverter(private val output: AxisOutputConfig) {
    fun axisToServo(value: Float): Int {
        val input = value.coerceIn(-1f, 1f)
        val maxDelta = if (input < 0f) {
            (output.center - output.maxNegative).toFloat()
        } else {
            (output.maxPositive - output.center).toFloat()
        }
        return (output.center + input * maxDelta).roundToInt().coerceIn(0, 255)
    }

    fun servoToAxis(value: Int): Float {
        val safeValue = value.coerceIn(minOf(output.maxNegative, output.maxPositive), maxOf(output.maxNegative, output.maxPositive))
        val centerToPositive = (output.maxPositive - output.center).toFloat()
        val negativeToCenter = (output.center - output.maxNegative).toFloat()

        val useNegative = if (output.maxNegative < output.maxPositive) {
            safeValue < output.center
        } else {
            safeValue > output.center
        }
        val maxDelta = if (useNegative) negativeToCenter else centerToPositive
        if (abs(maxDelta) < 0.0001f) return 0f
        return ((safeValue - output.center).toFloat() / maxDelta).coerceIn(-1f, 1f)
    }
}
