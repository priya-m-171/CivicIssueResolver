# Features By Role

The Citizen App operates on a strict Role-Based Access Control (RBAC) system, providing a tailored experience for four distinct user types.

## 1. Citizen (The End User)
* **Secure Authentication:** Easy login/registration via Email or Google Sign-In.
* **AI-Assisted Reporting:** Citizens take a live photo of a civic issue. Gemini AI automatically analyzes the image to suggest a Category (e.g., Road, Electrical, Sanitation) and Priority.
* **Precision Geolocation:** Captures the exact latitude and longitude of the device to pinpoint the issue on a map.
* **Real-time Tracking:** Citizens can view a dynamic dashboard showing their active and past reports, with live status updates (Pending, Assigned, Resolved).
* **Multi-Language Support:** The UI can dynamically switch between English and localized languages (e.g., Tamil) for inclusive accessibility.

## 2. Municipal Worker (Field Agent)
* **Task Assignment Dashboard:** Workers receive automated alerts for new issues assigned to them in their vicinity.
* **Map Navigation:** Integrated routing to show exactly where the issue is located on an interactive map.
* **Proof of Completion (PoC):** Upon fixing the issue, workers must use the built-in camera to capture a live "After" photo.
* **Digital E-Signature:** Workers physically sign the screen of their device to cryptographically certify the job is complete, updating the database in real-time.

## 3. Authority (Mid-Level Manager)
* **Regional Oversight:** Views all pending and incoming issues for their assigned district/ward.
* **Dispatch Management:** Manages the roster of available municipal workers and manually assigns complex tickets to specific specialized workers.
* **Verification:** Reviews the "Proof of Completion" submitted by workers before officially marking an issue as closed and notifying the citizen.

## 4. Administrator (System Owner)
* **Global Dashboard:** Has an overarching 'God-Mode' view of the entire municipal system.
* **Live Analytics:** Views dynamic charts and graphs (using `fl_chart`) showing issue resolution rates, active worker metrics, and geographical hotspots of civic problems.
* **User Management:** Can approve, suspend, or change the roles of users (e.g., promoting a user to a Worker or Authority role).
* **Data Export:** Can export system metrics and resolved issues to CSV formats for external government auditing.
