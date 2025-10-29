export async function GET() {
  const ts = new Date().toISOString();
  return new Response(JSON.stringify({ ok: true, ts }), {
    headers: { "Content-Type": "application/json" },
  });
}
