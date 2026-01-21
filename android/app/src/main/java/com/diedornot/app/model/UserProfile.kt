package com.diedornot.app.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * User profile model
 * Maps to the 'users' table in Supabase
 *
 * Schema (from supabase/migrations/001_init.sql):
 * - id: UUID (references auth.users)
 * - name: TEXT
 * - emergency_email: TEXT
 * - created_at: TIMESTAMPTZ
 */
@Serializable
data class UserProfile(
    val id: String,
    val name: String? = null,
    @SerialName("emergency_email")
    val emergencyEmail: String? = null,
    @SerialName("created_at")
    val createdAt: String? = null
)
