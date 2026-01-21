package com.diedornot.app.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Check-in model
 * Maps to the 'check_ins' table in Supabase
 *
 * Schema (from supabase/migrations/001_init.sql):
 * - id: UUID (auto-generated)
 * - user_id: UUID (foreign key to users)
 * - check_in_date: DATE
 * - created_at: TIMESTAMPTZ
 *
 * Important constraint:
 * - UNIQUE (user_id, check_in_date) - prevents duplicate check-ins
 *   This is enforced at the DATABASE level, not in app code
 */
@Serializable
data class CheckIn(
    val id: String? = null,
    @SerialName("user_id")
    val userId: String? = null,
    @SerialName("check_in_date")
    val checkInDate: String,
    @SerialName("created_at")
    val createdAt: String? = null
)
