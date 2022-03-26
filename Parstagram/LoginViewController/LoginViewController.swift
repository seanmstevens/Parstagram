//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var buttons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func toggleButtonsState() {
        buttons.forEach { $0.isEnabled.toggle() }
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        toggleButtonsState()
        PFUser.logInWithUsername(inBackground: username, password: password) { user, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
            } else {
                self.transitionToHome()
            }
            
            self.toggleButtonsState()
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        toggleButtonsState()
        user.signUpInBackground { success, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
            } else {
                self.transitionToHome()
            }
            
            self.toggleButtonsState()
        }
    }
    
    private func transitionToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNavigationController = storyboard.instantiateViewController(withIdentifier: "HomeNavigationController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeNavigationController)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
