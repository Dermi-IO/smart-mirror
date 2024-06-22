module.exports = {
  apps: [
    {
      name: 'nextjs-api',
      script: 'dist/src/index.js', // Entry point script
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
};