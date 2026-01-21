package com.diedornot.app.data

import com.diedornot.app.model.CheckIn
import io.github.jan.supabase.postgrest.from
import io.github.jan.supabase.postgrest.query.Columns
import java.time.LocalDate

/**
 * Repository for check-in operations
 *
 * Design principles (from CLAUDE.md):
 * - All security enforced by RLS policies (supabase/migrations/002_rls.sql)
 * - Duplicate prevention via database constraint (unique user_id + check_in_date)
 * - NO permission checks in application code - trust the database
 */
class CheckInRepository {
    private val supabase = SupabaseClient.instance

    /**
     * Check in for today
     * If already checked in today, database constraint will prevent duplicate
     *
     * @throws Exception if check-in fails (e.g., duplicate constraint violation)
     */
    suspend fun checkInToday() {
        val today = LocalDate.now().toString()

        supabase.from("check_ins").insert(
            CheckIn(checkInDate = today)
        )
    }

    /**
     * Get all check-ins for current user
     * RLS policy automatically filters by auth.uid()
     *
     * @return List of check-ins, sorted by date descending
     */
    suspend fun getMyCheckIns(): List<CheckIn> {
        return supabase.from("check_ins")
            .select {
                order("check_in_date", ascending = false)
            }
            .decodeList<CheckIn>()
    }

    /**
     * Check if user has checked in today
     *
     * @return true if checked in today, false otherwise
     */
    suspend fun hasCheckedInToday(): Boolean {
        val today = LocalDate.now().toString()

        val result = supabase.from("check_ins")
            .select(columns = Columns.list("id")) {
                filter {
                    eq("check_in_date", today)
                }
            }
            .decodeList<CheckIn>()

        return result.isNotEmpty()
    }
}
