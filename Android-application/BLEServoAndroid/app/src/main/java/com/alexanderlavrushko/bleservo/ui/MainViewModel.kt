package com.alexanderlavrushko.bleservo.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.alexanderlavrushko.bleservo.ble.BleConnectionState
import com.alexanderlavrushko.bleservo.ble.BleDiscoveredDevice
import com.alexanderlavrushko.bleservo.ble.BleServoListener
import com.alexanderlavrushko.bleservo.ble.BleServoTransport
import com.alexanderlavrushko.bleservo.protocol.AxisConverter
import com.alexanderlavrushko.bleservo.protocol.ChannelConfig
import com.alexanderlavrushko.bleservo.protocol.ControlPreset
import com.alexanderlavrushko.bleservo.protocol.ServoBleProtocol
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class ControlMode { Sliders, Buttons }

data class MainUiState(
    val bleState: BleConnectionState = BleConnectionState.Idle,
    val devices: List<BleDiscoveredDevice> = emptyList(),
    val selectedDeviceAddress: String? = null,
    val controlMode: ControlMode = ControlMode.Sliders,
    val preset: ControlPreset = ControlPreset.defaults,
    val drivingAxis: Float = 0f,
    val steeringAxis: Float = 0f,
    val drivingServo: Int = 127,
    val steeringServo: Int = 127,
    val errorText: String? = null,
    val logs: List<String> = emptyList(),
)

class MainViewModel(application: Application) : AndroidViewModel(application), BleServoListener {
    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState

    private val transport = BleServoTransport(application, this)

    private var drivingAnimationJob: Job? = null
    private var steeringAnimationJob: Job? = null

    fun isBluetoothEnabled(): Boolean = transport.isBluetoothEnabled()

    fun refreshBluetoothState() {
        transport.refreshBluetoothState()
    }

    fun startScan() {
        _uiState.update { it.copy(devices = emptyList(), errorText = null) }
        transport.startScan()
    }

    fun stopScan() {
        transport.stopScan()
    }

    fun setSelectedDevice(address: String?) {
        _uiState.update { it.copy(selectedDeviceAddress = address) }
    }

    fun connectSelected() {
        val selected = uiState.value.selectedDeviceAddress ?: run {
            onError("Select a device first")
            return
        }
        val device = uiState.value.devices.firstOrNull { it.address == selected } ?: run {
            onError("Selected device not in scan list")
            return
        }
        transport.connect(device)
    }

    fun disconnect() {
        transport.disconnect()
    }

    fun setControlMode(mode: ControlMode) {
        _uiState.update { it.copy(controlMode = mode) }
    }

    fun setPreset(name: String) {
        val preset = ControlPreset.all.firstOrNull { it.name == name } ?: return
        _uiState.update { state ->
            val drivingServo = AxisConverter(preset.driving.outputConfig).axisToServo(state.drivingAxis)
            val steeringServo = AxisConverter(preset.steering.outputConfig).axisToServo(state.steeringAxis)
            state.copy(
                preset = preset,
                drivingServo = drivingServo,
                steeringServo = steeringServo,
            )
        }
        publishServoValues()
    }

    fun onSliderChanged(isDriving: Boolean, axisValue: Float) {
        val preset = uiState.value.preset
        val axis = axisValue.coerceIn(-1f, 1f)
        _uiState.update { state ->
            if (isDriving) {
                val servo = AxisConverter(preset.driving.outputConfig).axisToServo(axis)
                state.copy(drivingAxis = axis, drivingServo = servo)
            } else {
                val servo = AxisConverter(preset.steering.outputConfig).axisToServo(axis)
                state.copy(steeringAxis = axis, steeringServo = servo)
            }
        }
        publishServoValues()
    }

    fun onSliderReleased(isDriving: Boolean) {
        val config = if (isDriving) uiState.value.preset.driving else uiState.value.preset.steering
        animateAxisToTarget(isDriving, 0f, config)
    }

    fun onButtonPressed(isDriving: Boolean, positive: Boolean) {
        val target = if (positive) 1f else -1f
        val config = if (isDriving) uiState.value.preset.driving else uiState.value.preset.steering
        val current = if (isDriving) uiState.value.drivingAxis else uiState.value.steeringAxis
        if ((positive && current < 0f) || (!positive && current > 0f)) {
            onSliderChanged(isDriving, 0f)
        }
        animateAxisToTarget(isDriving, target, config)
    }

    fun onButtonReleased(isDriving: Boolean) {
        val config = if (isDriving) uiState.value.preset.driving else uiState.value.preset.steering
        animateAxisToTarget(isDriving, 0f, config)
    }

    private fun animateAxisToTarget(isDriving: Boolean, target: Float, config: ChannelConfig) {
        val currentJob = if (isDriving) drivingAnimationJob else steeringAnimationJob
        currentJob?.cancel()

        val newJob = viewModelScope.launch {
            var current = if (isDriving) uiState.value.drivingAxis else uiState.value.steeringAxis
            val stepBase = 0.03f * config.animationSpeed.coerceAtLeast(0.2f)
            while (kotlin.math.abs(current - target) > 0.01f) {
                val delta = (target - current)
                val step = delta.coerceIn(-stepBase, stepBase)
                current += step
                onSliderChanged(isDriving, current)
                delay(16)
            }
            onSliderChanged(isDriving, target)
        }

        if (isDriving) {
            drivingAnimationJob = newJob
        } else {
            steeringAnimationJob = newJob
        }
    }

    private fun publishServoValues() {
        val state = uiState.value
        val positions = MutableList(ServoBleProtocol.expectedChannelCount) { 127 }
        positions[state.preset.driving.channelIndex] = state.drivingServo
        positions[state.preset.steering.channelIndex] = state.steeringServo
        transport.writePositions(positions)
    }

    override fun onStateChanged(state: BleConnectionState) {
        _uiState.update { it.copy(bleState = state) }
    }

    override fun onDeviceDiscovered(device: BleDiscoveredDevice) {
        _uiState.update { state ->
            val updated = state.devices
                .filterNot { it.address == device.address }
                .plus(device)
                .sortedByDescending { it.rssi }
            val selected = state.selectedDeviceAddress ?: updated.firstOrNull()?.address
            state.copy(devices = updated, selectedDeviceAddress = selected)
        }
    }

    override fun onPositionsUpdated(positions: List<Int>) {
        if (positions.size < ServoBleProtocol.expectedChannelCount) return
        val preset = uiState.value.preset
        val driveRaw = positions.getOrElse(preset.driving.channelIndex) { 127 }
        val steerRaw = positions.getOrElse(preset.steering.channelIndex) { 127 }

        val driveAxis = AxisConverter(preset.driving.outputConfig).servoToAxis(driveRaw)
        val steerAxis = AxisConverter(preset.steering.outputConfig).servoToAxis(steerRaw)

        _uiState.update {
            it.copy(
                drivingAxis = driveAxis,
                steeringAxis = steerAxis,
                drivingServo = driveRaw,
                steeringServo = steerRaw,
            )
        }
    }

    override fun onError(message: String) {
        _uiState.update { it.copy(errorText = message) }
        addLog("ERROR: $message")
    }

    override fun onLog(message: String) {
        addLog(message)
    }

    fun clearError() {
        _uiState.update { it.copy(errorText = null) }
    }

    private fun addLog(message: String) {
        _uiState.update { state ->
            val logs = (state.logs + message).takeLast(300)
            state.copy(logs = logs)
        }
    }

    override fun onCleared() {
        transport.cleanup()
        super.onCleared()
    }
}
