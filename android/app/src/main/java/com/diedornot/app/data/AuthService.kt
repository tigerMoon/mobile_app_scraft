package com.diedornot.app.data

import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.Email

/**
 * Authentication service
 * Handles anonymous authentication flow
 *
 * Design principle:
 * - Anonymous auth is automatic on first launch
 * - No login/signup UI needed
 * - Supabase generates unique user_id automatically
 */
class AuthService {
    private val auth = SupabaseClient.instance.auth

    /**
     * Sign in anonymously
     * Called automatically when app launches if not authenticated
     */
    suspend fun signInAnonymously() {
        try {
            auth.signInAnonymously()
        } catch (e: Exception) {
            throw AuthException("Anonymous sign-in failed: ${e.message}")
        }
    }

    /**
     * Check if user is currently authenticated
     */
    fun isAuthenticated(): Boolean {
        return auth.currentUserOrNull() != null
    }

    /**
     * Get current user ID
     * Returns null if not authenticated
     */
    fun getCurrentUserId(): String? {
        return auth.currentUserOrNull()?.id
    }

    /**
     * Sign out current user
     */
    suspend fun signOut() {
        auth.signOut()
    }
}

class AuthException(message: String) : Exception(message)
