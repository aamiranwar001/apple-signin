import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var fullName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = UserDefaults.standard.value(forKey: "User_FirstName") as! String
        let lastName = UserDefaults.standard.value(forKey: "User_LastName") as! String
        userId.text = UserDefaults.standard.value(forKey: "User_AppleID") as? String
        email.text = UserDefaults.standard.value(forKey: "User_Email") as? String
        fullName.text = "\(firstName) \(lastName)"
    }
}
