package com.diedornot.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.diedornot.app.ui.CheckInScreen
import com.diedornot.app.ui.theme.DiedOrNotTheme

/**
 * Main activity - App entry point
 *
 * Minimal structure following modern Android architecture:
 * - Single Activity
 * - Jetpack Compose for UI
 * - Material 3 theming
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            DiedOrNotTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    CheckInScreen()
                }
            }
        }
    }
}
