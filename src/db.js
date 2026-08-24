const { Pool } = require('pg');

// DATABASE_URL is provided by your host (Render/Railway) automatically
// once you attach a Postgres instance. Locally, set it in .env.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};
