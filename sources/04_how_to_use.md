# How to Use (Step-by-Step Guide)

The Citizen App is designed for simplicity, irrespective of the user's role. Here is a step-by-step walkthrough of the platform's core workflow.

## Step 1: Registration and Authentication
1. Open the **Citizen App**.
2. Tap on "Sign Up" or "Login with Google". 
3. After authentication, the app checks the user's assigned role in the `profiles` table on the database and redirects them to their respective dashboard (Citizen Home, Worker Dashboard, Authority Dashboard, or Admin Dashboard).

## Step 2: Reporting a New Issue (Citizen Workflow)
1. On the Citizen Home screen, tap the prominent **"+" (Add New Report)** button.
2. Allow camera and location permissions (if prompted).
3. **Capture Image:** Take a clear photo of the civic issue (e.g., an overflowing garbage bin).
4. **AI Processing:** Wait a few seconds while Gemini AI analyzes the image. It will automatically populate the "Category" (e.g., Sanitation) and "Priority" (e.g., High) fields.
5. **Location Tagging:** The app will automatically fetch the device's current GPS coordinates and display the location on the map.
6. **Submit:** Review the auto-generated details and tap "Submit Report". The issue instantly appears in the database.

## Step 3: Issue Verification and Dispatch (Authority Workflow)
1. The Authority logs into their dashboard and views the "Pending Issues" list.
2. They select the newly reported issue from Step 2.
3. The Authority reviews the AI's classification, the image, and the location.
4. They tap **"Assign Worker"**, selecting an available municipal worker from the roster who specializes in that category. The issue status changes to "Assigned".

## Step 4: Resolution & Proof of Completion (Worker Workflow)
1. The assigned Worker receives a notification and logs in.
2. They open the issue details and tap **"Navigate"** to get GPS directions to the exact spot.
3. Upon arriving, they fix the issue.
4. The worker taps **"Fix Issue"** in the app.
5. **Upload Proof:** They take a live photo of the resolved scene.
6. **E-Signature:** They physically sign the screen using their finger on the provided canvas.
7. They hit submit. The status updates to "Resolved".

## Step 5: Final Review & Citizen Notification
1. The Authority reviews the Worker's proof photo and signature.
2. Once verified, the issue is closed.
3. The original Citizen sees the issue move to the "Resolved Reports" tab on their screen, completing the accountability loop.

## Administrator (God-Mode)
At any point, the System Administrator can log in to view the global dashboard to monitor total open vs. resolved queries, add new workers to the system, or intervene in escalating complex problems.
