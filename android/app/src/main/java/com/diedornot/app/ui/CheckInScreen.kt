package com.diedornot.app.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.diedornot.app.model.CheckIn

/**
 * Check-in screen - Main UI
 *
 * Design philosophy (mirrors iOS CheckInView):
 * - Declarative UI with Jetpack Compose
 * - State-driven updates (no manual UI manipulation)
 * - Single source of truth (ViewModel state)
 */
@Composable
fun CheckInScreen(
    viewModel: CheckInViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    // Show snackbar for errors and success messages
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(uiState.error) {
        uiState.error?.let { error ->
            snackbarHostState.showSnackbar(error)
            viewModel.clearError()
        }
    }

    LaunchedEffect(uiState.successMessage) {
        uiState.successMessage?.let { message ->
            snackbarHostState.showSnackbar(message)
            viewModel.clearSuccessMessage()
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = { Text("Died Or Not") }
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when {
                uiState.isLoading -> {
                    LoadingView()
                }
                else -> {
                    CheckInContent(
                        uiState = uiState,
                        onCheckIn = { viewModel.checkIn() },
                        onLoadHistory = { viewModel.loadCheckInHistory() }
                    )
                }
            }
        }
    }
}

@Composable
private fun LoadingView() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }
}

@Composable
private fun CheckInContent(
    uiState: CheckInUiState,
    onCheckIn: () -> Unit,
    onLoadHistory: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        // Status card
        StatusCard(hasCheckedIn = uiState.hasCheckedInToday)

        // Check-in button
        CheckInButton(
            hasCheckedIn = uiState.hasCheckedInToday,
            isLoading = uiState.isLoading,
            onClick = onCheckIn
        )

        // History button
        OutlinedButton(
            onClick = onLoadHistory,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("查看历史记录")
        }

        // History list
        if (uiState.checkInHistory.isNotEmpty()) {
            CheckInHistoryList(checkIns = uiState.checkInHistory)
        }
    }
}

@Composable
private fun StatusCard(hasCheckedIn: Boolean) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = if (hasCheckedIn) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surfaceVariant
            }
        )
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = if (hasCheckedIn) "✓" else "•",
                style = MaterialTheme.typography.displayLarge,
                color = if (hasCheckedIn) {
                    MaterialTheme.colorScheme.primary
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant
                }
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = if (hasCheckedIn) "今日已签到" else "今日未签到",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun CheckInButton(
    hasCheckedIn: Boolean,
    isLoading: Boolean,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        enabled = !hasCheckedIn && !isLoading,
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(24.dp),
                color = MaterialTheme.colorScheme.onPrimary
            )
        } else {
            Text(
                text = if (hasCheckedIn) "今日已签到" else "签到",
                style = MaterialTheme.typography.titleMedium
            )
        }
    }
}

@Composable
private fun CheckInHistoryList(checkIns: List<CheckIn>) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = "签到历史",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(8.dp))
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(4.dp),
                modifier = Modifier.heightIn(max = 300.dp)
            ) {
                items(checkIns) { checkIn ->
                    CheckInHistoryItem(checkIn)
                }
            }
        }
    }
}

@Composable
private fun CheckInHistoryItem(checkIn: CheckIn) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = checkIn.checkInDate,
            style = MaterialTheme.typography.bodyLarge
        )
        Text(
            text = "✓",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.primary
        )
    }
}
