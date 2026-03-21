# Technology Stack & Architecture

Our application is built using a modern, scalable, and highly performant technology stack.

## Frontend (Client Application)
* **Framework: Flutter (Dart)**
  * *Why?* Allows us to deploy natively to Android, iOS, and Web from a single codebase, drastically cutting development time while maintaining 60FPS performance.
* **State Management: Provider**
  * *Why?* Cleanly separates our business logic from UI code, ensuring the app's memory and data stay synchronized across different screens securely.
* **UI/UX Design:** Material 3 Design Guidelines with a robust, dynamically adjusting Dark/Light mode theme.

## Backend as a Service (BaaS)
* **Platform: Supabase** (An open-source Firebase alternative)
* **Database: PostgreSQL**
  * *Why?* Civic data is highly relational (User -> Issue -> Worker). PostgreSQL ensures absolute data integrity and structured queries, which NoSQL alternatives struggle with for this use-case.
* **Authentication: Supabase Auth**
  * *Features:* Handles secure login, JWT session tokens, Google OAuth, and Row-Level Security (RLS) policies to ensure Citizens can't see Admin data.
* **Storage: Supabase Storage Buckets**
  * *Features:* Securely stores and serves high-resolution image uploads for issue reports and worker proofs via CDN.

## Key APIs & Third-Party Libraries
* **Google Generative AI (Gemini 2.5 Flash):** Specifically used for the `AIService` to analyze uploaded photos, extract semantic meaning, and output structured JSON determining the issue Category and Priority.
* **Location & Mapping:** 
  * `flutter_map` & `latlong2`: For rendering interactive OpenStreetMap tiles.
  * `geolocator`: Tapping directly into the OS-level GPS hardware to get precise coordinates.
* **Analytics & Polish:**
  * `fl_chart`: For generating beautiful, animated data visualizations on the Admin Dashboard.
  * `signature`: For capturing and converting raw touch inputs into visual e-signatures.
  * `image_picker`: For safely interfacing with device cameras and photo galleries.

## System Architecture Flow
1. **Client Layer:** Flutter app captures user input, GPS, and images.
2. **Analysis Layer:** Image is streamed to Gemini API; JSON response dictates the UI flow.
3. **Transport Layer:** HTTP/REST calls push structured data to the Supabase endpoint.
4. **Data Layer:** PostgreSQL triggers run, assigning unique UUIDs, storing standard data, and placing images into Secure Storage Buckets.
5. **Real-time Layer:** Supabase WebSockets instantly update the Authority/Worker dashboards without requiring a page refresh.
