package com.alexanderlavrushko.bleservo.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.Build
import android.os.ParcelUuid
import com.alexanderlavrushko.bleservo.protocol.ServoBleProtocol
import kotlin.collections.ArrayDeque

enum class BleConnectionState {
    BluetoothOff,
    Idle,
    Scanning,
    Connecting,
    Discovering,
    Ready,
}

data class BleDiscoveredDevice(
    val name: String,
    val address: String,
    val rssi: Int,
)

interface BleServoListener {
    fun onStateChanged(state: BleConnectionState)
    fun onDeviceDiscovered(device: BleDiscoveredDevice)
    fun onPositionsUpdated(positions: List<Int>)
    fun onError(message: String)
    fun onLog(message: String)
}

class BleServoTransport(
    context: Context,
    private val listener: BleServoListener,
) {
    private val appContext = context.applicationContext
    private val bluetoothManager = appContext.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val adapter: BluetoothAdapter? get() = bluetoothManager.adapter
    private val scanner get() = adapter?.bluetoothLeScanner

    private var connectedGatt: BluetoothGatt? = null
    private var positionCharacteristic: BluetoothGattCharacteristic? = null
    private var shouldStayConnected = false
    private var pendingDevice: BluetoothDevice? = null

    private var operationInProgress = false
    private val operationQueue = ArrayDeque<() -> Boolean>()
    private var delayedWrite: ByteArray? = null

    private var isScanning = false

    init {
        updateState(
            if (adapter?.isEnabled == true) BleConnectionState.Idle else BleConnectionState.BluetoothOff
        )
    }

    private var state: BleConnectionState = BleConnectionState.Idle
        set(value) {
            if (field == value) return
            field = value
            listener.onStateChanged(value)
            listener.onLog("BLE state = $value")
        }

    fun isBluetoothEnabled(): Boolean = adapter?.isEnabled == true

    fun refreshBluetoothState() {
        if (!isBluetoothEnabled()) {
            stopScan()
            clearGatt()
            updateState(BleConnectionState.BluetoothOff)
        } else if (state == BleConnectionState.BluetoothOff) {
            updateState(BleConnectionState.Idle)
        }
    }

    fun startScan() {
        if (!isBluetoothEnabled()) {
            updateState(BleConnectionState.BluetoothOff)
            listener.onError("Bluetooth is OFF")
            return
        }
        if (isScanning) return

        val bleScanner = scanner ?: run {
            listener.onError("BLE scanner unavailable")
            return
        }

        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(ServoBleProtocol.serviceUuid))
            .build()

        val settings = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_BALANCED)
                .setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES)
                .setMatchMode(ScanSettings.MATCH_MODE_AGGRESSIVE)
                .setNumOfMatches(ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT)
                .build()
        } else {
            ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_BALANCED)
                .build()
        }

        isScanning = true
        updateState(BleConnectionState.Scanning)
        listener.onLog("Start scanning for ${ServoBleProtocol.serviceUuid}")
        bleScanner.startScan(listOf(filter), settings, scanCallback)
    }

    fun stopScan() {
        if (!isScanning) return
        isScanning = false
        scanner?.stopScan(scanCallback)
        listener.onLog("Scan stopped")
        if (!shouldStayConnected && connectedGatt == null) {
            updateState(BleConnectionState.Idle)
        }
    }

    fun connect(device: BleDiscoveredDevice) {
        shouldStayConnected = true
        pendingDevice = adapter?.getRemoteDevice(device.address)
        connectPendingDevice()
    }

    fun disconnect() {
        shouldStayConnected = false
        pendingDevice = null
        stopScan()
        connectedGatt?.disconnect()
        clearGatt()
        updateState(if (isBluetoothEnabled()) BleConnectionState.Idle else BleConnectionState.BluetoothOff)
    }

    fun cleanup() {
        shouldStayConnected = false
        stopScan()
        clearGatt()
    }

    fun writePositions(positions: List<Int>) {
        val bytes = ServoBleProtocol.encodePositions(positions)
        if (operationInProgress) {
            delayedWrite = bytes
            return
        }
        queueOperation {
            val gatt = connectedGatt ?: return@queueOperation false
            val characteristic = positionCharacteristic ?: return@queueOperation false
            characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            characteristic.value = bytes
            val started = gatt.writeCharacteristic(characteristic)
            if (started) {
                listener.onLog("Write positions: ${ServoBleProtocol.decodePositions(bytes)}")
            }
            started
        }
    }

    private fun connectPendingDevice() {
        val device = pendingDevice ?: run {
            listener.onError("No selected device")
            return
        }
        stopScan()
        clearGatt()
        updateState(BleConnectionState.Connecting)
        listener.onLog("Connecting to ${device.address}")
        connectedGatt = device.connectGatt(appContext, false, gattCallback)
    }

    private fun queueOperation(operation: () -> Boolean) {
        operationQueue.add(operation)
        processNextOperation()
    }

    private fun processNextOperation() {
        if (operationInProgress) return
        val op = operationQueue.removeFirstOrNull() ?: return
        operationInProgress = true
        val started = op()
        if (!started) {
            listener.onError("Failed to start BLE operation")
            onOperationComplete()
        }
    }

    private fun onOperationComplete() {
        operationInProgress = false
        val postponed = delayedWrite
        if (postponed != null) {
            delayedWrite = null
            writePositions(ServoBleProtocol.decodePositions(postponed))
            return
        }
        processNextOperation()
    }

    private fun clearGatt() {
        operationQueue.clear()
        operationInProgress = false
        delayedWrite = null
        positionCharacteristic = null
        connectedGatt?.close()
        connectedGatt = null
    }

    private fun updateState(newState: BleConnectionState) {
        state = newState
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device ?: return
            listener.onDeviceDiscovered(
                BleDiscoveredDevice(
                    name = result.scanRecord?.deviceName ?: device.name ?: "Unknown",
                    address = device.address,
                    rssi = result.rssi,
                )
            )
        }

        override fun onScanFailed(errorCode: Int) {
            isScanning = false
            listener.onError("Scan failed: $errorCode")
            updateState(BleConnectionState.Idle)
            if (shouldStayConnected) startScan()
        }
    }

    @SuppressLint("MissingPermission")
    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            val isSuccess = status == BluetoothGatt.GATT_SUCCESS
            if (isSuccess && newState == BluetoothProfile.STATE_CONNECTED) {
                listener.onLog("Connected to ${gatt.device.address}")
                updateState(BleConnectionState.Discovering)
                // Request MTU first to reduce retries on some stacks.
                if (!gatt.requestMtu(128)) {
                    gatt.discoverServices()
                }
                return
            }

            if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                listener.onLog("Disconnected from ${gatt.device.address}, status=$status")
                clearGatt()
                updateState(if (isBluetoothEnabled()) BleConnectionState.Idle else BleConnectionState.BluetoothOff)
                if (shouldStayConnected && isBluetoothEnabled()) {
                    pendingDevice?.let {
                        connectPendingDevice()
                    } ?: startScan()
                }
                return
            }

            if (!isSuccess) {
                listener.onError("Connection error status=$status")
                clearGatt()
                updateState(if (isBluetoothEnabled()) BleConnectionState.Idle else BleConnectionState.BluetoothOff)
                if (shouldStayConnected && isBluetoothEnabled()) {
                    pendingDevice?.let {
                        connectPendingDevice()
                    } ?: startScan()
                }
            }
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            listener.onLog("MTU changed mtu=$mtu status=$status")
            gatt.discoverServices()
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                listener.onError("Service discovery failed: $status")
                gatt.disconnect()
                return
            }

            val service = gatt.getService(ServoBleProtocol.serviceUuid)
            if (service == null) {
                listener.onError("Servo service not found")
                gatt.disconnect()
                return
            }
            val posChar = service.getCharacteristic(ServoBleProtocol.positionCharUuid)
            if (posChar == null) {
                listener.onError("Servo position characteristic not found")
                gatt.disconnect()
                return
            }
            positionCharacteristic = posChar
            queueOperation {
                val started = gatt.readCharacteristic(posChar)
                if (started) listener.onLog("Reading initial positions")
                started
            }
            updateState(BleConnectionState.Ready)
        }

        @Deprecated("Deprecated in Java")
        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int,
        ) {
            if (characteristic.uuid == ServoBleProtocol.positionCharUuid) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    val positions = ServoBleProtocol.decodePositions(characteristic.value ?: byteArrayOf())
                    listener.onLog("Read positions: $positions")
                    listener.onPositionsUpdated(positions)
                } else {
                    listener.onError("Read failed status=$status")
                }
                onOperationComplete()
            }
        }

        @Deprecated("Deprecated in Java")
        override fun onCharacteristicWrite(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int,
        ) {
            if (characteristic.uuid == ServoBleProtocol.positionCharUuid) {
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    listener.onError("Write failed status=$status")
                }
                onOperationComplete()
            }
        }
    }
}
