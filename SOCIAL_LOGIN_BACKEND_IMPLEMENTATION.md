# Social Login Backend Implementation Guide

This guide provides step-by-step instructions to implement social login (Google, Apple, Facebook) in your Express.js backend with PostgreSQL database.

## Overview

The Flutter mobile app has been updated to support social login and will send requests to a new endpoint: `POST /auth/social-login`

### Request Format
```json
{
  "provider": "google|apple|facebook",
  "access_token": "provider_access_token",
  "user_info": {
    "id": "provider_user_id",
    "email": "user@example.com",
    "name": "User Full Name",
    "picture": "https://avatar-url.com/image.jpg"
  }
}
```

### Response Format
```json
{
  "success": true,
  "message": "Social login successful",
  "data": {
    "token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "user": {
      "id": "user_id",
      "full_name": "User Name",
      "email": "user@email.com",
      "phone": null,
      "preferred_language": "en",
      "is_verified": true,
      "is_active": true,
      "business_ids": ["business_id_1"],
      "provider": "google",
      "social_id": "google_user_id",
      "avatar_url": "https://avatar-url.com",
      "isVerified": true
    }
  }
}
```

## Step 1: Database Schema Updates

Execute these SQL commands on your PostgreSQL database:

```sql
-- Add social login columns to users table
ALTER TABLE users ADD COLUMN provider VARCHAR(20) DEFAULT 'email';
ALTER TABLE users ADD COLUMN social_id VARCHAR(255);
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);

-- Create indexes for performance
CREATE INDEX idx_users_social ON users(provider, social_id);
CREATE INDEX idx_users_email ON users(email);

-- Update existing users to have 'email' as default provider
UPDATE users SET provider = 'email' WHERE provider IS NULL;
```

## Step 2: Install Required Dependencies

```bash
npm install axios googleapis facebook-sdk-for-javascript express-rate-limit
# or
yarn add axios googleapis facebook-sdk-for-javascript express-rate-limit
```

## Step 3: Environment Variables

Add these to your `.env` file:

```env
# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Facebook App
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# Apple (if using server-side verification)
APPLE_CLIENT_ID=your_apple_service_id
APPLE_TEAM_ID=your_apple_team_id
APPLE_KEY_ID=your_apple_key_id

# JWT Settings (if not already set)
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your_jwt_refresh_secret
JWT_REFRESH_EXPIRES_IN=7d
```

## Step 4: Create Social Login Route

Create a new file `routes/auth/social-login.js`:

```javascript
const express = require('express');
const axios = require('axios');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg'); // Adjust based on your DB setup

const router = express.Router();

// Rate limiting for social login
const socialLoginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // limit each IP to 10 requests per windowMs
  message: {
    success: false,
    message: 'Too many social login attempts, please try again later.'
  }
});

// Token verification functions
const verifyGoogleToken = async (accessToken) => {
  try {
    const response = await axios.get(`https://www.googleapis.com/oauth2/v2/userinfo?access_token=${accessToken}`);
    return response.data;
  } catch (error) {
    throw new Error('Invalid Google token');
  }
};

const verifyFacebookToken = async (accessToken) => {
  try {
    const response = await axios.get(`https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${accessToken}`);
    return response.data;
  } catch (error) {
    throw new Error('Invalid Facebook token');
  }
};

const verifyAppleToken = async (identityToken) => {
  try {
    // Apple token verification requires more complex JWT verification
    // For now, we'll decode the token (implement proper verification in production)
    const decoded = jwt.decode(identityToken);
    if (!decoded) {
      throw new Error('Invalid Apple token');
    }
    return {
      id: decoded.sub,
      email: decoded.email,
      name: 'Apple User' // Apple doesn't always provide name in token
    };
  } catch (error) {
    throw new Error('Invalid Apple token');
  }
};

// Main social login endpoint
router.post('/social-login', socialLoginLimiter, async (req, res) => {
  try {
    const { provider, access_token, user_info } = req.body;
    
    // Validation
    if (!provider || !access_token || !user_info) {
      return res.status(400).json({
        success: false,
        message: 'Provider, access token, and user info are required'
      });
    }

    if (!['google', 'apple', 'facebook'].includes(provider)) {
      return res.status(400).json({
        success: false,
        message: 'Unsupported provider'
      });
    }

    // Log attempt
    console.log(`Social login attempt: ${provider} - ${user_info.email} - ${new Date().toISOString()}`);

    let verifiedUser;

    // Verify token with respective provider
    switch (provider) {
      case 'google':
        verifiedUser = await verifyGoogleToken(access_token);
        break;
      case 'facebook':
        verifiedUser = await verifyFacebookToken(access_token);
        break;
      case 'apple':
        verifiedUser = await verifyAppleToken(access_token);
        break;
    }

    // Ensure verified user matches provided user_info
    if (verifiedUser.id !== user_info.id || verifiedUser.email !== user_info.email) {
      return res.status(400).json({
        success: false,
        message: 'Token verification failed'
      });
    }

    // Database operations
    // Replace 'pool' with your database connection instance
    const pool = require('../../config/database'); // Adjust path as needed

    // Check if user exists by social_id or email
    const existingUserQuery = `
      SELECT * FROM users 
      WHERE (provider = $1 AND social_id = $2) OR email = $3
    `;
    
    const existingUser = await pool.query(existingUserQuery, [
      provider,
      user_info.id,
      user_info.email
    ]);

    let user;

    if (existingUser.rows.length > 0) {
      // User exists - update if needed
      user = existingUser.rows[0];
      
      // Update social info if not set or if switching from email to social
      if (!user.social_id || user.provider === 'email') {
        const updateQuery = `
          UPDATE users 
          SET provider = $1, social_id = $2, avatar_url = $3, updated_at = NOW()
          WHERE id = $4
          RETURNING *
        `;
        
        const updated = await pool.query(updateQuery, [
          provider,
          user_info.id,
          user_info.picture || user_info.avatar_url,
          user.id
        ]);
        
        user = updated.rows[0];
      }
    } else {
      // Create new user
      const createUserQuery = `
        INSERT INTO users (
          full_name, email, provider, social_id, avatar_url, 
          is_verified, is_active, preferred_language, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
        RETURNING *
      `;
      
      const newUser = await pool.query(createUserQuery, [
        user_info.name || 'Social User',
        user_info.email,
        provider,
        user_info.id,
        user_info.picture || user_info.avatar_url,
        true, // Social login users are considered verified
        true,
        'en' // default language
      ]);
      
      user = newUser.rows[0];
      
      console.log(`New social user created: ${user.email} via ${provider}`);
    }

    // Generate JWT tokens
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
    );

    // Get business IDs (adjust query based on your business relationship table)
    const businessQuery = `
      SELECT business_id FROM user_businesses WHERE user_id = $1
    `;
    const businesses = await pool.query(businessQuery, [user.id]);
    const businessIds = businesses.rows.map(b => b.business_id);

    // Log successful login
    console.log(`Social login successful: ${user.email} via ${provider}`);

    // Format response to match your existing auth structure
    const responseData = {
      success: true,
      message: 'Social login successful',
      data: {
        token,
        refresh_token: refreshToken,
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          phone: user.phone,
          preferred_language: user.preferred_language,
          is_verified: user.is_verified,
          is_active: user.is_active,
          business_ids: businessIds,
          provider: user.provider,
          social_id: user.social_id,
          avatar_url: user.avatar_url,
          isVerified: user.is_verified // for compatibility with mobile app
        }
      }
    };

    res.status(200).json(responseData);

  } catch (error) {
    console.error('Social login error:', error);
    res.status(500).json({
      success: false,
      message: 'Social login failed',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
```

## Step 5: Update Main Auth Routes

In your main auth routes file (e.g., `routes/auth/index.js` or `routes/auth.js`):

```javascript
const express = require('express');
const socialLoginRouter = require('./social-login'); // Adjust path as needed

const router = express.Router();

// Your existing auth routes...
// router.post('/login', ...);
// router.post('/register', ...);

// Add the social login route
router.use('/', socialLoginRouter);

module.exports = router;
```

## Step 6: Update User Profile Response

Ensure your existing `/auth/profile` endpoint returns the new social login fields:

```javascript
// In your profile endpoint
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await getUserById(req.user.userId);
    
    res.json({
      success: true,
      data: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        preferred_language: user.preferred_language,
        is_verified: user.is_verified,
        is_active: user.is_active,
        business_ids: user.business_ids,
        provider: user.provider,        // New field
        social_id: user.social_id,      // New field
        avatar_url: user.avatar_url,    // New field
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user profile'
    });
  }
});
```

## Step 7: Testing Your Implementation

### Test with cURL

```bash
# Test Google login
curl -X POST http://localhost:3000/auth/social-login \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "google",
    "access_token": "google_access_token_here",
    "user_info": {
      "id": "google_user_id_123",
      "email": "testuser@gmail.com",
      "name": "Test User",
      "picture": "https://lh3.googleusercontent.com/a/default-user"
    }
  }'

# Test Facebook login
curl -X POST http://localhost:3000/auth/social-login \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "facebook",
    "access_token": "facebook_access_token_here",
    "user_info": {
      "id": "facebook_user_id_123",
      "email": "testuser@facebook.com",
      "name": "Test User",
      "picture": "https://graph.facebook.com/123/picture"
    }
  }'
```

### Expected Response

```json
{
  "success": true,
  "message": "Social login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid-here",
      "full_name": "Test User",
      "email": "testuser@gmail.com",
      "phone": null,
      "preferred_language": "en",
      "is_verified": true,
      "is_active": true,
      "business_ids": [],
      "provider": "google",
      "social_id": "google_user_id_123",
      "avatar_url": "https://lh3.googleusercontent.com/a/default-user",
      "isVerified": true
    }
  }
}
```

## Step 8: Provider Configuration (External Setup Required)

### Google OAuth Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your domain to authorized origins
6. Note down Client ID and Client Secret

### Facebook App Setup
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product
4. Configure OAuth redirect URIs
5. Note down App ID and App Secret

### Apple Sign In Setup
1. Go to [Apple Developer Console](https://developer.apple.com/)
2. Create a new Service ID
3. Configure Sign in with Apple
4. Set up domain verification
5. Note down Service ID, Team ID, and Key ID

## Step 9: Security Considerations

### Additional Security Measures

```javascript
// Add to your social login route
const crypto = require('crypto');

// Generate a secure state parameter for CSRF protection
const generateState = () => {
  return crypto.randomBytes(32).toString('hex');
};

// Validate request origin (add middleware)
const validateOrigin = (req, res, next) => {
  const allowedOrigins = [
    'http://localhost:3000',
    'https://yourdomain.com'
  ];
  
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: 'Unauthorized origin'
    });
  }
};

// Apply to social login route
router.post('/social-login', validateOrigin, socialLoginLimiter, async (req, res) => {
  // ... existing code
});
```

## Step 10: Logging and Monitoring

### Enhanced Logging

```javascript
const winston = require('winston'); // npm install winston

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'social-login.log' }),
    new winston.transports.Console()
  ]
});

// Use in your social login route
logger.info('Social login attempt', {
  provider,
  email: user_info.email,
  ip: req.ip,
  userAgent: req.get('User-Agent'),
  timestamp: new Date().toISOString()
});
```

## Troubleshooting

### Common Issues

1. **Token Verification Fails**
   - Check if tokens are properly passed from frontend
   - Verify provider API endpoints are accessible
   - Check rate limits on provider APIs

2. **Database Errors**
   - Ensure all new columns exist in users table
   - Check if your database connection pool is properly configured
   - Verify SQL queries match your exact table schema

3. **JWT Token Issues**
   - Ensure JWT_SECRET environment variables are set
   - Check token expiration times
   - Verify token signing algorithm matches

4. **CORS Issues**
   - Add proper CORS configuration for mobile app requests
   - Ensure preflight OPTIONS requests are handled

### Testing Checklist

- [ ] Database schema updated successfully
- [ ] Environment variables configured
- [ ] Social login endpoint responds correctly
- [ ] Token verification works for each provider
- [ ] New users are created properly
- [ ] Existing users are updated correctly
- [ ] JWT tokens are generated and valid
- [ ] Business IDs are fetched correctly
- [ ] Error handling works as expected
- [ ] Rate limiting is functional
- [ ] Logging is working

## Production Deployment Notes

1. **Apple Token Verification**: Implement proper Apple JWT token verification using Apple's public keys
2. **Rate Limiting**: Adjust rate limits based on your app's usage patterns
3. **Monitoring**: Set up alerts for failed social login attempts
4. **Backup**: Ensure user data backup includes new social login fields
5. **Privacy**: Review data retention policies for social login data

## Support

If you encounter issues during implementation, check:

1. Server logs for detailed error messages
2. Database query execution results
3. Provider API documentation for any changes
4. Network connectivity to provider APIs

The mobile app is ready and waiting for these backend endpoints to be implemented. Once complete, users will be able to sign in using Google, Apple, or Facebook from the login screen.