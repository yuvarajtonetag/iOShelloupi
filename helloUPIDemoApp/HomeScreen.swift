//
//  HomeScreen.swift
//  helloUPIDemoApp
//
//  Created by JAYA$URYA on 05/02/25.
//
import SwiftUI
import Contacts
import Hello_UPI_iOS_Framework
import Speech
import AVFoundation

struct HomeScreen: View {
    // This property determines the current environment
    @State private var environment = "Development"
    
    @State private var selectedLanguage: Language? = nil
    @State private var email = ""
    @State private var bic = ""
    @State private var apiKey = ""
    @State private var subscriptionKey = ""
    
    @State private var isEnvironmentPickerVisible = false
    @State private var isLanguagePickerVisible = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var permissionErrMsg = ""
    
    //This property determines whether sdk is displayed or not
    @State private var isSDKInitialized = false
    
    //This dict contains the final response data from SDK
    @State var contentToDisplay: [String:Any]? = nil
    
    let environments = ["Development", "Staging", "Pre Production", "Production"]
    
    var body: some View {
        VStack{
            Text("Hello UPI 0.1")
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.clear)
            ZStack {
                Color.clear
                Form {
                    EnvironmentSelectionSection()
                    LanguageSelectionSection()
                    BICInputSection()
                    SubscriptionKeyInputSection()
                    EmailInputSection()
                    GoogleAPIInputSection()
                    if(!permissionErrMsg.isEmpty){
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            Label(
                                title: { Text(permissionErrMsg).foregroundColor(.red) },
                                icon: { Image(systemName: "gear") }
                            )
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    
                    SubmitButtonSection()
                    if let contentToDisplay = contentToDisplay {
                        generatedText(dict: contentToDisplay)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                
                if isSDKInitialized {
                    VStack {
                        Spacer()  // Push the SDK view down to avoid the navigation bar
                        MySDK.shared.getSDKView()
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
    }
    
    @ViewBuilder
    private func EnvironmentSelectionSection() -> some View {
        Section(header: Text("Environment Selection").bold().foregroundColor(.black.opacity(0.8))) {
            Button(action: {
                isEnvironmentPickerVisible.toggle()
                hideKeyboard()
            }) {
                HStack {
                    Text(environment)
                        .foregroundColor(.black)
                    
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $isEnvironmentPickerVisible) {
                EnvironmentPicker()
            }
        }
    }
    
    @ViewBuilder
    private func EnvironmentPicker() -> some View {
        VStack {
            Text("Select Environment")
                .font(.headline)
                .padding()
            Divider()
            ScrollView {
                ForEach(environments, id: \.self) { env in
                    Button(action: {
                        environment = env
                        isEnvironmentPickerVisible.toggle()
                    }) {
                        Text("\(env)")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
            }
        }
    }
    
    @ViewBuilder
    private func LanguageSelectionSection() -> some View {
        Section(header: Text("Language Selection").bold().foregroundColor(.black.opacity(0.8))) {
            Button(action: {
                isLanguagePickerVisible.toggle()
                hideKeyboard()
            }) {
                HStack {
                    Text(selectedLanguage?.capitalizedString ?? "")
                        .foregroundColor(selectedLanguage == nil ? .gray : .black)
                    
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $isLanguagePickerVisible) {
                LanguagePicker()
            }
        }
    }
    
    @ViewBuilder
    private func LanguagePicker() -> some View {
        VStack {
            Text("Select Language")
                .font(.headline)
                .padding()
            Divider()
            ScrollView {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                        isLanguagePickerVisible.toggle()
                    }) {
                        Text("\(language.capitalizedString)")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
            }
        }
    }
    
    @ViewBuilder
    private func BICInputSection() -> some View {
        Section(header: Text("BIC").bold().foregroundColor(.black.opacity(0.8))) {
            TextField("Enter your BIC", text: $bic)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    @ViewBuilder
    private func SubscriptionKeyInputSection() -> some View {
        Section(header: Text("Subscription Key").bold().foregroundColor(.black.opacity(0.8))) {
            TextField("Enter your Subscription Key", text: $subscriptionKey)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    @ViewBuilder
    private func EmailInputSection() -> some View {
        Section(header: Text("Email Address").bold().foregroundColor(.black.opacity(0.8))) {
            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    @ViewBuilder
    private func GoogleAPIInputSection() -> some View {
        Section(header: Text("Google API Key").bold().foregroundColor(.black.opacity(0.8))) {
            TextField("Enter api key", text: $apiKey)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    @ViewBuilder
    private func SubmitButtonSection() -> some View {
        Section {
            Button(action: {
                hideKeyboard()
                if isValidForm() {
                    checkPermissionAndInitializeSDK()
                } else {
                    showAlert = true
                }
            }) {
                Text("Submit")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.5)]),
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private func generatedText(dict: [String: Any]) -> some View{
        var showText = "HelloUPI sdk response"
        // Response will be received in the main_content key
        let mainContent = dict["main_content"] as? [String: Any] ?? [:]
        
        //If the main content has session_id which means the Transaction is initiated successfully
        if let session_id = mainContent["session_id"] as? String {
            showText+="\n\nSession Id: \(session_id)"
            let flow_type = mainContent["flow_Type"] as? String ?? ""
            showText+="\n\nFlow type: \(flow_type)"
            let intent = mainContent["intent"] as? String ?? ""
            showText+="\n\nIntent: \(intent)"
            _ = try! JSONSerialization.data(withJSONObject: mainContent["callback_entity"] ?? [:])
            showText+="\n\nCallback Entity:: \(mainContent["callback_entity"] ?? [:])"
        }// If there is any error occured, error_code and its error_desc will be received
        else if let error_code = mainContent["error_code"] as? Int {
            if let error_desc = mainContent["error_desc"]{
                showText+="\n\nError Code: \(error_code), \(error_desc)"
            }
        }
        return Text(showText)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func isValidForm() -> Bool {
        if environment.isEmpty {
            alertMessage = "Please select an environment."
            return false
        }
        if selectedLanguage == .none {
            alertMessage = "Please select a language."
            return false
        }
        if !isValidEmail(email) || email.isEmpty {
            alertMessage = "Please enter a valid email address."
            return false
        }
        if bic.isEmpty {
            alertMessage = "Please enter bic"
            return false
        }
        if subscriptionKey.isEmpty {
            alertMessage = "Please enter subscription key"
            return false
        }
        if apiKey.isEmpty {
            alertMessage = "Please enter google cloud api key"
            return false
        }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    
    private func requestPermissions(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        // Request Speech Recognition permission
        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                debugPrint("Speech recognition not authorized")
                permissionErrMsg = "Please enable permissions to access your microphone, Speech recognition and contacts in app settings"
            }
            group.leave()
        }
        
        // Request Microphone permission
        group.enter()
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if !granted {
                    debugPrint("Microphone access not granted")
                    permissionErrMsg = "Please enable permissions to access your microphone, Speech recognition and contacts in app settings"
                }
                group.leave()
            }
        }else{
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    debugPrint("Microphone access not granted")
                    permissionErrMsg = "Please enable permissions to access your microphone, Speech recognition and contacts in app settings"
                }
                group.leave()
            }
        }
        // Request Contacts permission
        group.enter()
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            if !granted {
                debugPrint("Contacts access denied")
                permissionErrMsg = "Please enable permissions to access your microphone, Speech recognition and contacts in app settings"
            }
            group.leave()
        }
        
        // Check permissions after all requests are completed
        group.notify(queue: .main) {
            if self.isAllPermissionsGranted() {
                debugPrint("All permissions granted. Initializing SDK.")
                completion()
            } else {
                debugPrint("Not all permissions granted.")
            }
        }
    }
    private func isAllPermissionsGranted() -> Bool {
        let recordPermission: Bool
        if #available(iOS 17.0, *) {
            recordPermission = (AVAudioApplication.shared.recordPermission == .granted)
        } else {
            recordPermission = (AVAudioSession.sharedInstance().recordPermission == .granted)
        }
        return SFSpeechRecognizer.authorizationStatus() == .authorized &&
        recordPermission &&
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    //Check all the necessary permissions are already enabled
    private func checkPermissionAndInitializeSDK() {
        //Initialize SDK if necessary permissions are granted
        if isAllPermissionsGranted() {
            debugPrint("Permissions already granted. Initializing SDK.")
            initializeSDK()
        } else {
            debugPrint("Requesting permissions.")
            requestPermissions {
                self.initializeSDK()
            }
        }
    }

    private func initializeSDK() {
        guard !environment.isEmpty,
              !email.isEmpty,
              !bic.isEmpty,
              !subscriptionKey.isEmpty,
        let selectedLanguage = selectedLanguage  else {
            debugPrint("Error: All fields are required")
            return
        }
        
        let ttsModel = selectedLanguage.getValue() == "mr" ? "Wavenet" : "Standard"
        let voice = "A"
        let apiURL = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
        let googleServicesDict = [
            "ttsModel": ttsModel,
            "voice": voice,
            "apiURL": apiURL,
            "apiKey": apiKey
        ]
        var envVar = EnvironmentConfig.development
        if environment == environments[1]{
            envVar = EnvironmentConfig.staging
        }else if environment == environments[2]{
            envVar = EnvironmentConfig.pre_production
        }else if environment == environments[3]{
            envVar = EnvironmentConfig.production
        }
        
        //Start monitor the network from here
        NetworkMonitor.shared.startMonitoring()
        
        //Input required values for SDK to initialize
        let config = SDKConfiguration(
            environment: envVar,
            language: selectedLanguage,
            email: email,
            bic: bic,
            subscriptionKey: subscriptionKey,
            googleServiceDict: googleServicesDict,
            onDismiss: dismissSDK
        )
        debugPrint(config)
        
        MySDK.shared.initialize(with: config)
        isSDKInitialized = true
    }
    
    //Pass this dismissSDK method in SDKConfiguration to get the final response from SDK
    private func dismissSDK(dict: [String: Any]?) {
        isSDKInitialized = false
        debugPrint(String(describing: dict))
        contentToDisplay = dict
    }
}
