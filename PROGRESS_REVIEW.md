# A7 Progress Review

## Feature integrations
- **Spotify auth + persistence**: The `HomeViewModel` drives a PKCE sign-in flow via `SignInSpotifyHelper`, exchanges tokens, fetches the Spotify profile, and stores a `SpotifyInfo` record with expiry in Firestore so the Home UI can reflect connection state on launch and refresh tokens when needed.
- **Apple Music scaffolding**: A minimal MusicKit-based helper requests authorization and stores an `AppleMusicInfo` stub, while the token service intentionally throws until an Apple Developer account is available.
- **Home experience**: `HomeView` renders a guide bar whose Spotify/Apple Music buttons adapt to connection state, loads Firestore user data plus mock product rows, and routes to profile, settings, or party playlist screens.
- **Database model refactor**: `DBUser` now nests optional `SpotifyInfo` and `AppleMusicInfo` structs with snake_case Firestore encoding/decoding helpers and update methods for each service.

## Notable behaviors
- Refresh logic checks `expiresAt` on load and only calls Spotify’s token endpoint when necessary, preserving existing refresh tokens when the API omits them.
- The Apple Music path is wired to mark users connected after authorization, but developer-token fetching remains a TODO; MusicKit catalog calls are deferred.
- Guide bar buttons become no-ops when a service is already connected, preventing redundant auth loops.

## Code structure & style cues
- SwiftUI views pair with `ObservableObject` view models for business logic, keeping network/state work out of the UI (e.g., `HomeView`/`HomeViewModel`, `ProfileView`/`ProfileViewModel`).
- Firebase concerns are centralized in manager types: `AuthenticationManager` wraps Auth flows, while `UserManager` owns Firestore CRUD plus `DBUser`/music info encoding.
- Music service utilities live under `WEJAY/Services/Spotify` and `WEJAY/Services/AppleMusic`, separating PKCE login helpers from REST/token clients.
- Navigation relies on `RouterView` into `RootView`, which toggles between `AuthenticationView` and `ProfileView`; UIKit pop gesture tweaks sit in an extension for consistency across screens.
- Tests currently mirror Xcode scaffolding without assertions, leaving room for future coverage.

## Gaps / future polish
- Party/playlist data still comes from the dummy `DBHelper().getProducts()` feed.
- Apple Music integration can’t proceed past authorization without a real developer token backend.
- Share flow, QR join, and role-based DJ/guest routing are stubbed in the UI but not yet implemented.
