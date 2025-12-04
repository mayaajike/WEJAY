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



# WEJAY
I will be creating an iOS mobile app called We-Jay that will help DJs and music fans connect at events. Music is a big part of any gathering, and while everyone wants to hear their favorite songs, DJs often have a hard time keeping the crowd interested, receiving and managing requests.

For example, think about this situation: A group of Italian college graduates has their last dinner in France. The place, food, and service are all great, but the French DJ only plays French music. The Italian guests have a hard time enjoying the night because they can't understand the language and there isn't any music they can relate to. The end result is a celebration that is less meaningful and less memorable.

We-Jay addresses this. With the app, DJs can share a scannable code that connects guests to their playlist and through Apple Music or Spotify streaming accounts, guests can then:

[x] Submit song requests directly to the DJ’s playlist.

[x] Vote on other guests’ recommendations to help prioritize crowd favorites.

[x] Track when their requested songs are played.

[x] Rate the DJ’s performance at the end of the event.

On the DJ side, We-Jay provides organization and valuable insight. The app’s algorithms will rank songs by votes and requests, highlight crowd preferences, and generate a DJ score based on guest feedback and interactions. This ensures DJs can make informed decisions in real time, keeping the energy high and the audience satisfied. Ultimately, We-Jay creates a more interactive, inclusive, and data-driven experience for both DJs and their audiences, transforming how music is shared and enjoyed at events.
