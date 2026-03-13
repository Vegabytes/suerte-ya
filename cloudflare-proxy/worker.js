/**
 * SuerteYa CORS Proxy - Cloudflare Worker
 * Proxies requests to SELAE and ONCE APIs to avoid CORS issues
 */

const ALLOWED_ORIGINS = [
  'https://suerte-ya.pages.dev',
  'https://suerteya.es',
  'http://localhost:8080',
  'http://localhost:3000',
];

const API_ROUTES = {
  '/api/selae/resultado': 'https://www.loteriasyapuestas.es/servicios/ultimoResultado',
  '/api/selae/botes': 'https://www.loteriasyapuestas.es/servicios/botes',
  '/api/selae/comprobar': 'https://www.loteriasyapuestas.es/servicios/premioDecimoWeb',
  '/api/once/resultado': 'https://www.once.es/servicios/resultado-sorteo',
};

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin') || '';

    // Handle preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: corsHeaders(origin),
      });
    }

    // Route the request
    const path = url.pathname;

    // SELAE ultimo resultado
    if (path.startsWith('/api/selae/resultado')) {
      const juego = url.searchParams.get('juego');
      const targetUrl = `https://www.loteriasyapuestas.es/servicios/ultimoResultado?juego=${juego}`;
      return proxyRequest(targetUrl, origin);
    }

    // SELAE botes
    if (path === '/api/selae/botes') {
      return proxyRequest('https://www.loteriasyapuestas.es/servicios/botes', origin);
    }

    // SELAE comprobar décimo
    if (path.startsWith('/api/selae/comprobar')) {
      const codigo = url.searchParams.get('codigo');
      return proxyRequest(
        `https://www.loteriasyapuestas.es/servicios/premioDecimoWeb?codigo=${codigo}`,
        origin
      );
    }

    // ONCE resultado
    if (path.startsWith('/api/once/resultado')) {
      // /api/once/resultado/cupon/ultimo
      const subpath = path.replace('/api/once/resultado', '');
      return proxyRequest(
        `https://www.once.es/servicios/resultado-sorteo${subpath}`,
        origin
      );
    }

    return new Response(JSON.stringify({ error: 'Not found', routes: Object.keys(API_ROUTES) }), {
      status: 404,
      headers: { 'Content-Type': 'application/json', ...corsHeaders(origin) },
    });
  },
};

async function proxyRequest(targetUrl, origin) {
  try {
    const response = await fetch(targetUrl, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'SuerteYa/1.0',
      },
    });

    const body = await response.text();

    return new Response(body, {
      status: response.status,
      headers: {
        'Content-Type': response.headers.get('Content-Type') || 'application/json',
        'Cache-Control': 'public, max-age=300', // Cache 5 min
        ...corsHeaders(origin),
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 502,
      headers: { 'Content-Type': 'application/json', ...corsHeaders(origin) },
    });
  }
}

function corsHeaders(origin) {
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept',
    'Access-Control-Max-Age': '86400',
  };
}
