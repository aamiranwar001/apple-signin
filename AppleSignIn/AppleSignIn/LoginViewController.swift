import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSignInWithAppleButton()
        addObserverForAppleIDChangeNotification()
    }
    
    // Add Sign in with Apple button with target
    fileprivate func addSignInWithAppleButton() {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(appleIDButtonTapped), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1.0),
            button.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1.0)
        ])
    }

    // Open the dialog after tapping button
    @objc func appleIDButtonTapped() {
        // 1. Provider is responsible for generating requests for authentication based on AppleID.
        let provider = ASAuthorizationAppleIDProvider()
        
        // 2. From this provider, call “createRequest ()” method.
        let request = provider.createRequest()
        
        // 3. Define what scopes you want to receive from the user. Currently, only Email and Full name are available.
        request.requestedScopes = [.fullName, .email]
        
        // 4. Create an AuthorizationController from those requests
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // 5. Define the controller delegate, so you can respond to the user actions in the dialog.
        controller.delegate = self
        
        // 6. Provide a presentationContextProvider, so the controller can tell from what window to open.
        controller.presentationContextProvider = self
        
        // 7. Call performRequests method.
        controller.performRequests()
    }
    
    // Listen to this notification and then get the credential state for the user ID you got when the user logged in
    func addObserverForAppleIDChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appleIDStateChanged), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }
    
    @objc func appleIDStateChanged() {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: "\(UserDefaults.standard.value(forKey: "User_AppleID")!)") { (credentialState, error) in
            switch credentialState {
                case .authorized:
                    print("User is already authorized")
                case .revoked:
                    print("Logout user")
                case .notFound:
                    print("Logout user")
                default: break
            }
        }
    }
}

// MARK:- ASAuthorizationControllerDelegate
extension LoginViewController : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert: UIAlertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        // authorization object contains all the required data from the authorization process
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let email = credential.email {
                UserDefaults.standard.set("\(email)", forKey: "User_Email")
            }
            
            if let fullName = credential.fullName {
                UserDefaults.standard.set(fullName.givenName ?? "", forKey: "User_FirstName")
                UserDefaults.standard.set(fullName.familyName ?? "", forKey: "User_LastName")
            }
            
            let userID = credential.user
            if userID != "" {
                UserDefaults.standard.set("\(userID)", forKey: "User_AppleID")
            }
            
            UserDefaults.standard.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "DetailViewController") as DetailViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK:- ASAuthorizationControllerPresentationContextProviding
extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
