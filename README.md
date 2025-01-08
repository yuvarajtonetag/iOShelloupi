Minimum Deployment iOS version should be iOS 14

### Import HelloUPISDK 
1. Add the Hello_UPI_iOS_Framework under the project folder.
2. Go to Project Target -> General Tab ->  Frameworks, libraries and Embedded Content.
3. Modify the Embeded value of Hello_UPI_iOS_Framework to Embed & Sign.
4. In the Home Screen swift file, get values of the below variable.

```
@State private var bic = "YOUR_BIC" //Request to Tonetag Team at allocate the BIC
@State private var apiKey = "YOUR_GOOGLE_CLOUD_API_KEY" //Request to Tonetag Team at allocate the Google Cloud API Key
@State private var subscriptionKey = "YOUR_SUBSCRIPTION_KEY" //Request to Tonetag Team at allocate the sub key based on environment
```
### Necessary permission for Info.plist
* Add NSMicrophoneUsageDescription key
* Add NSSpeechRecognitionUsageDescription
* Add NSContactsUsageDescription
