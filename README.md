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

### How to request activation keys
We’re excited for you to explore the integration showcased in this repository! To get started with a trial, simply drop us a request at <a href="mailto:dev&#64;xyz&#46;com">Contact Us</a> with the following details:

Company Name
Contact Name
Company Email
Phone Number
Once we receive your request, we’ll promptly share your trial activation keys so you can dive right in. Looking forward to having you onboard and hearing your feedback!
