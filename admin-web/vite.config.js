import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// `base` defaults to '/' for local dev; GitHub Pages deploys set VITE_BASE.
export default defineConfig({
  base: process.env.VITE_BASE || '/',
  plugins: [react()],
})
