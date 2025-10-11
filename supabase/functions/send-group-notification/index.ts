
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
// http/server.ts import 주소를 안정적인 deno.land 공식 주소로 변경
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

// CORS 헤더 설정
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 요청 본문에서 group_id, title, body 추출
    const { group_id, title, body } = await req.json();
    if (!group_id || !title || !body) {
      throw new Error('group_id, title, and body are required.');
    }
    
    // Supabase 클라이언트 생성
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. 해당 그룹에 속한 모든 사용자의 onesignal_player_id 조회
    const { data: users, error: usersError } = await supabaseClient
      .from('profiles')
      .select('onesignal_player_id')
      .eq('group_id', group_id)
      .not('onesignal_player_id', 'is', null);

    if (usersError) throw usersError;

    const playerIds = users.map(user => user.onesignal_player_id);

    if (playerIds.length === 0) {
      return new Response(JSON.stringify({ message: 'No users with OneSignal Player IDs found in this group.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 2. OneSignal로 푸시 알림 요청 전송
    const ONE_SIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID');
    const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY');

    if (!ONE_SIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
      throw new Error('OneSignal App ID or REST API Key is not set in secrets.');
    }

    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
      },
      body: JSON.stringify({
        app_id: ONE_SIGNAL_APP_ID,
        include_player_ids: playerIds,
        headings: { en: title },
        contents: { en: body },
      }),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(`OneSignal request failed: ${errorBody}`);
    }

    const result = await response.json();

    // 3. 성공 응답 반환
    return new Response(JSON.stringify({ success: true, result }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});

