import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const PLANS = {
  bulanan: {
    code: 'BLN',
    price: 5000,
    name: 'Koini Plus Bulanan (Sandbox)',
  },
  tahunan: {
    code: 'THN',
    price: 50000,
    name: 'Koini Plus Tahunan (Sandbox)',
  },
} as const;

type PlanKey = keyof typeof PLANS;

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Metode tidak didukung.' }, 405);
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (!token) {
    return jsonResponse({ error: 'Sesi login tidak ditemukan.' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const midtransServerKey = (Deno.env.get('MIDTRANS_SERVER_KEY') ?? '').trim();

  if (!supabaseUrl || !supabaseAnonKey) {
    return jsonResponse({ error: 'Konfigurasi Supabase belum lengkap.' }, 500);
  }
  if (!midtransServerKey) {
    return jsonResponse(
      {
        error:
          'MIDTRANS_SERVER_KEY belum diatur di Supabase Secrets. Setel Server Key Sandbox dulu.',
      },
      503,
    );
  }
  if (!midtransServerKey.startsWith('SB-Mid-server-')) {
    return jsonResponse(
      {
        error:
          'Kunci Midtrans harus menggunakan Sandbox Server Key (SB-Mid-server-...).',
      },
      400,
    );
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return jsonResponse({ error: 'Sesi login tidak valid.' }, 401);
  }

  let payload: Record<string, unknown>;
  try {
    payload = (await req.json()) as Record<string, unknown>;
  } catch {
    return jsonResponse({ error: 'Format permintaan tidak valid.' }, 400);
  }

  const action = String(payload.action ?? '');
  const uidPrefix = user.id.replace(/-/g, '').slice(0, 8).toUpperCase();
  const basicAuth = `Basic ${btoa(`${midtransServerKey}:`)}`;

  if (action === 'create') {
    const planKey = String(payload.plan ?? '') as PlanKey;
    const plan = PLANS[planKey];
    if (!plan) {
      return jsonResponse({ error: 'Paket Koini Plus tidak valid.' }, 400);
    }

    const orderId = `KOINI-${plan.code}-${uidPrefix}-${Date.now()}`;
    const rawName =
      typeof user.user_metadata?.full_name === 'string' &&
      user.user_metadata.full_name.trim().length > 0
        ? user.user_metadata.full_name.trim()
        : 'Ayah/Bunda';

    const snapResponse = await fetch(
      'https://app.sandbox.midtrans.com/snap/v1/transactions',
      {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          Authorization: basicAuth,
        },
        body: JSON.stringify({
          transaction_details: {
            order_id: orderId,
            gross_amount: plan.price,
          },
          item_details: [
            {
              id: `koini-plus-${planKey}`,
              price: plan.price,
              quantity: 1,
              name: plan.name,
            },
          ],
          customer_details: {
            first_name: rawName.slice(0, 50),
            email: user.email ?? 'orangtua@koini.app',
          },
        }),
      },
    );

    const snapData = (await snapResponse.json().catch(() => ({}))) as Record<
      string,
      unknown
    >;
    if (!snapResponse.ok || typeof snapData.redirect_url !== 'string') {
      const messages = Array.isArray(snapData.error_messages)
        ? snapData.error_messages.join('; ')
        : 'Gagal membuat transaksi Midtrans Sandbox.';
      return jsonResponse({ error: messages }, 502);
    }

    return jsonResponse({
      order_id: orderId,
      plan: planKey,
      gross_amount: plan.price,
      token: snapData.token,
      redirect_url: snapData.redirect_url,
    });
  }

  if (action === 'status') {
    const orderId = String(payload.order_id ?? '').trim();
    const orderPattern = new RegExp(`^KOINI-(BLN|THN)-${uidPrefix}-\\d+$`);
    const match = orderPattern.exec(orderId);
    if (!match) {
      return jsonResponse(
        { error: 'Order ID tidak valid untuk akun ini.' },
        403,
      );
    }

    const planKey: PlanKey = match[1] === 'THN' ? 'tahunan' : 'bulanan';
    const expectedPrice = PLANS[planKey].price;

    const statusResponse = await fetch(
      `https://api.sandbox.midtrans.com/v2/${encodeURIComponent(orderId)}/status`,
      {
        method: 'GET',
        headers: {
          Accept: 'application/json',
          Authorization: basicAuth,
        },
      },
    );

    const statusData = (await statusResponse.json().catch(() => ({}))) as Record<
      string,
      unknown
    >;
    const statusCode = String(statusData.status_code ?? '');
    if (statusResponse.status === 404 || statusCode === '404') {
      return jsonResponse({
        paid: false,
        order_id: orderId,
        plan: planKey,
        transaction_status: 'not_started',
        message:
          'Pembayaran belum dipilih di halaman Midtrans. Selesaikan dulu di browser, lalu cek lagi.',
      });
    }

    const txStatus = String(statusData.transaction_status ?? 'pending');
    const fraudStatus = String(statusData.fraud_status ?? '');
    const grossAmount = Math.round(Number(statusData.gross_amount ?? 0));
    const isSettled =
      txStatus === 'settlement' ||
      (txStatus === 'capture' && fraudStatus !== 'challenge');
    const paid = isSettled && grossAmount === expectedPrice;

    return jsonResponse({
      paid,
      order_id: orderId,
      plan: planKey,
      transaction_status: txStatus,
      payment_type: statusData.payment_type ?? null,
      message: paid
        ? 'Pembayaran Sandbox terkonfirmasi!'
        : `Status transaksi saat ini: ${txStatus}. Selesaikan simulasi bayar lalu tekan Cek status lagi.`,
    });
  }

  return jsonResponse({ error: 'Aksi tidak dikenali.' }, 400);
});
