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

## Opening the project in Xcode

Open the checked-in `DocMaker.xcodeproj` when working on the app.

### Regenerating the project with XcodeGen

If the project file ever gets out of sync, you can rebuild it from `project.yml`:

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if it is not already available:

   ```sh
   brew install xcodegen
   ```

2. From the repository root, generate a fresh `.xcodeproj`:

   ```sh
   xcodegen generate
   ```

3. Open the regenerated `DocMaker.xcodeproj` in Xcode.

The generated project already declares the `GoogleSignIn` and `GoogleSignInSwift` Swift package products, so the `import GoogleSignIn` statements resolve without additional manual setup.

### Troubleshooting “No such module 'GoogleSignIn'”

If Xcode still cannot find the module after regenerating the project:

1. Reset Swift Package Manager’s cache: `File ▸ Packages ▸ Reset Package Caches`.
2. Confirm the `GoogleSignIn` package (version 9.0.0 or newer) is added from `https://github.com/google/GoogleSignIn-iOS`.
3. Ensure both **GoogleSignIn** and **GoogleSignInSwift** are listed under **Frameworks, Libraries, and Embedded Content** for the **DocMaker** target.
4. Clean the build folder (`Shift` + `Cmd` + `K`) and rebuild (`Cmd` + `B`).

The XcodeGen configuration already includes both products under `productDependencies`, so once the package cache is refreshed and the generated project is opened, the modules should import correctly.
