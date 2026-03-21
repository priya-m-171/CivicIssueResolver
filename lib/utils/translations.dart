import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

class AppTranslations {
  static const Map<String, String> ta = {
    // English -> Tamil Dictionary
    'Submit New Issue': 'புதிய புகாரை சமர்ப்பிக்கவும்',
    'Description': 'விளக்கம்',
    'Photos': 'புகைப்படங்கள்',
    'Location': 'இடம்',
    'Contact': 'தொடர்பு',
    'Review': 'மதிப்பாய்வு',
    'Title (Required)': 'தலைப்பு (கட்டாயம்)',
    'Short, clear title': 'சுருக்கமான, தெளிவான தலைப்பு',
    'Description (Required)': 'விளக்கம் (கட்டாயம்)',
    'Provide as much detail as possible':
        'முடிந்தவரை விரிவான விவரங்களை வழங்கவும்',
    'Category': 'வகை',
    'Priority Level': 'முன்னுரிமை நிலை',
    'Low': 'குறைந்த',
    'Medium': 'நடுத்தர',
    'High': 'உயர்ந்த',
    'Severe': 'கடும்',
    'Back': 'பின் செல்',
    'Next Step': 'அடுத்த படி',
    'Tap to add photos': 'புகைப்படங்களைச் சேர்க்கத் தட்டவும்',
    'Supported: JPG, PNG (Max 5 photos)': 'பொருத்தமான கோப்புகள்: JPG, PNG',
    'Photo Tips': 'புகைப்பட வழிகாட்டல்',
    'Pin Issue Location': 'புகாரின் இடத்தைக் குறிக்கவும்',
    'Your Details': 'உங்கள் விவரங்கள்',
    'Full Name': 'முழு பெயர்',
    'Phone Number': 'தொலைபேசி எண்',
    'Submit Issue': 'புகாரைச் சமர்ப்பிக்கவும்',
    'Overview': 'கண்ணோட்டம்',
    'My Issues': 'என் புகார்கள்',
    'Map': 'வரைபடம்',
    'Alerts': 'அறிவிப்பு',
    'Profile': 'சுயவிவரம்',
    'Report Issue': 'புகார் செய்',
    'Settings': 'அமைப்புகள்',
    'Language': 'மொழி',
    'Theme': 'தோற்றம்',
    'Sign Out': 'வெளியேறு',
    'Success': 'வெற்றி',
    'Issue submitted successfully!': 'புகார் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!',
    'Return to Home': 'முகப்புக்கு திரும்பு',
    'Select Category': 'வகையைத் தேர்ந்தெடுக்கவும்',
    'Select Priority': 'முன்னுரிமையை தேர்ந்தெடுக்கவும்',
    'Total Issues': 'மொத்த புகார்கள்',
    'Resolution Rate': 'தீர்வு விகிதம்',
    'Active Tasks': 'செயலில் உள்ள பணிகள்',
    'Resolved Tasks': 'தீர்க்கப்பட்ட பணிகள்',
    'System Settings': 'கணினி அமைப்புகள்',
    'Data Management': 'தரவு மேலாண்மை',
    'Export Report': 'அறிக்கையை ஏற்றுமதி செய்',

    // Issue Reporting specific strings
    'Describe Your Issue': 'உங்கள் புகாரை விவரிக்கவும்',
    'Be as specific as possible to help us resolve it quickly':
        'இதை விரைவாகத் தீர்க்க முடியுமானவரை குறிப்பிட்ட விவரங்களை வழங்கவும்',
    'Issue Title *': 'புகாரின் தலைப்பு *',
    'e.g., Large pothole on Main Street':
        'உதாரணமாக, மெயின் வீதியில் பெரிய பள்ளம்',
    'Issue Category *': 'புகார் வகை *',
    // Fallback Categories
    'Roads & Traffic': 'சாலை மற்றும் போக்குவரத்து',
    'Sanitation & Garbage': 'சுகாதாரம் மற்றும் குப்பை',
    'Water & Pipes': 'நீர் மற்றும் குழாய்கள்',
    'Electricity & Safety': 'மின்சாரம் மற்றும் பாதுகாப்பு',
    'Other': 'மற்றவை',

    // New 40 Categories
    'Open Manhole / Uncovered Drain': 'திறந்த மேன்ஹோல் / மூடப்படாத வடிகால்',
    'Large Pothole / Crater': 'பெரிய பள்ளம் / குழி',
    'Waterlogged Road / Flooded Street':
        'தண்ணீர் தேங்கிய சாலை / வெள்ளம் சூழ்ந்த தெரு',
    'Caved-in Road / Sinkhole': 'உள்ளிறங்கிய சாலை / பள்ளம்',
    'Broken Pavement / Missing Footpath':
        'உடைந்த நடைபாதை / காணாமல் போன நடைபாதை',
    'Fallen Tree / Large Debris Blocking Road':
        'விழுந்த மரம் / சாலையை அடைக்கும் பெரிய குப்பைகள்',
    'Damaged / Missing speed breaker': 'சேதமடைந்த / காணாமல் போன வேகத்தடை',
    'Uprooted or Damaged Traffic Signal/Signboard':
        'வேரோடு சாய்ந்த அல்லது சேதமடைந்த போக்குவரத்து சிக்னல் / அறிவிப்புப் பலகை',
    'Illegal Road Cutting / Unfilled Trench':
        'சட்டவிரோத சாலை வெட்டு / நிரப்பப்படாத அகழி',
    'Construction Material Dumped on Road':
        'சாலையில் கொட்டப்படும் கட்டுமானப் பொருட்கள்',
    'Large Garbage Dump / Overflowing Dhalao (Bin)':
        'பெரிய குப்பை மேடு / நிரம்பி வழியும் குப்பைத் தொட்டி',
    'Dead Animal on Street (Dog, Cattle, etc.)':
        'தெருவில் இறந்த விலங்கு (நாய், மாடு போன்றவை)',
    'Burning of Garbage / Plastic/ Leaves':
        'குப்பை / பிளாஸ்டிக் / இலைகளை எரித்தல்',
    'Choked Nala / Overflowing Storm Water Drain':
        'அடைபட்ட கால்வாய் / நிரம்பி வழியும் மழைநீர் வடிகால்',
    'Public Defecation / Urination Hotspot':
        'பொது இடங்களில் மலம் / சிறுநீர் கழிக்கும் பகுதி',
    'Medical / Bio-hazardous Waste Dumped Openly':
        'திறந்த வெளியில் கொட்டப்டும் மருத்துவ / உயிரபாய குப்பைகள்',
    'Construction Debris (Malba) Dumped Illegally':
        'சட்டவிரோதமாகக் கொட்டப்படும் கட்டுமானக் கழிவுகள் (மால்பா)',
    'Uncleaned Public Toilet (Sulabh)':
        'சுத்தம் செய்யப்படாத பொது கழிப்பறை (சுலப்)',
    'Major Drinking Water Pipeline Burst / Leakage':
        'முக்கிய குடிநீர் குழாய் வெடிப்பு / கசிவு',
    'Sewage Line Overflow / Manhole Gushing Water':
        'கழிவுநீர் குழாய் நிரம்பி வழிதல் / மேன்ஹோலில் இருந்து நீர் பீறிடுதல்',
    'Contaminated / Muddy / Foul Smelling Tap Water':
        'மாசுபட்ட / சேற்று / துர்நாற்றம் வீசும் குழாய் நீர்',
    'Stagnant Water Pool (Mosquito Breeding)':
        'தேங்கிய நீர்க்குட்டை (கொசு உற்பத்தி)',
    'Illegal Water Connection / Pumping':
        'சட்டவிரோத குடிநீர் இணைப்பு / பம்பிங்',
    'No Water Supply in Area': 'பகுதியில் நீர் வழங்கல் இல்லை',
    'Live / Dangling Electric Wires on Street':
        'தெருவில் உயிருள்ள / தொங்கும் மின் கம்பிகள்',
    'Sparking / Smoking Transformer or Pole':
        'தீப்பொறி / புகை வரும் டிரான்ஸ்பார்மர் அல்லது மின்கம்பம்',
    'Fallen Electricity Pole': 'விழுந்த மின்கம்பம்',
    'Broken / Non-functional Streetlight(s)':
        'உடைந்த / வேலை செய்யாத தெருவிளக்கு(கள்)',
    'Open Junction Box / Exposed Wiring at Ground Level':
        'திறந்த வளைவுப் பெட்டி / தரைமட்டத்திலுள்ள திறந்த வயர்கள்',
    'Streetlights Kept ON During Daytime':
        'பகலில் எரிய விடப்படும் தெருவிளக்குகள்',
    'Illegal Encroachment (Shops/Vendors Blocking Footpath)':
        'சட்டவிரோத ஆக்கிரமிப்பு (கடை / வியாபாரிகளால் நடைபாதை அடைப்பு)',
    'Abandoned / Scrap Vehicle Parked on Road':
        'சாலையில் நிறுத்தப்பட்டுள்ள கைவிடப்பட்ட / பழைய வாகனம்',
    'Illegal Hoardings / Banners Blocking View/Signals':
        'பார்வை / சிக்னல்களை மறைக்கும் சட்டவிரோத விளம்பரப் பலகைகள் / பதாகைகள்',
    'Stray Dog Menace / Aggressive Pack':
        'தெரு நாய் தொல்லை / ஆக்ரோஷமான நாய்கள்',
    'Stray Cattle / Monkeys Causing Nuisance':
        'தெரு மாடுகள் / குரங்குகளால் ஏற்படும் தொல்லை',
    'Unfenced Construction Site / Open Lift Shaft':
        'வேலி இல்லாத கட்டுமான தளம் / திறந்த லிப்ட் தண்டு',
    'Illegal Cutting / Pruning of Trees': 'சட்டவிரோதமாக மரம் வெட்டுதல் ',
    'Poor Maintenance of Public Park (Broken Swings/Benches)':
        'பொதுப் பூங்காவின் மோசமான பராமரிப்பு (உடைந்த ஊஞ்சல்கள் / பெஞ்சுகள்)',
    'Industrial Effluent Discharge into Drain/River':
        'வடிகால் / ஆற்றில் வெளியேற்றப்படும் தொழிற்சாலைக் கழிவுநீர்',
    'Loudspeaker / Noise Pollution Violation':
        'ஒலிபெருக்கி / இரைச்சல் மாசுக் கட்டுப்பாடு விதிமீறல்',
    'Detailed Description *': 'விரிவான விளக்கம் *',
    'Describe the issue in detail. Include when you first noticed it, how it affects you...':
        'புகாரை விரிவாக விவரிக்கவும். இதை முதல் முறையாக எப்போது கவனித்தீர்கள், அது எவ்வாறு பாதிக்கிறது என்பதைச் சேர்க்கவும்...',
    'Priority Level *': 'முன்னுரிமை நிலை *',
    'Cancel': 'ரத்து செய்',
    'Submit Report': 'புகாரைச் சமர்ப்பிக்கவும்',

    // Step 2 & 3
    'Photos help us understand and resolve your issue faster (max 5)':
        'புகைப்படங்கள் உங்கள் புகாரை விரைவாகப் புரிந்துகொள்ளவும் தீர்க்கவும் உதவும் (அதிகபட்சம் 5)',
    '• Take clear, well-lit photos from multiple angles\n• Include context (street signs, landmarks)\n• Show the full extent of the problem\n• Avoid blurry or dark images':
        '• பல கோணங்களில் இருந்து தெளிவான, நன்கு வெளிச்சம் உள்ள புகைப்படங்களை எடுக்கவும்\n• சூழலைச் சேர்க்கவும் (தெரு அடையாளங்கள், அடையாளங்கள்)\n• பிரச்சினையின் முழு வீச்சை காட்டுங்கள்\n• மங்கலான அல்லது இருண்ட படங்களை தவிர்க்கவும்',

    'Live location auto-detected. Tap map to adjust if needed.':
        'நேரலை இருப்பிடம் தானாக கண்டறியப்பட்டது. தேவைப்பட்டால் சரிசெய்ய வரைபடத்தைத் தட்டவும்.',
    'Detecting your location...': 'உங்கள் இருப்பிடத்தை கண்டறிகிறது...',

    // Step 4 & 5
    'Contact Information': 'தொடர்பு தகவல்',
    'So we can update you about the status of your complaint':
        'எனவே உங்கள் புகாரின் நிலை குறித்த புதுப்பிப்புகளை வழங்கலாம்',
    'Full Name *': 'முழு பெயர் *',
    'Your full name': 'உங்கள் முழு பெயர்',
    'Your phone number': 'உங்கள் தொலைபேசி எண்',
    'Your contact information is kept private and only used for status updates.':
        'உங்கள் தொடர்புத் தகவல் தனிப்பட்டதாக வைக்கப்பட்டு, நிலை புதுப்பிப்புகளுக்கு மட்டுமே பயன்படுத்தப்படும்.',

    'Review & Submit': 'சமர்ப்பிக்க மதிப்பாய்வு செய்யவும்',
    'Please review your complaint before submitting':
        'சமர்ப்பிக்கும் முன் உங்கள் புகாரை மதிப்பாய்வு செய்யவும்',
    'Issue Details': 'புகார் விவரங்கள்',
    'Evidence': 'சான்று',
    'photo(s) attached': 'புகைப்பட(ங்கள்) இணைக்கப்பட்டுள்ளன',
    'Address': 'முகவரி',
    'Name': 'பெயர்',
    'Once submitted, a unique ticket ID will be generated and you will receive status updates.':
        'சமர்ப்பித்தவுடன், தனிப்பட்ட டிக்கெட் ஐடி உருவாக்கப்படும், மேலும் நீங்கள் நிலை புதுப்பிப்புகளைப் பெறுவீர்கள்.',

    'Not provided': 'வழங்கப்படவில்லை',
    'Complaint Submitted!': 'புகார் சமர்ப்பிக்கப்பட்டது!',
    'Your complaint has been successfully submitted. You will receive updates on its status.':
        'உங்கள் புகார் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டுள்ளது. அதன் நிலை குறித்த புதுப்பிப்புகளை நீங்கள் பெறுவீர்கள்.',
    'Your Ticket Number': 'உங்கள் டிக்கெட் எண்',

    // Newly Added Dashboard & Notification Strings
    'Good Morning': 'காலை வணக்கம்',
    'Good Afternoon': 'மதிய வணக்கம்',
    'Good Evening': 'மாலை வணக்கம்',
    'Citizen': 'குடிமகன்',
    'Track & report civic issues in your area':
        'உங்கள் பகுதியில் உள்ள குடிமை பிரச்சனைகளை கண்காணிக்கவும் மற்றும் புகார் செய்யவும்',
    'Pending': 'நிலுவையில் உள்ளது',
    'Resolved': 'தீர்க்கப்பட்டது',
    'City Overview': 'நகரத்தின் கண்ணோட்டம்',
    'Total': 'மொத்தம்',
    'In Progress': 'செயலாக்கத்தில் உள்ளது',
    'Rate': 'விகிதம்',
    'Monthly Trend (issues submitted)':
        'மாதாந்திர போக்கு (சமர்ப்பிக்கப்பட்ட புகார்கள்)',
    'Issues by Category': 'வகை வாரியாக புகார்கள்',
    'My Recent Reports': 'எனது சமீபத்திய புகார்கள்',
    'View All': 'அனைத்தையும் காண்க',
    'Search your reports...': 'உங்கள் புகார்களைத் தேடுங்கள்...',
    'Completed': 'முடிந்தது',
    'Closed': 'மூடப்பட்டது',
    'SEVERE': 'கடும்',
    'MEDIUM': 'நடுத்தர',
    'LOW': 'குறைந்த',
    'HIGH': 'உயர்ந்த',
    'Submitted': 'சமர்ப்பிக்கப்பட்டது',
    'Verified': 'சரிபார்க்கப்பட்டது',
    'Attached Photos': 'இணைக்கப்பட்ட புகைப்படங்கள்',
    'Resolution Details': 'தீர்வு விவரங்கள்',
    'Worker Notes:': 'பணியாளர் குறிப்புகள்:',
    'Citizen Rating:': 'குடிமகன் மதிப்பீடு:',
    'Feedback:': 'பின்னூட்டம்:',
    'Proof of Completion:': 'முடித்ததற்கான சான்று:',
    'Notifications': 'அறிவிப்புகள்',
    'Mark all read': 'அனைத்தையும் படி',
    'Today': 'இன்று',
    'Earlier': 'முன்னதாக',
    'Complaint Submitted': 'புகார் சமர்ப்பிக்கப்பட்டது',
    'Close': 'மூடு',
    'Get Directions': 'வழியைப் பெறுங்கள்',
    'Assignment': 'பணி ஒதுக்கீடு',
    'Location & Date': 'இடம் மற்றும் தேதி',
    'Last Updated': 'கடைசியாக புதுப்பிக்கப்பட்டது',
    'Issue Location': 'புகாரின் இடம்',

    // Notification Dynamic Value Matchers & System Prompts
    'New Complaint': 'புதிய புகார்',
    'New System Complaint': 'புதிய கணினி புகார்',
    'Issue Status Updated': 'புகார் நிலை புதுப்பிக்கப்பட்டது',
    'New Task Assigned': 'புதிய பணி ஒதுக்கப்பட்டுள்ளது',
    'Task Status Updated': 'பணி நிலை புதுப்பிக்கப்பட்டது',
    'pending': 'நிலுவையில் உள்ளது',
    'in progress': 'செயலாக்கத்தில் உள்ளது',
    'resolved': 'தீர்க்கப்பட்டது',
    'closed': 'மூடப்பட்டது',
    'verified': 'சரிபார்க்கப்பட்டது',
    'completed': 'முடிந்தது',

    // Worker Dashboard
    'New Tasks': 'புதிய பணிகள்',
    'Active': 'செயலில்',
    'My Performance': 'எனது செயல்திறன்',
    'Tasks Done': 'முடிக்கப்பட்ட பணிகள்',
    'Completion Progress': 'நிறைவுப் பேரணி',
    'No active tasks right now': 'இப்போது செயலில் பணிகள் இல்லை',
    'Manage your assigned tasks & tracks progress':
        'உங்கள் ஒதுக்கப்பட்ட பணிகளை நிர்வகிக்கவும் மற்றும் முன்னேற்றத்தை கண்காணிக்கவும்',
    'Details': 'விவரங்கள்',
    'Start Work': 'வேலையைத் தொடங்கு',
    'Complete': 'முடி',
    'E-Signature Submitted': 'மின் கையொப்பம் சமர்ப்பிக்கப்பட்டது',
    'Tasks': 'பணிகள்',
    'History': 'வரலாறு',
    'E-Signature Required': 'மின் கையொப்பம் தேவை',
    'Clear': 'அழி',
    'Sign in the box below to confirm task completion':
        'பணி நிறைவை உறுதிப்படுத்த கீழே உள்ள பெட்டியில் கையொப்பமிடுங்கள்',
    'Confirm Completion with E-Signature':
        'மின் கையொப்பத்துடன் நிறைவை உறுதிப்படுத்து',
    'Submitting...': 'சமர்ப்பிக்கிறது...',
    'Signature captured': 'கையொப்பம் பதிவு செய்யப்பட்டது',
    'Draw your signature above then tap to confirm':
        'மேலே உங்கள் கையொப்பத்தை வரையுங்கள், பின்னர் உறுதிப்படுத்த தட்டவும்',
    'Capture Proof Image': 'சான்று படம் எடு',
    'Proof Image *': 'சான்று படம் *',
    'Resolution Notes': 'தீர்வு குறிப்புகள்',
    'Work Completion': 'வேலை நிறைவு',
    'of assigned tasks resolved': 'ஒதுக்கப்பட்ட பணிகளில் தீர்க்கப்பட்டவை',

    // Authority Dashboard
    'Authority Dashboard': 'அதிகாரி டாஷ்போர்டு',
    'Manage & verify community complaints':
        'சமூக புகார்களை நிர்வகிக்கவும் மற்றும் சரிபார்க்கவும்',
    'Complaint Volume (Weekly)': 'புகார் அளவு (வாராந்திர)',
    'Status Breakdown': 'நிலை பிரிவு',
    'Pending Review': 'சரிபார்ப்பு நிலுவையில்',
    'All Complaints': 'அனைத்து புகார்கள்',
    'Assigned': 'ஒதுக்கப்பட்டது',
    'Acknowledge & Verify': 'ஏற்றுக்கொண்டு சரிபார்',
    'Close Issue': 'புகாரை மூடு',
    'Authorize & Assign': 'அங்கீகரிக்கவும் மற்றும் ஒதுக்கவும்',
    'Analytics': 'பகுப்பாய்வு',
    'Assign Worker': 'பணியாளரை ஒதுக்கு',
    'Search by title, ticket, category...':
        'தலைப்பு, டிக்கெட், வகை மூலம் தேடுங்கள்...',
    'No complaints found': 'புகார்கள் எதுவும் கிடைக்கவில்லை',
    'Acknowledged': 'ஏற்றுக்கொள்ளப்பட்டது',
    'All': 'அனைத்தும்',

    // Admin Dashboard
    'Admin Dashboard': 'நிர்வாக டாஷ்போர்டு',
    'System overview & management': 'கணினி கண்ணோட்டம் மற்றும் நிர்வாகம்',
    'Users': 'பயனர்',
    'Q&A': 'கேள்வி/பதில்',
    'Issue Resolution Overview': 'புகார் தீர்வு கண்ணோட்டம்',
    'Issues by Department': 'துறை வாரியாக புகார்கள்',
    'User Management': 'பயனர் நிர்வாகம்',
    'Manage Workers & Authorities':
        'பணியாளர்கள் மற்றும் அதிகாரிகளை நிர்வகிக்கவும்',
    'Export Data': 'தரவை ஏற்றுமதி செய்',
    'Export Reports': 'அறிக்கைகளை ஏற்றுமதி செய்',
    'Generate CSV/PDF reports for analysis':
        'பகுப்பாய்வுக்கான CSV/PDF அறிக்கைகளை உருவாக்கு',
    'No data available to export': 'ஏற்றுமதி செய்ய தரவு இல்லை',

    // Ticket & Detail Screens
    'Status Timeline': 'நிலை காலவரிசை',
    'Submitted By': 'சமர்ப்பித்தவர்',
    'Submitted On': 'சமர்ப்பித்த தேதி',
    'Assigned Field Worker': 'ஒதுக்கப்பட்ட கள பணியாளர்',
    'Completion Proof Submitted': 'நிறைவு சான்று சமர்ப்பிக்கப்பட்டது',
    'E-signature captured and recorded by field worker':
        'கள பணியாளரால் மின் கையொப்பம் பதிவு செய்யப்பட்டது',
    'Rate This Resolution': 'இந்த தீர்வை மதிப்பிடுங்கள்',
    'How satisfied are you with the resolution?':
        'தீர்வு குறித்து நீங்கள் எவ்வளவு திருப்தி அடைகிறீர்கள்?',
    'Rate Resolution': 'தீர்வை மதிப்பிடு',
    'Reported By': 'புகார் அளித்தவர்',
    'Work Verified with E-Signature':
        'மின் கையொப்பத்துடன் வேலை சரிபார்க்கப்பட்டது',
    'E-Signature on file': 'கோப்பில் மின் கையொப்பம்',
    'Verification': 'சரிபார்ப்பு',
    'Feedback & Rating': 'பின்னூட்டம் மற்றும் மதிப்பீடு',
    'Field Worker Assigned': 'கள பணியாளர் ஒதுக்கப்பட்டார்',
    'NEW': 'புதிய',
    'No notifications yet': 'இதுவரை அறிவிப்புகள் இல்லை',
    'You\'ll see updates about your issues here':
        'உங்கள் புகார்கள் பற்றிய புதுப்பிப்புகளை இங்கே காண்பீர்கள்',
    'No issues reported yet': 'இதுவரை புகார்கள் எதுவும் பதிவாகவில்லை',
    'Tap the + button to report your first issue':
        'உங்கள் முதல் புகாரை பதிவு செய்ய + பொத்தானைத் தட்டவும்',
    'Tap \"Report Issue\" to submit your first complaint':
        'உங்கள் முதல் புகாரை சமர்ப்பிக்க \"புகார் செய்\" என்பதைத் தட்டவும்',
    'My Reports': 'என் புகார்கள்',

    // Report issue screen
    'Title *': 'தலைப்பு *',
    'Category *': 'வகை *',
    'Description *': 'விளக்கம் *',
    'Provide more details': 'மேலும் விவரங்களை வழங்கவும்',
    'e.g., Deep pothole on residential road':
        'உதாரணமாக, குடியிருப்புச் சாலையில் ஆழமான பள்ளம்',
    'Contact Info': 'தொடர்பு தகவல்',
    'Used only for status updates and verification':
        'நிலை புதுப்பிப்புகள் மற்றும் சரிபார்ப்புக்கு மட்டுமே பயன்படுத்தப்படும்',
    'Phone Number *': 'தொலைபேசி எண் *',
    'Review Submission': 'சமர்ப்பிப்பை மதிப்பாய்வு செய்',
    'Title': 'தலைப்பு',
    'Phone': 'தொலைபேசி',
    'AI is analyzing your photo...':
        'AI உங்கள் புகைப்படத்தை பகுப்பாய்வு செய்கிறது...',
    'This will auto-detect the issue type and priority.':
        'இது புகார் வகை மற்றும் முன்னுரிமையை தானாகக் கண்டறியும்.',
    'AI Identified the Issue ✓': 'AI புகாரை அடையாளம் கண்டுள்ளது ✓',
    'Could not identify the issue from photo':
        'புகைப்படத்திலிருந்து புகாரை அடையாளம் காண இயலவில்லை',
    'You can select the category manually in the next step.':
        'அடுத்த படியில் நீங்கள் வகையை கைமுறையாகத் தேர்ந்தெடுக்கலாம்.',
    'AI has auto-filled some fields based on your photo. Please verify.':
        'AI உங்கள் புகைப்படத்தின் அடிப்படையில் சில புலங்களை தானாக நிரப்பியுள்ளது. சரிபார்க்கவும்.',
    'Please fill in the details to describe the issue.':
        'புகாரை விவரிக்க விவரங்களை நிரப்பவும்.',
    'Auto-detected location. Tap map to adjust.':
        'தானாகக் கண்டறியப்பட்ட இடம். சரிசெய்ய வரைபடத்தைத் தட்டவும்.',
    'Finding address...': 'முகவரியைக் கண்டறிகிறது...',
    'Analyzing...': 'பகுப்பாய்வு செய்கிறது...',
    'low': 'குறைந்த',
    'medium': 'நடுத்தர',
    'high': 'உயர்ந்த',
    'severe': 'கடும்',

    // Profile screen strings
    'Help Center': 'உதவி மையம்',
    'About App': 'செயலியைப் பற்றி',
    'Dark Mode': 'இருண்ட பயன்முறை',
    'Light Mode': 'ஒளி பயன்முறை',
    'System': 'கணினி',
    'Email': 'மின்னஞ்சல்',
    'Role': 'பதவி',
    'Member Since': 'உறுப்பினர் ஆனது',
    'Edit Profile': 'சுயவிவரத்தை திருத்து',
    'Anonymous': 'அநாமதேய',
  };

  static String get(String key, bool isTamil) {
    if (!isTamil) return key;
    return ta[key] ?? key;
  }
}

extension TranslationExtension on String {
  String tr(BuildContext context) {
    try {
      final isTamil =
          Provider.of<PreferencesProvider>(context, listen: true).language ==
          'ta';

      var txt = this;
      if (isTamil) {
        // Dynamic Notification Strings regex matchers
        final submitReg = RegExp(
          r'^Your complaint "(.+)" \((CMP-[^\)]+)\) has been submitted\.$',
        );
        final verifyReg = RegExp(
          r'^A new complaint "(.+)" has been submitted and needs verification\.$',
        );
        final platformReg = RegExp(
          r'^A new complaint "(.+)" has been submitted to the platform\.$',
        );
        final statusReg = RegExp(r'^Issue "(.+)" status changed to (.+)\.$');
        final taskReg = RegExp(r'^Task "(.+)" is now (.+)\.$');

        if (submitReg.hasMatch(txt)) {
          final m = submitReg.firstMatch(txt)!;
          return 'உங்கள் புகார் "${m.group(1)}" (${m.group(2)}) சமர்ப்பிக்கப்பட்டுள்ளது.';
        }
        if (verifyReg.hasMatch(txt)) {
          final m = verifyReg.firstMatch(txt)!;
          return 'ஒரு புதிய புகார் "${m.group(1)}" சரிபார்ப்புக்கு சமர்ப்பிக்கப்பட்டுள்ளது.';
        }
        if (platformReg.hasMatch(txt)) {
          final m = platformReg.firstMatch(txt)!;
          return 'ஒரு புதிய புகார் "${m.group(1)}" சமர்ப்பிக்கப்பட்டுள்ளது.';
        }
        if (statusReg.hasMatch(txt)) {
          final m = statusReg.firstMatch(txt)!;
          return 'புகார் "${m.group(1)}" நிலை ${AppTranslations.get(m.group(2)!, true)} ஆக மாற்றப்பட்டுள்ளது.';
        }
        if (taskReg.hasMatch(txt)) {
          final m = taskReg.firstMatch(txt)!;
          return 'பணி "${m.group(1)}" இப்போது ${AppTranslations.get(m.group(2)!, true)} ஆக உள்ளது.';
        }

        return AppTranslations.get(txt, isTamil);
      }
      return txt;
    } catch (_) {
      return this; // Fallback gracefully if provider not in context or listen fails
    }
  }
}
