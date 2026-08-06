import Foundation

struct Localization {
    static let strings: [String: [Language: String]] = [
        "app_title": [
            .english: "AutismCare",
            .telugu: "ఆటిజం కేర్",
            .hindi: "ऑटिज्म केयर",
            .tamil: "ஆட்டிசம் கேர்",
            .kannada: "ಆಟಿಸಂ ಕೇರ್",
            .marathi: "ऑटिझम केअर"
        ],
        "total_patients": [
            .english: "TOTAL PATIENTS",
            .telugu: "మొత్తం రోగులు",
            .hindi: "कुल मरीज"
        ],
        "advice_given": [
            .english: "ADVISED",
            .telugu: "సమీక్షించబడింది",
            .hindi: "समीक्षित"
        ],
        "pending_review": [
            .english: "PENDING REVIEW",
            .telugu: "సమీక్ష పెండింగ్‌లో ఉంది",
            .hindi: "సమీక్ష కావలసివుంది"
        ],
        "my_patients": [
            .english: "MY PATIENTS",
            .telugu: "నా రోగులు",
            .hindi: "मेरे मरीज"
        ],
        "search_patients": [
            .english: "Search patients...",
            .telugu: "రోగుల కోసం వెతకండి...",
            .hindi: "मरीजों की खोज करें..."
        ],
        "good_morning": [
            .english: "Good morning",
            .telugu: "శుభోదయం",
            .hindi: "शुभ प्रभात"
        ],
        "good_afternoon": [
            .english: "Good afternoon",
            .telugu: "శుభ మధ్యాహ్నం",
            .hindi: "नमस्कार"
        ],
        "good_evening": [
            .english: "Good evening",
            .telugu: "శుభ సాయంత్రం",
            .hindi: "शुभ संध्या"
        ],
        "remove": [
            .english: "Remove",
            .telugu: "తొలగించు",
            .hindi: "हटाएं"
        ],
        "delete_patient": [
            .english: "Delete Patient",
            .telugu: "రోగిని తొలగించు",
            .hindi: "मरीज को हटाएं"
        ],
        "language_settings": [
            .english: "Language Settings",
            .telugu: "భాష సెట్టింగ్‌లు",
            .hindi: "भाषा सेटिंग्स",
            .tamil: "மொழி அமைப்புகள்",
            .kannada: "ಭಾಷಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
            .marathi: "भाषा सेटिंग्ज"
        ],
        "select_language": [
            .english: "Select Language",
            .telugu: "భాషను ఎంచుకోండి",
            .hindi: "भाषा चुनें",
            .tamil: "மொழியைத் தேர்ந்தெடுக்கவும்",
            .kannada: "ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ",
            .marathi: "भाषा निवडा"
        ],
        "home": [
            .english: "Home",
            .telugu: "హోమ్",
            .hindi: "होम",
            .tamil: "முகப்பு",
            .kannada: "ಮುಖಪುಟ",
            .marathi: "होम"
        ],
        "profile": [
            .english: "Profile",
            .telugu: "ప్రొఫైల్",
            .hindi: "प्रोफ़ाइल",
            .tamil: "சுயவிவரம்",
            .kannada: "ಪ್ರೊಫೈಲ್",
            .marathi: "प्रोफाइल"
        ],
        "reports": [
            .english: "Reports",
            .telugu: "నివేదికలు",
            .hindi: "रिपोर्ट"
        ],
        "assessments": [
            .english: "Assessments",
            .telugu: "అంచనాలు",
            .hindi: "मूल्यांकन"
        ],
        "feedbacks": [
            .english: "Feedbacks",
            .telugu: "అభిప్రాయాలు",
            .hindi: "फीडबैक"
        ],
        "monitoring_status": [
            .english: "Monitoring Status",
            .telugu: "పర్యవేక్షణ స్థితి",
            .hindi: "निगरानी की स्थिति"
        ],
        "active": [
            .english: "ACTIVE",
            .telugu: "క్రియాశీల",
            .hindi: "सक्रिय"
        ],
        "doctor_reviews_complete": [
            .english: "Doctor Reviews Complete",
            .telugu: "డాక్టర్ సమీక్షలు పూర్తయ్యాయి",
            .hindi: "डॉक्टर की समीक्षा पूरी हुई"
        ],
        "latest_doctor_feedback": [
            .english: "Latest Doctor Feedback",
            .telugu: "తాజా డాక్టర్ అభిప్రాయం",
            .hindi: "नवीनतम डॉक्टर फीडबैक"
        ],
        "new_assessment": [
            .english: "New Assessment",
            .telugu: "కొత్త అంచనా",
            .hindi: "नया मूल्यांकन"
        ],
        "start_assessment_subtitle": [
            .english: "Start a new behavior analysis session",
            .telugu: "కొత్త ప్రవర్తన విశ్లేషణ సెషన్‌ను ప్రారంభించండి",
            .hindi: "एक नया व्यवहार विश्लेषण सत्र शुरू करें"
        ],
        "good_night": [
            .english: "Good night",
            .telugu: "శుభ రాత్రి",
            .hindi: "शुभ रात्रि"
        ],
        "hello": [
            .english: "Hello",
            .telugu: "నమస్కారం",
            .hindi: "नमस्ते"
        ],
        "child_progress_summary": [
            .english: "Here's your child's progress summary",
            .telugu: "మీ బిడ్డ పురోగతి సారాంశం ఇక్కడ ఉంది",
            .hindi: "यहाँ आपके बच्चे की प्रगति का सारांश है"
        ],
        "child_journey_starts": [
            .english: "Your child's health journey starts here",
            .telugu: "మీ బిడ్డ ఆరోగ్య ప్రయాణం ఇక్కడ ప్రారంభమవుతుంది",
            .hindi: "आपके बच्चे की स्वास्थ्य यात्रा यहाँ से शुरू होती है",
            .tamil: "உங்கள் குழந்தையின் ஆரோக்கியப் பயணம் இங்கே தொடங்குகிறது",
            .kannada: "ನಿಮ್ಮ ಮಗುವಿನ ಆರೋಗ್ಯ ಪ್ರಯಾಣ ಇಲ್ಲಿಂದ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ",
            .marathi: "तुमच्या मुलाचा आरोग्य प्रवास येथून सुरू होतो"
        ],
        "sign_out": [
            .english: "Sign Out",
            .telugu: "సైన్ అవుట్",
            .hindi: "साइन आउट",
            .tamil: "வெளியேறு",
            .kannada: "ಸೈನ್ ಔಟ್",
            .marathi: "साइन आउट"
        ],
        "your_profile": [
            .english: "Your Profile",
            .telugu: "మీ ప్రొఫైల్",
            .hindi: "आपकी प्रोफ़ाइल"
        ],
        "your_reports": [
            .english: "Your Reports",
            .telugu: "మీ నివేదికలు",
            .hindi: "आपकी रिपोर्ट"
        ],
        "edit": [
            .english: "Edit",
            .telugu: "సవరించు",
            .hindi: "संपादित करें"
        ],
        "save_changes": [
            .english: "SAVE CHANGES",
            .telugu: "మార్పులను సేవ్ చేయి",
            .hindi: "बदलाव सहेजें"
        ],
        "patient_portal": [
            .english: "Patient Portal",
            .telugu: "రోగి పోర్టల్",
            .hindi: "पेशेंट पोर्टल",
            .tamil: "நோயாளி போர்டல்",
            .kannada: "ರೋಗಿಗಳ ಪೋರ್ಟಲ್",
            .marathi: "पेशंट पोर्टल"
        ],
        "doctor_portal": [
            .english: "Doctor Portal",
            .telugu: "డాక్టర్ పోర్టల్",
            .hindi: "डॉक्टर पोर्टल",
            .tamil: "மருத்துவர் போர்டல்",
            .kannada: "ವೈದ್ಯರ ಪೋರ್ಟಲ್",
            .marathi: "डॉक्टर पोर्टल"
        ],
        "continue_as_patient": [
            .english: "Continue as Patient",
            .telugu: "రోగిగా కొనసాగండి",
            .hindi: "मरीज के रूप में जारी रखें"
        ],
        "access_profile_history": [
            .english: "Access your child's profile & history",
            .telugu: "మీ బిడ్డ ప్రొఫైల్ మరియు చరిత్రను యాక్సెస్ చేయండి",
            .hindi: "अपने बच्चे की प्रोफाइल और इतिहास देखें"
        ],
        "register_as_patient": [
            .english: "Register as Patient",
            .telugu: "రోగిగా నమోదు చేసుకోండి",
            .hindi: "मरीज के रूप में पंजीकरण करें"
        ],
        "create_new_profile_subtitle": [
            .english: "Create a new profile for your child",
            .telugu: "మీ బిడ్డ కోసం కొత్త ప్రొఫైల్‌ను సృష్టించండి",
            .hindi: "अपने बच्चे के लिए एक नई प्रोफाइल बनाएं"
        ],
        "select_portal": [
            .english: "Select Your Portal",
            .telugu: "మీ పోర్టల్‌ని ఎంచుకోండి",
            .hindi: "अपना पोर्टल चुनें"
        ],
        "patient_portal_subtitle": [
            .english: "Symptom tracking & early screening",
            .telugu: "లక్షణాల గుర్తింపు మరియు స్క్రీనింగ్",
            .hindi: "लक्षण ट्रैकिंग और स्क्रीनिंग"
        ],
        "doctor_portal_subtitle": [
            .english: "Clinical assessments & data analysis",
            .telugu: "క్లినికల్ అంచనాలు మరియు డేటా విశ్లేషణ",
            .hindi: "नैदानिक मूल्यांकन और डेटा विश्लेषण"
        ],
        "trusted_medical": [
            .english: "✦ Trusted by Medical Professionals Worldwide ✦",
            .telugu: "✦ ప్రపంచవ్యాప్తంగా వైద్య నిపుణులచే విశ్వసించబడింది ✦",
            .hindi: "✦ दुनिया भर के चिकित्सा पेशेवरों द्वारा विश्वसनीय ✦"
        ],
        "monthly_timeline": [
            .english: "Monthly Timeline",
            .telugu: "నెలవారీ టైమ్‌లైన్",
            .hindi: "मासिक समयरेखा"
        ],
        "no_reports_month": [
            .english: "No reports found for this month.",
            .telugu: "ఈ నెలలో నివేదికలేవీ కనుగొనబడలేదు.",
            .hindi: "इस महीने के लिए कोई रिपोर्ट नहीं मिली।"
        ],
        "no_reports_yet": [
            .english: "No reports found yet.",
            .telugu: "ఇంకా నివేదికలేవీ కనుగొనబడలేదు.",
            .hindi: "अभी तक कोई रिपोर्ट नहीं मिली।"
        ],
        "behaviour_analysis": [
            .english: "Behaviour Analysis",
            .telugu: "ప్రవర్తన విశ్లేషణ",
            .hindi: "व्यवहार विश्लेषण"
        ],
        "analysis_description": [
            .english: "Understand your child's behavior with simple guided tools and insights.",
            .telugu: "సరళమైన మార్గదర్శక సాధనాలు మరియు అంతర్దృష్టులతో మీ బిడ్డ ప్రవర్తనను అర్థం చేసుకోండి.",
            .hindi: "सरल निर्देशित उपकरणों और अंतर्दृष्टि के साथ अपने बच्चे के व्यवहार को समझें।"
        ],
        "begin_analysis": [
            .english: "BEGIN ANALYSIS",
            .telugu: "విశ్లేషణ ప్రారంభించండి",
            .hindi: "विश्लेषण शुरू करें"
        ],
        "select_age_group": [
            .english: "Select Age Group",
            .telugu: "వయస్సు సమూహాన్ని ఎంచుకోండి",
            .hindi: "आयु वर्ग चुनें"
        ],
        "age_bracket_description": [
            .english: "Choose the respective age bracket to ensure clinical alignment.",
            .telugu: "క్లినికల్ అమరికను నిర్ధారించడానికి సంబంధిత వయస్సు బ్రాకెట్‌ను ఎంచుకోండి.",
            .hindi: "नैदानिक संरेखण सुनिश्चित करने के लिए संबंधित आयु वर्ग चुनें।"
        ],
        "infant_toddler": [
            .english: "Infant & Toddler",
            .telugu: "శిశువు & పసిబిడ్డ",
            .hindi: "शिशु और बच्चा"
        ],
        "under_3_years": [
            .english: "Under 3 Years Old",
            .telugu: "3 సంవత్సరాల కంటే తక్కువ వయస్సు",
            .hindi: "3 साल से कम उम्र"
        ],
        "older_child": [
            .english: "Older Child",
            .telugu: "పెద్ద బిడ్డ",
            .hindi: "बड़ा बच्चा"
        ],
        "older_3_years": [
            .english: "3 Years and Older",
            .telugu: "3 సంవత్సరాలు మరియు అంతకంటే ఎక్కువ",
            .hindi: "3 साल और उससे अधिक"
        ],
        "continue": [
            .english: "Continue",
            .telugu: "కొనసాగించు",
            .hindi: "जारी रखें"
        ],
        "loading_symptoms": [
            .english: "Loading symptoms...",
            .telugu: "లక్షణాలను లోడ్ చేస్తోంది...",
            .hindi: "लक्षण लोड हो रहे हैं..."
        ],
        "retry": [
            .english: "Retry",
            .telugu: "మళ్ళీ ప్రయత్నించు",
            .hindi: "पुनः प्रयास करें"
        ],
        "question_counter": [
            .english: "Question %d of %d",
            .telugu: "ప్రశ్న %d లో %d",
            .hindi: "प्रश्न %d का %d"
        ],
        "exhibit_symptom": [
            .english: "Does the child exhibit this symptom?",
            .telugu: "బిడ్డ ఈ లక్షణాన్ని ప్రదర్శిస్తున్నారా?",
            .hindi: "क्या बच्चा यह लक्षण दिखा रहा है?"
        ],
        "yes": [
            .english: "YES",
            .telugu: "అవును",
            .hindi: "हाँ"
        ],
        "no": [
            .english: "NO",
            .telugu: "కాదు",
            .hindi: "नहीं"
        ],
        "assessment": [
            .english: "Assessment",
            .telugu: "అంచనా",
            .hindi: "मूल्यांकन"
        ],
        "no_symptoms_found": [
            .english: "No symptoms found for this age group.",
            .telugu: "ఈ వయస్సు సమూహానికి ఎటువంటి లక్షణాలు కనుగొనబడలేదు.",
            .hindi: "इस आयु वर्ग के लिए कोई लक्षण नहीं मिले।"
        ],
        "assessment_completed": [
            .english: "Assessment Completed!",
            .telugu: "అంచనా పూర్తయింది!",
            .hindi: "मूल्यांकन पूरा हुआ!"
        ],
        "data_saved_review": [
            .english: "Data has been saved and is available for further review by your doctor.",
            .telugu: "డేటా సేవ్ చేయబడింది మరియు మీ డాక్టర్ తదుపరి సమీక్ష కోసం అందుబాటులో ఉంది.",
            .hindi: "डेटा सहेज लिया गया है और आपके डॉक्टर द्वारा आगे की समीक्षा के लिए उपलब्ध है।"
        ],
        "back_to_dashboard": [
            .english: "Back to Dashboard",
            .telugu: "డాష్‌బోర్డ్‌కు తిరిగి వెళ్ళు",
            .hindi: "डैशबोर्ड पर वापस जाएं"
        ],
        "responses_saved": [
            .english: "Responses Saved Successfully",
            .telugu: "ప్రతిస్పందనలు విజయవంతంగా సేవ్ చేయబడ్డాయి",
            .hindi: "प्रतिक्रियाएं सफलतापूर्वक सहेजी गईं"
        ],
        "assessment_submitted_view": [
            .english: "Your assessment has been submitted. You can now view the details below.",
            .telugu: "మీ అంచనా సమర్పించబడింది. మీరు ఇప్పుడు దిగువ వివరాలను చూడవచ్చు.",
            .hindi: "आपका मूल्यांकन जमा कर दिया गया है। अब आप नीचे विवरण देख सकते हैं।"
        ],
        "view_result": [
            .english: "View Result",
            .telugu: "ఫలితాన్ని చూడండి",
            .hindi: "परिणाम देखें"
        ],
        "back_to_home": [
            .english: "Back to Home",
            .telugu: "హోమ్‌కు తిరిగి వెళ్ళు",
            .hindi: "होम पर वापस जाएं"
        ],
        "assessment_result_title": [
            .english: "Assessment Result",
            .telugu: "అంచనా ఫలితం",
            .hindi: "मूल्यांकन परिणाम"
        ],
        "review_analysis_below": [
            .english: "Review the analysis below",
            .telugu: "దిగువ విశ్లేషణను సమీక్షించండి",
            .hindi: "नीचे दिए गए विश्लेषण की समीक्षा करें"
        ],
        "clinical_result_label": [
            .english: "Clinical Result",
            .telugu: "క్లినికల్ ఫలితం",
            .hindi: "नैदानिक परिणाम"
        ],
        "ai_summary_label": [
            .english: "AI Summary",
            .telugu: "AI సారాంశం",
            .hindi: "AI सारांश"
        ],
        "screening_score_label": [
            .english: "Screening Score",
            .telugu: "స్క్రీనింగ్ స్కోర్",
            .hindi: "स्क्रीनिंग स्कोर"
        ],
        "indicators_detected_label": [
            .english: "Indicators Detected",
            .telugu: "సూచికలు కనుగొనబడ్డాయి",
            .hindi: "पाए गए संकेतक"
        ],
        "risk_level_label": [
            .english: "Risk Level",
            .telugu: "ప్రమాద స్థాయి",
            .hindi: "जोखिम स्तर"
        ],
        "no_results_available": [
            .english: "No Results Available",
            .telugu: "ఫలితాలు అందుబాటులో లేవు",
            .hindi: "कोई परिणाम उपलब्ध नहीं"
        ],
        "complete_assessment_view": [
            .english: "Complete the assessment to view results.",
            .telugu: "ఫలితాలను చూడటానికి అంచనాను పూర్తి చేయండి.",
            .hindi: "परिणाम देखने के लिए मूल्यांकन पूरा करें।"
        ],
        "close": [
            .english: "Close",
            .telugu: "ముగించు",
            .hindi: "बंद करें"
        ],
        "edit_profile_title": [
            .english: "Edit Profile",
            .telugu: "ప్రొఫైల్‌ను సవరించండి",
            .hindi: "प्रोफ़ाइल संपादित करें"
        ],
        "profile_information": [
            .english: "Profile Information",
            .telugu: "ప్రొఫైల్ సమాచారం",
            .hindi: "प्रोफ़ाइल जानकारी"
        ],
        "full_name": [
            .english: "Full Name",
            .telugu: "పూర్తి పేరు",
            .hindi: "पूरा नाम"
        ],
        "phone_number": [
            .english: "Phone Number",
            .telugu: "ఫోన్ నంబర్",
            .hindi: "फ़ोन नंबर"
        ],
        "email_address": [
            .english: "Email Address",
            .telugu: "ఈమెయిల్ చిరునామా",
            .hindi: "ईमेल पता"
        ],
        "gender": [
            .english: "Gender",
            .telugu: "లింగం",
            .hindi: "लिंग"
        ],
        "select": [
            .english: "Select",
            .telugu: "ఎంచుకోండి",
            .hindi: "चुनें"
        ],
        "male": [
            .english: "Male",
            .telugu: "పురుషుడు",
            .hindi: "पुरुष"
        ],
        "female": [
            .english: "Female",
            .telugu: "స్త్రీ",
            .hindi: "महिला"
        ],
        "other_gender": [
            .english: "Other",
            .telugu: "ఇతర",
            .hindi: "अन्य"
        ],
        "date_of_birth": [
            .english: "Date of Birth",
            .telugu: "పుట్టిన తేదీ",
            .hindi: "जन्म तिथि"
        ],
        "cancel": [
            .english: "Cancel",
            .telugu: "రద్దు చేయి",
            .hindi: "रद्द करें"
        ],
        "ok": [
            .english: "OK",
            .telugu: "సరే",
            .hindi: "ठीक है"
        ],
        "profile_update_title": [
            .english: "Profile Update",
            .telugu: "ప్రొఫైల్ అప్‌డేట్",
            .hindi: "प्रोफ़ाइल अपडेट"
        ],
        "add_photo": [
            .english: "ADD PHOTO",
            .telugu: "ఫోటో జోడించండి",
            .hindi: "फोटो जोड़ें"
        ],
        "years": [
            .english: "years",
            .telugu: "సంవత్సరాలు",
            .hindi: "वर्ष"
        ],
        "registered_on": [
            .english: "Registered on",
            .telugu: "నమోదైన తేదీ",
            .hindi: "पंजीकृत तिथि"
        ],
        "welcome_back": [
            .english: "Welcome Back",
            .telugu: "తిరిగి స్వాగతం",
            .hindi: "वापसी पर स्वागत है"
        ],
        "login_subtitle": [
            .english: "Log in to monitor your child's progress",
            .telugu: "మీ బిడ్డ పురోగతిని పర్యవేక్షించడానికి లాగిన్ చేయండి",
            .hindi: "अपने बच्चे की प्रगति की निगरानी के लिए लॉग इन करें"
        ],
        "enter_id_placeholder": [
            .english: "Enter ID (e.g. PAT123)",
            .telugu: "ID ని నమోదు చేయండి (ఉదా. PAT123)",
            .hindi: "आईडी दर्ज करें (जैसे PAT123)"
        ],
        "password_label": [
            .english: "Password",
            .telugu: "పాస్‌వర్డ్",
            .hindi: "पासवर्ड"
        ],
        "password_placeholder": [
            .english: "Your secure password",
            .telugu: "మీ సురక్షిత పాస్‌వర్డ్",
            .hindi: "आपका सुरक्षित पासवर्ड"
        ],
        "forgot_password": [
            .english: "Forgot password?",
            .telugu: "పాస్‌వర్డ్ మరిచిపోయారా?",
            .hindi: "पासवर्ड भूल गए?"
        ],
        "log_in_button": [
            .english: "LOG IN",
            .telugu: "లాగిన్ చేయండి",
            .hindi: "लॉग इन करें"
        ],
        "login_failed_title": [
            .english: "Login Failed",
            .telugu: "లాగిన్ విఫలమైంది",
            .hindi: "लॉग इन विफल"
        ],
        "Child is not sharing things when asked": [
            .english: "Child is not sharing things when asked",
            .telugu: "అడిగినప్పుడు బిడ్డ వస్తువులను పంచుకోవడం లేదు",
            .hindi: "पूछने पर बच्चा चीजें साझा नहीं कर रहा है"
        ],
        "Child does not involve in imaginative play": [
            .english: "Child does not involve in imaginative play",
            .telugu: "పిల్లవాడు ఊహాజనిత ఆటలో పాల్గొనడు",
            .hindi: "बच्चा कल्पनाशील खेल में शामिल नहीं होता है"
        ],
        "Sometimes it feels like child can't hear well": [
            .english: "Sometimes it feels like child can't hear well",
            .telugu: "కొన్నిసార్లు బిడ్డ సరిగా వినలేనట్లు అనిపిస్తుంది",
            .hindi: "कभी-कभी लगता है कि बच्चा ठीक से सुन नहीं पा रहा है"
        ],
        "Child grabs elders hands to his/her point of interest": [
            .english: "Child grabs elders hands to his/her point of interest",
            .telugu: "బిడ్డ పెద్దల చేతులను తన ఆసక్తి పాయింట్ వైపుకు లాగుతుంది",
            .hindi: "बच्चा बड़ों के हाथ अपने रुचि के स्थान की ओर खींचता है"
        ],
        "Child has poor eye contact": [
            .english: "Child has poor eye contact",
            .telugu: "బిడ్డకు కంటి చూపు (eye contact) సరిగా లేదు",
            .hindi: "बच्चे का आई कॉन्टैक्ट खराब है"
        ],
        "Child has abnormal gestures and behaviour": [
            .english: "Child has abnormal gestures and behaviour",
            .telugu: "బిడ్డ ప్రవర్తన మరియు సైగలు అసాధారణంగా ఉన్నాయి",
            .hindi: "बच्चे का हाव-भाव और व्यवहार असामान्य है"
        ],
        "Child prefers to be alone": [
            .english: "Child prefers to be alone",
            .telugu: "బిడ్డ ఒంటరిగా ఉండటానికి ఇష్టపడుతుంది",
            .hindi: "बच्चा अकेला रहना पसंद करता है"
        ],
        "Child does not like to be hugged or touched": [
            .english: "Child does not like to be hugged or touched",
            .telugu: "బిడ్డ కౌగిలించుకోవడం లేదా తాకడం ఇష్టపడదు",
            .hindi: "बच्चे को गले लगाना या छूना पसंद नहीं है"
        ],
        "Your child needs further Diagnostic Tests for Autism.": [
            .english: "Your child needs further Diagnostic Tests for Autism.",
            .telugu: "మీ బిడ్డకు ఆటిజం కోసం మరిన్ని రోగనిర్ధారణ పరీక్షలు అవసరం.",
            .hindi: "आपके बच्चे को ऑटिज्म के लिए और अधिक नैदानिक परीक्षणों की आवश्यकता है।"
        ],
        "Timeline": [
            .english: "Timeline",
            .telugu: "కాలక్రమం",
            .hindi: "समयरेखा"
        ],
        "specialization": [
            .english: "Specialization",
            .telugu: "ప్రత్యేకత",
            .hindi: "विशेषज्ञता"
        ],
        "pediatrician": [
            .english: "Pediatrician",
            .telugu: "పిల్లల వైద్యుడు",
            .hindi: "बाल रोग विशेषज्ञ"
        ],
        "child_psychiatrist": [
            .english: "Child Psychiatrist",
            .telugu: "చైల్డ్ సైకియాట్రిస్ట్",
            .hindi: "बाल मनोचिकित्सक"
        ],
        "speech_therapist": [
            .english: "Speech Therapist",
            .telugu: "స్పీచ్ థెరపిస్ట్",
            .hindi: "स्पीच थेरेपिस्ट"
        ],
        "occupational_therapist": [
            .english: "Occupational Therapist",
            .telugu: "ఆక్యుపేషనల్ థెరపిస్ట్",
            .hindi: "ऑक्यूपेशनल थेरेपिस्ट"
        ],
        "edit_doctor_profile_title": [
            .english: "Edit Doctor Profile",
            .telugu: "డాక్టర్ ప్రొఫైల్‌ను సవరించండి",
            .hindi: "डॉक्टर प्रोफ़ाइल संपादित करें"
        ],
        "select_specialization": [
            .english: "Select Specialization",
            .telugu: "ప్రత్యేకతను ఎంచుకోండి",
            .hindi: "विशेषज्ञता चुनें"
        ],
        "your_profile_title": [
            .english: "Your Profile",
            .telugu: "మీ ప్రొఫైల్",
            .hindi: "आपकी प्रोफ़ाइल"
        ],
        "edit_profile_details": [
            .english: "EDIT PROFILE DETAILS",
            .telugu: "ప్రొఫైల్ వివరాలను సవరించండి",
            .hindi: "प्रोफ़ाइल विवरण संपादित करें"
        ],
        "update_professional_info": [
            .english: "Update your professional information",
            .telugu: "మీ వృత్తిపరమైన సమాచారాన్ని అప్‌డేట్ చేయండి",
            .hindi: "अपनी पेशेवर जानकारी अपडेट करें"
        ],
        "clinical_chronology": [
            .english: "CLINICAL CHRONOLOGY",
            .telugu: "క్లినికల్ క్రోనాలజీ",
            .hindi: "क्लिनिकल क्रोनोलॉजी"
        ],
        "no_history_recorded": [
            .english: "No history recorded yet.",
            .telugu: "ఇంకా చరిత్ర నమోదు కాలేదు.",
            .hindi: "अभी तक कोई इतिहास दर्ज नहीं किया गया है।"
        ],
        "delete_report": [
            .english: "Delete Report",
            .telugu: "నివేదికను తొలగించు",
            .hindi: "रिपोर्ट हटाएं"
        ],
        "delete_report_message": [
            .english: "Are you sure you want to permanently delete this clinical report? This action cannot be undone.",
            .telugu: "మీరు ఈ క్లినికల్ నివేదికను శాశ్వతంగా తొలగించాలనుకుంటున్నారా? ఈ చర్యను రద్దు చేయలేము.",
            .hindi: "क्या आप वाकई इस क्लिनिकल रिपोर्ट को स्थायी रूप से हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।"
        ],
        "permanent_deletion": [
            .english: "Permanent Deletion",
            .telugu: "శాశ్వత తొలగింపు",
            .hindi: "स्थायी विलोपन"
        ],
        "delete_permanently": [
            .english: "Delete Permanently",
            .telugu: "శాశ్వతంగా తొలగించు",
            .hindi: "स्थायी रूप से हटाएं"
        ],
        "confirm_delete_patient": [
            .english: "Confirming: Delete %@? This action is irreversible and wipes all database records.",
            .telugu: "ధృవీకరిస్తున్నాము: %@ను తొలగించాలా? ఈ చర్య మార్చలేనిది మరియు అన్ని రికార్డులను తుడిచివేస్తుంది.",
            .hindi: "पुष्टि कर रहे हैं: %@ को हटा दें? यह क्रिया अपरिवर्तनीय है और सभी रिकॉर्ड मिटा देती है।"
        ],
        "dr": [
            .english: "Dr. ",
            .telugu: "డాక్టర్ ",
            .hindi: "डॉ. "
        ],
        "clinical_guidance": [
            .english: "Clinical Guidance",
            .telugu: "క్లినికల్ మార్గదర్శకత్వం",
            .hindi: "क्लिनिकल मार्गदर्शन"
        ],
        "post_advice": [
            .english: "POST ADVICE",
            .telugu: "సలహాను పోస్ట్ చేయండి",
            .hindi: "सलाह पोस्ट करें"
        ],
        "no_clinical_notes": [
            .english: "No clinical notes recorded yet.",
            .telugu: "ఇంకా క్లినికల్ నోట్స్ నమోదు కాలేదు.",
            .hindi: "अभी तक कोई क्लिनिकल नोट्स दर्ज नहीं किए गए हैं।"
        ],
        "clinical_analysis_report": [
            .english: "CLINICAL ASSESSMENT REPORT",
            .telugu: "క్లినికల్ అసెస్‌మెంట్ నివేదిక",
            .hindi: "क्लिनिकल मूल्यांकन रिपोर्ट"
        ],
        "patient_id_label": [
            .english: "Patient ID",
            .telugu: "రోగి ID",
            .hindi: "मरीज ID"
        ],
        "patient_name_label": [
            .english: "Patient Name",
            .telugu: "రోగి పేరు",
            .hindi: "मरीज का नाम"
        ],
        "assessment_date_label": [
            .english: "Assessment Date",
            .telugu: "అంచనా తేదీ",
            .hindi: "मूल्यांकन की तिथि"
        ],
        "summary_label": [
            .english: "SUMMARY",
            .telugu: "సారాంశం",
            .hindi: "सारांश"
        ],
        "symptom_markers_label": [
            .english: "SYMPTOM MARKERS",
            .telugu: "లక్షణ మార్కర్లు",
            .hindi: "लक्षण मार्कर"
        ],
        "generated_via_system": [
            .english: "Generated via Saveetha Autism Care Network",
            .telugu: "సవీత ఆటిజం కేర్ నెట్‌వర్క్ ద్వారా రూపొందించబడింది",
            .hindi: "सवीथा ऑटिज्म केयर नेटवर्क के माध्यम से उत्पन्न"
        ],
        "clinical_analysis": [
            .english: "Clinical Analysis",
            .telugu: "క్లినికల్ విశ్లేషణ",
            .hindi: "क्लिनिकल विश्लेषण"
        ],
        "symptom_matrix": [
            .english: "Symptom Matrix",
            .telugu: "లక్షణాల మాతృక",
            .hindi: "लक्षण मैट्रिक्स"
        ],
        "download_report": [
            .english: "Download Report",
            .telugu: "నివేదికను డౌన్‌లోడ్ చేయండి",
            .hindi: "रिपोर्ट डाउनलोड करें"
        ],
        "delete_report_confirm": [
            .english: "Delete Report?",
            .telugu: "నివేదికను తొలగించాలా?",
            .hindi: "रिपोर्ट हटाएं?"
        ],
        "Your Child Needs Further Diagnostic Tests For Autism.": [
            .english: "Your Child Needs Further Diagnostic Tests For Autism.",
            .telugu: "మీ బిడ్డకు ఆటిజం కోసం మరిన్ని రోగనిర్ధారణ పరీక్షలు అవసరం.",
            .hindi: "आपके बच्चे को ऑटिज्म के लिए और अधिक नैदानिक परीक्षणों की आवश्यकता है।"
        ],
        "Child is not looking at the direction point": [
            .english: "Child is not looking at the direction point",
            .telugu: "బిడ్డ దిశ పాయింట్ వైపు చూడటం లేదు",
            .hindi: "बच्चा दिशा बिंदु की ओर नहीं देख रहा है"
        ],
        "My child is not imitating my actions": [
            .english: "My child is not imitating my actions",
            .telugu: "నా బిడ్డ నా చర్యలను అనుకరించడం లేదు",
            .hindi: "मेरा बच्चा मेरे कार्यों की नकल नहीं कर रहा है"
        ],
        "Child is finding difficult to express smile": [
            .english: "Child is finding difficult to express smile",
            .telugu: "బిడ్డ చిరునవ్వును వ్యక్తపరచడం కష్టంగా అనిపిస్తోంది",
            .hindi: "बच्चे को मुस्कान व्यक्त करने में कठिनाई हो रही है"
        ],
        "Has poor eye contact": [
            .english: "Has poor eye contact",
            .telugu: "కంటిచూపు సరిగా లేదు",
            .hindi: "आई कॉन्टैक्ट खराब है"
        ],
        "Child is finding it difficult to understand gestures": [
            .english: "Child is finding it difficult to understand gestures",
            .telugu: "బిడ్డ సైగలను అర్థం చేసుకోవడం కష్టంగా అనిపిస్తోంది",
            .hindi: "बच्चे को इशारों को समझने में कठिनाई हो रही है"
        ],
        "My child prefers to be alone": [
            .english: "My child prefers to be alone",
            .telugu: "నా బిడ్డ ఒంటరిగా ఉండటానికి ఇష్టపడతారు",
            .hindi: "मेरा बच्चा अकेला रहना पसंद करता है"
        ],
        "professional_clinical_care": [
            .english: "Professional Clinical Assessment & Care",
            .telugu: "ప్రొఫెషనల్ క్లినికల్ అసెస్‌మెంట్ & కేర్",
            .hindi: "पेशेवर नैदानिक मूल्यांकन एवं देखभाल"
        ],
        "empowering_doctors_marquee": [
            .english: "✦  Empowering Doctors, Improving Lives  ✦  Authorized Personnel Only  ✦  Secure Assessment Portal  ✦",
            .telugu: "✦ డాక్టర్లను శక్తివంతం చేయడం ✦ అధికారిక సిబ్బందికి మాత్రమే ✦ సురక్షిత పోర్టల్ ✦",
            .hindi: "✦ डॉक्टरों को सशक्त बनाना ✦ केवल अधिकृत कर्मियों के लिए ✦ सुरक्षित पोर्टल ✦"
        ],
        "continue_as_doctor": [
            .english: "Continue as Doctor",
            .telugu: "డాక్టర్‌గా కొనసాగండి",
            .hindi: "डॉक्टर के रूप में जारी रखें"
        ],
        "secure_auth_patient_lists": [
            .english: "Secure authorization & patient lists",
            .telugu: "సురక్షిత అధికారం & రోగుల జాబితాలు",
            .hindi: "सुरक्षित प्राधिकरण एवं मरीजों की सूची"
        ],
        "register_as_doctor": [
            .english: "Register as Doctor",
            .telugu: "డాక్టర్‌గా నమోదు చేసుకోండి",
            .hindi: "डॉक्टर के रूप में पंजीकरण करें"
        ],
        "join_professional_network": [
            .english: "Join the professional care network",
            .telugu: "ప్రొఫెషనల్ కేర్ నెట్‌వర్క్‌లో చేరండి",
            .hindi: "पेशेवर देखभाल नेटवर्क से जुड़ें"
        ],
        "professional_access": [
            .english: "Professional Access",
            .telugu: "ప్రొఫెషనల్ యాక్సెస్",
            .hindi: "पेशेवर पहुंच"
        ],
        "clinical_dashboard_care_providers": [
            .english: "Clinical Dashboard for Care Providers",
            .telugu: "కేర్ ప్రొవైడర్‌ల కోసం క్లినికల్ డాష్‌బోర్డ్",
            .hindi: "देखभाल प्रदाताओं के लिए नैदानिक डैशबोर्ड"
        ],
        "professional_email": [
            .english: "Professional Email",
            .telugu: "ప్రొఫెషనల్ ఇమెయిల్",
            .hindi: "पेशेवर ईमेल"
        ],
        "security_password": [
            .english: "Security Password",
            .telugu: "భద్రతా పాస్‌వర్డ్",
            .hindi: "सुरक्षा पासवर्ड"
        ],
        "enter_credentials": [
            .english: "Enter credentials",
            .telugu: "ఆధారాలను నమోదు చేయండి",
            .hindi: "क्रेडेंशियल्स दर्ज करें"
        ],
        "authorize_login": [
            .english: "AUTHORIZE LOGIN",
            .telugu: "లాగిన్ అధికారం ఇవ్వండి",
            .hindi: "लॉगिन अधिकृत करें"
        ],
        "authorized_clinical_use": [
            .english: "Authorized Clinical Use Only",
            .telugu: "అధీకృత క్లినికల్ ఉపయోగానికి మాత్రమే",
            .hindi: "केवल अधिकृत नैदानिक उपयोग के लिए"
        ],
        "saveetha_network": [
            .english: "Saveetha Autism Care Network",
            .telugu: "సవీత ఆటిజం కేర్ నెట్‌వర్క్",
            .hindi: "सवीथा ऑटिज़्म केयर नेटवर्क"
        ],
        "authorization_failed": [
            .english: "Authorization Failed",
            .telugu: "అధికారం విఫలమైంది",
            .hindi: "प्राधिकरण विफल"
        ]
    ]
    
    static func translate(_ key: String, for language: Language) -> String {
        return strings[key]?[language] ?? key
    }
}
