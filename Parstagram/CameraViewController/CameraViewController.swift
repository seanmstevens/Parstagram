//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imagePlaceholderView: UIImageView!
    @IBOutlet weak var commentField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePlaceholderView.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
    }

    @IBAction func onTapImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imagePlaceholderView.image = scaledImage
        dismiss(animated: true)
    }
    
    @IBAction func onPost(_ sender: Any) {
        let post = Post()
        post.caption = commentField.text
        post.author = PFUser.current()
        post.media = PFFileObject(name: "image.png", data: (imagePlaceholderView.image?.pngData())!)
        
        post.saveInBackground { success, error in
            if let error = error {
                print("Error when creating post: \(error.localizedDescription)")
            } else {
                print("Post created!")
                self.navigationController?.popViewController(animated: true)
            }
        }
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
