// const String backendUrl = 'http://192.168.8.140:5000/api/v1';
// const String backendUrl = 'http://192.168.1.17:5000/api/v1';
// const String backendUrl = 'https://petbackend-production.up.railway.app/api/v1';
const String backendUrl = 'http://10.0.2.2:5000/api/v1';

// ── OpenRouter (LLM for AI Search filter extraction) ──────────────────────
// Get your key at https://openrouter.ai/keys
// Replace the value below with your actual key
const String openRouterApiKey = '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';

// Model used: very cheap, fast, great at JSON extraction
// Cost: ~$0.00003 per query (practically free)
// Alternatives (also cheap): 'mistralai/mistral-7b-instruct', 'meta-llama/llama-3.2-3b-instruct'
const String openRouterModel = 'openai/gpt-4o-mini';