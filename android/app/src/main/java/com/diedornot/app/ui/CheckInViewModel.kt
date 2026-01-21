package com.diedornot.app.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.diedornot.app.data.AuthService
import com.diedornot.app.data.CheckInRepository
import com.diedornot.app.model.CheckIn
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for check-in screen
 * Manages UI state and business logic
 *
 * Design pattern: Unidirectional data flow
 * - State flows down from ViewModel to UI
 * - Events flow up from UI to ViewModel
 */
class CheckInViewModel : ViewModel() {
    private val authService = AuthService()
    private val checkInRepository = CheckInRepository()

    // UI State
    private val _uiState = MutableStateFlow(CheckInUiState())
    val uiState: StateFlow<CheckInUiState> = _uiState.asStateFlow()

    init {
        initializeAuth()
    }

    /**
     * Initialize authentication
     * Sign in anonymously if not already authenticated
     */
    private fun initializeAuth() {
        viewModelScope.launch {
            try {
                if (!authService.isAuthenticated()) {
                    authService.signInAnonymously()
                }
                loadCheckInStatus()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "认证失败: ${e.message}"
                )
            }
        }
    }

    /**
     * Load today's check-in status
     */
    private fun loadCheckInStatus() {
        viewModelScope.launch {
            try {
                val hasCheckedIn = checkInRepository.hasCheckedInToday()
                _uiState.value = _uiState.value.copy(
                    hasCheckedInToday = hasCheckedIn,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "加载失败: ${e.message}",
                    isLoading = false
                )
            }
        }
    }

    /**
     * Perform check-in for today
     * Called when user taps the check-in button
     */
    fun checkIn() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                isLoading = true,
                error = null
            )

            try {
                checkInRepository.checkInToday()
                _uiState.value = _uiState.value.copy(
                    hasCheckedInToday = true,
                    isLoading = false,
                    successMessage = "签到成功!"
                )
            } catch (e: Exception) {
                val errorMessage = when {
                    e.message?.contains("duplicate") == true -> "今天已经签到过了"
                    else -> "签到失败: ${e.message}"
                }
                _uiState.value = _uiState.value.copy(
                    error = errorMessage,
                    isLoading = false
                )
            }
        }
    }

    /**
     * Load check-in history
     */
    fun loadCheckInHistory() {
        viewModelScope.launch {
            try {
                val checkIns = checkInRepository.getMyCheckIns()
                _uiState.value = _uiState.value.copy(
                    checkInHistory = checkIns
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "加载历史记录失败: ${e.message}"
                )
            }
        }
    }

    /**
     * Clear error message
     */
    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }

    /**
     * Clear success message
     */
    fun clearSuccessMessage() {
        _uiState.value = _uiState.value.copy(successMessage = null)
    }
}

/**
 * UI state for check-in screen
 * Immutable data class for state management
 */
data class CheckInUiState(
    val hasCheckedInToday: Boolean = false,
    val isLoading: Boolean = true,
    val error: String? = null,
    val successMessage: String? = null,
    val checkInHistory: List<CheckIn> = emptyList()
)
