//
//  DetailsViewController.swift
//  ShoppingListProject
//
//  Created by Denis DRAGAN on 29.04.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    
    var selectedProductName = ""
    var selectedProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != "" {
            saveButton.isHidden = true
            nameTextField.isEnabled = false
            priceTextField.isEnabled = false
            sizeTextField.isEnabled = false
            // CoreData secilen urun bilgileri
            if let uuidString = selectedProductUUID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                            }
                            if let price = result.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String {
                                sizeTextField.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("Fetch Error")
                }
            }
            
        } else {
            // Urun ekleme sirasinda save button davranislari
            saveButton.isHidden = false
            saveButton.isEnabled = false
            // Textlerin bos gelmesi
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }
        
        let gectureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        // view'de boş alanlara tıklandıgında
        view.addGestureRecognizer(gectureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        saveButton.isEnabled = true
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        // CoreDate import edilir ve ShoppingListProject'e ulasma
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        shopping.setValue(sizeTextField.text!, forKey: "size")
        shopping.setValue(nameTextField.text!, forKey: "name")
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
        if let price = Int(priceTextField.text!) {
            shopping.setValue(price, forKey: "price")
        }
        
        do {
            try context.save()
            print("Save successful")
        } catch {
            print("Error")
        }
        // veriler girildikten sonra tableView olan sayfaya geri donmesi
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataEntered"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
