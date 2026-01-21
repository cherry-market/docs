# API Configuration Guide

## Environment Variables

### Frontend (cherry-client)

#### Local Development (.env.local)

```env
VITE_API_BASE_URL=http://localhost:8080
```

#### Production (.env.production)

```env
VITE_API_BASE_URL=https://api.cherriy.com
```

### Backend (cherry-server)

#### Production Environment Variables

```env
CORS_ALLOWED_ORIGINS=https://cherriy.com,https://www.cherriy.com
```

## Architecture

| Environment | Frontend Domain       | Backend Domain          |
| ----------- | --------------------- | ----------------------- |
| Local       | http://localhost:3000 | http://localhost:8080   |
| Production  | https://cherriy.com   | https://api.cherriy.com |

## Deployment Checklist

### Frontend Deployment (CloudFront + S3)

1. Set environment variable:

   ```bash
   VITE_API_BASE_URL=https://api.cherriy.com npm run build
   ```

2. Upload `dist/` to S3 bucket

3. Invalidate CloudFront cache

### Backend Deployment (EC2)

1. Set environment variable on EC2:

   ```bash
   export CORS_ALLOWED_ORIGINS=https://cherriy.com,https://www.cherriy.com
   ```

2. Restart application

## Local Development

```bash
# Terminal 1: Start backend
cd cherry-server
./gradlew bootRun

# Terminal 2: Start frontend
cd cherry-client
npm run dev
```

Frontend will call `http://localhost:8080` directly (no proxy needed).

## Migration Summary

**Removed:**

- Vite proxy configuration (`/api` prefix)
- Hardcoded `http://localhost:8080` in authApi.ts
- Direct fetch calls in authApi.ts (now uses shared api.ts)

**Added:**

- Environment variable based API URL configuration
- Single API client entry point (api.ts)
- Production CORS configuration for cherriy.com

**Benefits:**

- Same code works in local and production
- No conditional logic based on environment
- Single source of truth for API calls
