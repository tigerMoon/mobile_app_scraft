import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Missing environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    console.log("🔍 Checking for missed check-ins...");

    // 获取所有用户
    const { data: users, error: usersError } = await supabase
      .from("users")
      .select("*");

    if (usersError) {
      throw usersError;
    }

    console.log(`📋 Found ${users?.length || 0} users`);

    let notificationCount = 0;

    for (const user of users ?? []) {
      // 获取用户最后一次签到记录
      const { data: checkIns, error: checkInsError } = await supabase
        .from("check_ins")
        .select("check_in_date")
        .eq("user_id", user.id)
        .order("check_in_date", { ascending: false })
        .limit(1);

      if (checkInsError) {
        console.error(`❌ Error fetching check-ins for user ${user.id}:`, checkInsError);
        continue;
      }

      // 如果没有签到记录，跳过
      if (!checkIns || checkIns.length === 0) {
        console.log(`⚠️ User ${user.id} has no check-ins`);
        continue;
      }

      const lastCheckIn = new Date(checkIns[0].check_in_date);
      const today = new Date();
      const diffInMs = today.getTime() - lastCheckIn.getTime();
      const diffInDays = diffInMs / (1000 * 60 * 60 * 24);

      console.log(`👤 User ${user.id}: last check-in ${diffInDays.toFixed(1)} days ago`);

      // 如果超过 2 天未签到，发送通知
      if (diffInDays >= 2) {
        console.log(`🚨 Sending notification for user ${user.id}`);

        try {
          const notifyResponse = await fetch(
            `${supabaseUrl}/functions/v1/send-notification-email`,
            {
              method: "POST",
              headers: {
                "Authorization": `Bearer ${supabaseServiceKey}`,
                "Content-Type": "application/json"
              },
              body: JSON.stringify(user)
            }
          );

          if (!notifyResponse.ok) {
            console.error(`❌ Failed to send notification: ${notifyResponse.statusText}`);
          } else {
            notificationCount++;
            console.log(`✅ Notification sent for user ${user.id}`);
          }
        } catch (notifyError) {
          console.error(`❌ Error sending notification:`, notifyError);
        }
      }
    }

    const result = {
      success: true,
      usersChecked: users?.length || 0,
      notificationsSent: notificationCount,
      timestamp: new Date().toISOString()
    };

    console.log("✅ Check completed:", result);

    return new Response(
      JSON.stringify(result),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    );

  } catch (error) {
    console.error("❌ Error in check-missed-check-ins:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }
});