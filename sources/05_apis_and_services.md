# APIs and Core Services

The platform relies heavily on seamlessly integrating various Application Programming Interfaces (APIs) and discrete service modules to function. 

## 1. Supabase (Backend as a Service)
Our real-time database, authentication, and simple object storage are entirely handled by Supabase.

* **Database (PostgreSQL via REST/GraphQL API):** 
  * We make direct JSON queries to fetch issues, user profiles, and assignments.
  * Real-time listeners (WebSockets) automatically push new data to the Flutter app when an issue changes status (e.g., going from Pending -> Resolved).
* **Storage API:**
  * Handles the multipart-uploading of Citizen issue photos and Worker proof photos to secure, publicly accessible CDN buckets.
* **Authentication API:**
  * Utilizes JWT (JSON Web Tokens) to verify that a worker cannot manipulate another worker's assigned tasks.

## 2. Google Generative AI (Gemini 2.5 Flash API)
This is the core of our smart-reporting feature, located in `AIService`.

* **Endpoint Used:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`
* **Function:** 
  * The Flutter app converts the uploaded issue photo into a base64 string.
  * It sends a highly specific prompt along with the image to the Gemini API: `"Civic issue photo analysis. Pick ONE category... Assign priority... Reply ONLY with JSON..."`
  * The AI responds with structured JSON that is parsed directly into the app's UI state, automatically populating the form for the user.
* **Why this API?** Minimal latency, high accuracy in visual context understanding, and cost-effective text/image generation.

## 3. Location & Mapping Services
Instead of relying on costly Google Maps API bills, we utilize open-source frameworks for geolocation.

* **OpenStreetMap (Tiles API):**
  * Fetched dynamically using the `flutter_map` package via a standard `{z}/{x}/{y}.png` tile endpoint. 
  * Provides the visual map interface where issues are plotted via Marker widgets.
* **Geolocator Service:**
  * Taps into the native Android/iOS location APIs to grab precise latitude and longitude.
  * Ensures that when a worker clicks "Navigate," they are given accurate point-to-point vectors from their current location to the reported problem.

## 4. Hardware Native Providers
The Flutter engine exposes native device functionality as Dart APIs:

* **Image Picker API:** Direct hooks into the iOS/Android camera modules to capture high-definition JPEG/PNG assets.
* **Touch Event APIs:** Specifically utilized by the `signature` package to track the X/Y coordinates of the user's finger during the E-Signature phase, converting that path into a scalable vector graphic or image buffer.
