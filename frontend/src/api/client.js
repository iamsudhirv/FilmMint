import axios from 'axios'

// Set VITE_API_URL at build time (Vercel/Render env var). Local dev reads frontend/.env.development.
const apiUrl = import.meta.env.VITE_API_URL

export const api = axios.create({
  baseURL: `${apiUrl ?? ''}/api/v1`,
})

// If the API URL is missing or wrong, a single-page-app host answers every path with index.html (HTTP 200).
// Turn that silent failure into a clear error that the pages already know how to display.
api.interceptors.response.use((response) => {
  if (typeof response.data === 'string' && response.data.trimStart().startsWith('<')) {
    throw new Error(
      apiUrl
        ? `The API at ${apiUrl} did not return data. Is the backend running?`
        : 'The API address is not configured (VITE_API_URL is not set for this build).',
    )
  }
  return response
})
