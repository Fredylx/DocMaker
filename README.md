# DocMaker

## Authentication overview

DocMaker now includes a lightweight `AuthService` that lets users sign up, log in, and sign out locally. Credentials are stored securely in `UserDefaults` for demo purposes and the UI provides validation, loading states, and error feedback during authentication flows.

## Suggested production login API

For a production-ready login backend, consider managed identity providers such as [Supabase](https://supabase.com) or [Auth0](https://auth0.com). Both expose straightforward REST endpoints. For example, Supabase’s password login accepts a request shaped like:

```http
POST https://<project-ref>.supabase.co/auth/v1/token?grant_type=password
Content-Type: application/json
apikey: <public-anon-key>

{
  "email": "user@example.com",
  "password": "yourStrongPassword"
}
```

Successful responses include an access token (`access_token`) and refresh token (`refresh_token`) that you can store securely (for example in the keychain) and attach to subsequent API calls.
