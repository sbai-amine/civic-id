/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        civic: {
          50: '#eef4ff',
          100: '#dbe8ff',
          600: '#1f5fd0',
          700: '#174bab',
          900: '#0f2f6f',
        },
      },
      boxShadow: {
        soft: '0 8px 24px rgba(15, 47, 111, 0.08)',
      },
    },
  },
  plugins: [],
}
