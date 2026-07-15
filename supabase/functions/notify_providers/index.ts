import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { JWT } from 'https://esm.sh/google-auth-library@9'

// This Edge Function is triggered by a Database Webhook when a new Request is inserted.
// It fetches available providers, gets their FCM tokens, and sends push notifications.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // The payload from the database webhook
    const payload = await req.json()
    const record = payload.record

    if (record.status !== 'Pending_Broadcast') {
      return new Response(JSON.stringify({ message: "Not pending broadcast" }), { headers: corsHeaders })
    }

    // Call our RPC to get available providers
    const { data: providers, error: rpcError } = await supabase.rpc('get_available_providers', {
      p_category_id: record.category_id
    });

    if (rpcError) throw rpcError;
    if (!providers || providers.length === 0) {
      return new Response(JSON.stringify({ message: "No available providers found" }), { headers: corsHeaders })
    }

    const tokens = providers.map((p: any) => p.fcm_token).filter((t: any) => t != null);
    
    if (tokens.length === 0) {
      return new Response(JSON.stringify({ message: "No FCM tokens found for providers" }), { headers: corsHeaders })
    }

    // ---------------------------------------------------------
    // To send via FCM HTTP v1, you need to generate an access token
    // using your firebase-adminsdk.json service account.
    // Deno edge functions require passing the private key via env vars.
    // ---------------------------------------------------------
    
    // 1. Load Service Account from Env Vars
    const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')
    const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n')
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')

    if (!clientEmail || !privateKey || !projectId) {
       return new Response(JSON.stringify({ error: "Firebase credentials missing in env" }), { headers: corsHeaders })
    }

    // 2. Generate Access Token
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    
    const tokenResponse = await jwtClient.getAccessToken()
    const accessToken = tokenResponse.token

    // 3. Send Notification to all tokens (Looping or sending individually, FCM HTTP v1 supports individual messages, we can use Promise.all)
    const responses = await Promise.all(tokens.map(async (token: String) => {
        const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({
                message: {
                    token: token,
                    notification: {
                        title: "طلب خدمة جديد!",
                        body: record.description || "يوجد طلب جديد متاح في تخصصك."
                    },
                    data: {
                        request_id: record.id
                    }
                }
            })
        });
        return await res.json();
    }));

    return new Response(JSON.stringify({ success: true, responses }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 })
  }
})
