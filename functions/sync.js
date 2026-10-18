export async function onRequestPost(context) {
  try {
    const { category, streak } = await context.request.json();
    
    // Upsert into Cloudflare D1 SQL database
    await context.env.DB.prepare(`
      INSERT INTO habit_sync (category, streak, updated_at) 
      VALUES (?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(category) DO UPDATE SET 
        streak = excluded.streak,
        updated_at = CURRENT_TIMESTAMP
    `).bind(category, streak).run();

    return new Response(JSON.stringify({ status: "success" }), {
      headers: { "Content-Type": "application/json" }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
}
