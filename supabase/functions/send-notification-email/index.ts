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
    const { name, emergency_email, id } = await req.json();

    console.log(`📧 Preparing to notify ${emergency_email}`);
    console.log(`👤 User: ${name} (ID: ${id})`);
    console.log(`⚠️ User has missed check-ins for 2+ days`);

    // 在实际生产环境中，这里应该集成真实的邮件服务
    // 例如: SendGrid, AWS SES, Resend 等
    // 示例代码:
    /*
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [{
          to: [{ email: emergency_email }],
          subject: `⚠️ ${name} 可能需要关注`,
        }],
        from: { email: 'noreply@diedornot.app' },
        content: [{
          type: 'text/html',
          value: `<p>${name} 已经连续 2 天未签到，请关注他们的情况。</p>`
        }]
      })
    });
    */

    // 目前只记录日志
    console.log("✅ Notification logged (email service not configured)");

    return new Response(
      JSON.stringify({
        success: true,
        message: "Notification logged",
        recipient: emergency_email,
        timestamp: new Date().toISOString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    );

  } catch (error) {
    console.error("❌ Error in send-notification-email:", error);
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