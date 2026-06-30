package com.alexanderlavrushko.bleservo.ui

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.ListView
import android.widget.SeekBar
import android.widget.Spinner
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.alexanderlavrushko.bleservo.R
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    private val viewModel: MainViewModel by viewModels()

    private lateinit var statusText: TextView
    private lateinit var errorText: TextView
    private lateinit var scanButton: Button
    private lateinit var connectButton: Button
    private lateinit var disconnectButton: Button
    private lateinit var devicesList: ListView
    private lateinit var modeSpinner: Spinner
    private lateinit var presetSpinner: Spinner

    private lateinit var drivingSeekBar: SeekBar
    private lateinit var steeringSeekBar: SeekBar
    private lateinit var drivingServoText: TextView
    private lateinit var steeringServoText: TextView

    private lateinit var drivingMinusButton: Button
    private lateinit var drivingPlusButton: Button
    private lateinit var steeringMinusButton: Button
    private lateinit var steeringPlusButton: Button

    private lateinit var logsText: TextView

    private val permissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { result ->
            val granted = result.values.all { it }
            if (granted) {
                maybeEnableBluetoothAndStartScan()
            } else {
                showError("Bluetooth permissions denied")
            }
        }

    private val enableBluetoothLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            viewModel.refreshBluetoothState()
            if (viewModel.isBluetoothEnabled()) {
                viewModel.startScan()
            }
        }

    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
                viewModel.refreshBluetoothState()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        bindViews()
        bindActions()
        collectState()
    }

    override fun onStart() {
        super.onStart()
        registerReceiver(bluetoothReceiver, IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED))
    }

    override fun onStop() {
        runCatching { unregisterReceiver(bluetoothReceiver) }
        super.onStop()
    }

    private fun bindViews() {
        statusText = findViewById(R.id.textStatus)
        errorText = findViewById(R.id.textError)
        scanButton = findViewById(R.id.buttonScan)
        connectButton = findViewById(R.id.buttonConnect)
        disconnectButton = findViewById(R.id.buttonDisconnect)
        devicesList = findViewById(R.id.listDevices)
        modeSpinner = findViewById(R.id.spinnerMode)
        presetSpinner = findViewById(R.id.spinnerPreset)

        drivingSeekBar = findViewById(R.id.seekDriving)
        steeringSeekBar = findViewById(R.id.seekSteering)
        drivingServoText = findViewById(R.id.textDrivingServo)
        steeringServoText = findViewById(R.id.textSteeringServo)

        drivingMinusButton = findViewById(R.id.buttonDrivingMinus)
        drivingPlusButton = findViewById(R.id.buttonDrivingPlus)
        steeringMinusButton = findViewById(R.id.buttonSteeringMinus)
        steeringPlusButton = findViewById(R.id.buttonSteeringPlus)

        logsText = findViewById(R.id.textLogs)

        modeSpinner.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, listOf("Sliders", "Buttons"))
        presetSpinner.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, listOf("Default", "My Car"))
    }

    private fun bindActions() {
        scanButton.setOnClickListener {
            ensureBluetoothReadyThenScan()
        }

        connectButton.setOnClickListener {
            viewModel.connectSelected()
        }

        disconnectButton.setOnClickListener {
            viewModel.disconnect()
        }

        devicesList.setOnItemClickListener { _, _, position, _ ->
            val selected = viewModel.uiState.value.devices.getOrNull(position)
            viewModel.setSelectedDevice(selected?.address)
        }

        modeSpinner.setSelection(0)
        modeSpinner.setOnItemSelectedListener(SimpleItemSelectedListener { position ->
            viewModel.setControlMode(if (position == 0) ControlMode.Sliders else ControlMode.Buttons)
        })

        presetSpinner.setSelection(0)
        presetSpinner.setOnItemSelectedListener(SimpleItemSelectedListener { position ->
            viewModel.setPreset(if (position == 0) "Default" else "My Car")
        })

        setupSeekBar(drivingSeekBar, isDriving = true)
        setupSeekBar(steeringSeekBar, isDriving = false)

        setButtonPressHandlers(drivingMinusButton, isDriving = true, positive = false)
        setButtonPressHandlers(drivingPlusButton, isDriving = true, positive = true)
        setButtonPressHandlers(steeringMinusButton, isDriving = false, positive = false)
        setButtonPressHandlers(steeringPlusButton, isDriving = false, positive = true)

        errorText.setOnClickListener { viewModel.clearError() }
    }

    private fun setupSeekBar(seekBar: SeekBar, isDriving: Boolean) {
        seekBar.max = 200
        seekBar.progress = 100
        seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (!fromUser) return
                val axis = ((progress - 100) / 100f).coerceIn(-1f, 1f)
                viewModel.onSliderChanged(isDriving, axis)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) = Unit

            override fun onStopTrackingTouch(seekBar: SeekBar?) {
                viewModel.onSliderReleased(isDriving)
            }
        })
    }

    private fun setButtonPressHandlers(button: Button, isDriving: Boolean, positive: Boolean) {
        button.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                android.view.MotionEvent.ACTION_DOWN -> viewModel.onButtonPressed(isDriving, positive)
                android.view.MotionEvent.ACTION_UP,
                android.view.MotionEvent.ACTION_CANCEL,
                android.view.MotionEvent.ACTION_OUTSIDE -> viewModel.onButtonReleased(isDriving)
            }
            false
        }
    }

    private fun collectState() {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    statusText.text = getString(R.string.status_template, state.bleState.name)
                    errorText.text = state.errorText ?: ""
                    errorText.visibility = if (state.errorText != null) TextView.VISIBLE else TextView.GONE

                    val adapter = ArrayAdapter(
                        this@MainActivity,
                        android.R.layout.simple_list_item_single_choice,
                        state.devices.map { "${it.name} (${it.address}) RSSI=${it.rssi}" }
                    )
                    devicesList.adapter = adapter
                    devicesList.choiceMode = ListView.CHOICE_MODE_SINGLE
                    val selectedIndex = state.devices.indexOfFirst { it.address == state.selectedDeviceAddress }
                    if (selectedIndex >= 0) {
                        devicesList.setItemChecked(selectedIndex, true)
                    }

                    val drivingProgress = ((state.drivingAxis.coerceIn(-1f, 1f) + 1f) * 100f).toInt()
                    val steeringProgress = ((state.steeringAxis.coerceIn(-1f, 1f) + 1f) * 100f).toInt()
                    if (!drivingSeekBar.isPressed) drivingSeekBar.progress = drivingProgress
                    if (!steeringSeekBar.isPressed) steeringSeekBar.progress = steeringProgress

                    drivingServoText.text = getString(R.string.axis_value_template, state.drivingAxis, state.drivingServo)
                    steeringServoText.text = getString(R.string.axis_value_template, state.steeringAxis, state.steeringServo)

                    val slidersVisible = state.controlMode == ControlMode.Sliders
                    drivingSeekBar.visibility = if (slidersVisible) SeekBar.VISIBLE else SeekBar.GONE
                    steeringSeekBar.visibility = if (slidersVisible) SeekBar.VISIBLE else SeekBar.GONE

                    val buttonsVisible = !slidersVisible
                    val buttonsVisibility = if (buttonsVisible) Button.VISIBLE else Button.GONE
                    drivingMinusButton.visibility = buttonsVisibility
                    drivingPlusButton.visibility = buttonsVisibility
                    steeringMinusButton.visibility = buttonsVisibility
                    steeringPlusButton.visibility = buttonsVisibility

                    logsText.text = state.logs.joinToString("\n")
                }
            }
        }
    }

    private fun ensureBluetoothReadyThenScan() {
        val permissions = requiredBluetoothPermissions()
        val missing = permissions.filterNot { hasPermission(it) }
        if (missing.isNotEmpty()) {
            permissionLauncher.launch(missing.toTypedArray())
            return
        }
        maybeEnableBluetoothAndStartScan()
    }

    private fun maybeEnableBluetoothAndStartScan() {
        if (viewModel.isBluetoothEnabled()) {
            viewModel.startScan()
            return
        }
        val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        enableBluetoothLauncher.launch(intent)
    }

    private fun requiredBluetoothPermissions(): List<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            listOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            listOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun showError(message: String) {
        AlertDialog.Builder(this)
            .setTitle(R.string.app_name)
            .setMessage(message)
            .setPositiveButton(android.R.string.ok, null)
            .show()
    }
}
