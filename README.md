# News App (Flutter)

Hey! This is a simple news app made with Flutter. You can read the latest news, search for stuff, and save your favorite articles as bookmarks.

## What can you do?
- See top news stories
- Search for news
- Bookmark articles (saved on your phone)
- Login and signup (basic)

## How to run it
1. Make sure you have **Flutter** installed (3.7.0 or above is fine).
2. Get a free API key from [newsapi.org](https://newsapi.org) (just sign up there).
3. Download this project and open it in Android Studio or VS Code.
4. In `lib/config/app_config.dart`, put your API key instead of the default one.
5. Open a terminal and run:
   ```bash
   flutter pub get
   flutter run
   ```

## Folders (what's inside lib/)
- `models/` - Data stuff (like Article, Bookmark)
- `pages/` - The screens you see
- `providers/` - App state (uses Provider)
- `services/` - API calls and helpers
- `config/` - App settings

## Some packages used
- provider
- http
- hive
- cached_network_image
- webview_flutter

## Problems?
- If news doesn't load after installing APK, check your internet and make sure you added the right permissions (see AndroidManifest.xml).
- If bookmarks don't save, try clearing app data or reinstalling.
- If you get API errors, check your API key.

## Building APK
To make a release APK:
```bash
flutter build apk --release
```
