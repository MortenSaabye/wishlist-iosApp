//
//  WishViewController.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 12/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit

class WishViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
//    MARK: Properties
    var wish: Wish?
    var newCategoryCreated = false
    @IBOutlet weak var WishImageView: UIImageView!
    @IBOutlet weak var WishTextField: UITextField!
    @IBOutlet weak var WishUrlTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        saveButton.isEnabled = false
        WishTextField.delegate = self
        if let wish = self.wish {
            self.navigationItem.titleView = setTitle(title: wish.title, subtitle: wish.category)
            WishTextField.text = wish.title
            WishUrlTextView.text = wish.url?.absoluteString
            if let image = wish.image {
                WishImageView.image = image
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    MARK: Actions
    @IBAction func pasteLink(_ sender: UIButton) {
        if let url = UIPasteboard.general.url {
            self.wish = Wish(url: url)
            if let image = wish?.image {
                self.WishImageView.image = image
            }
            self.WishTextField.text = wish?.title
            self.WishUrlTextView.text = wish?.url?.absoluteString
            updateButtonState()
        } else {
            let alert = UIAlertController(title: "No link pasted", message: "It looks like you didn't paste a link...", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        
        }
    }
    @IBAction func cancel(_ sender: Any) {
//        If a new category was made, it must be deleted. 
        if self.newCategoryCreated == true {
            Wish.categories.removeLast()
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        WishTextField.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
//    MARK: Navigation 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        updateButtonState()
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("savebutton was not pressed...")
            return
        }
        guard let wishTitle = WishTextField.text else {
            print("No title in text view")
            return
        }
        let wishImage = WishImageView.image
        let wishUrl = URL(string: WishUrlTextView.text)

        if self.wish != nil {
            self.wish?.title = wishTitle
            self.wish?.image = wishImage
            self.wish?.url = wishUrl
            dismiss(animated: true, completion: nil)
        } else {
            self.wish = Wish(title: wishTitle, url: wishUrl, photo: wishImage)
        }
    }
    
    @IBAction func unwindFromCategoryView(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? CategoryViewController else {
            fatalError("Could not cast as WishViewController")
        }
        self.wish?.category = sourceViewController.category
//        New category created flag. If the user cancels after creating a new category, 
//        that category must be deleted because it is unused and shuld not show up in collection view.
        self.newCategoryCreated = sourceViewController.newCategoryCreated
    }
    
//    MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        WishImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        updateButtonState()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//    MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButtonState()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }

    
//    MARK: Private methods
    private func updateButtonState() {
        let text = WishTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    private func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(subtitleLabel.frame.width, titleLabel.frame.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
}

