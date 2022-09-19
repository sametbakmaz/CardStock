//
//  DetailsViewController.swift
//  CardStockProject
//
//  Created by Abdulsamet Bakmaz on 19.09.2022.
//

import UIKit
import CoreData


class DetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stokAdiText: UITextField!
    @IBOutlet weak var stokKoduText: UITextField!
    @IBOutlet weak var stokBirimComboText: UITextField!
    @IBOutlet weak var kdvTipComboText: UITextField!
    @IBOutlet weak var aciklamaText: UITextView!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    var secilenStokAdi = ""
    var secilenStokUUID : UUID?
    
    let birimList = ["ADET","KİLOGRAM","LİTRE","METRE"]
    let kdvList = ["%1","%8","%18"]
    
    let stokBirimPicker = UIPickerView()
    let kdvPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if secilenStokAdi != ""{
            saveButtonOutlet.isHidden = true
            //core data secilen ürn bilgilerini göster
            if let uuidString = secilenStokUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardStock")
                fetchRequest.predicate = NSPredicate(format: "id = %@",  uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let  stokAdi = sonuc.value(forKey: "stokAdi") as? String{
                                stokAdiText.text = stokAdi
                                stokAdiText.isEnabled = false
                            }
                            if let  stokKodu = sonuc.value(forKey: "stokKodu") as? String{
                                stokKoduText.text = stokKodu
                                stokKoduText.isEnabled = false
                            }
                            if let  stokBirimi = sonuc.value(forKey: "stokBirimi") as? String{
                                stokBirimComboText.text = stokBirimi
                                stokBirimComboText.isEnabled = false
                            }
                            if let  kdvTip = sonuc.value(forKey: "kdv") as? String{
                                kdvTipComboText.text = kdvTip
                                kdvTipComboText.isEnabled = false
                            }
                            if let  aciklama = sonuc.value(forKey: "aciklama") as? String{
                                aciklamaText.text = aciklama
                                aciklamaText.isEditable = false
                            }
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data{
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                                
                            }
                        }
                    }
                }catch{
                    print("hata var")
                }
            }
        }else {
            // + ya tıklayarak yeni ürün için geldi
            stokAdiText.text = ""
            stokKoduText.text = ""
            stokBirimComboText.text = ""
            kdvTipComboText.text = ""
            aciklamaText.text = ""
            saveButtonOutlet.isEnabled = false
            
            imageView.isUserInteractionEnabled = true
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choseImage)) //fotoğraf seçimi için tıklandığında yapıalcak işlem
            imageView.addGestureRecognizer(imageGestureRecognizer)
        }

        //picker
        stokBirimPicker.delegate = self
        stokBirimPicker.dataSource = self
        stokBirimComboText.inputView = stokBirimPicker
        
        kdvPicker.delegate = self
        kdvPicker.dataSource = self
        kdvTipComboText.inputView = kdvPicker
        
        stokBirimPicker.tag = 1
        kdvPicker.tag = 2
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer) //viewControllera boş bir yere tıklandığında klavyeyi kapatır
        
        
    }
    

    //klavyeyi kapat
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    //Görsel seç
    @objc func choseImage(){
        let picker = UIImagePickerController()//fotoğraf seçimi için gerekli fonksiyon
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any]) { //medya seçmeyi bitirdim (didfinish), kullanıcı seçim yaptıktan sonra kullanulır.
        
        imageView.image = info[.originalImage] as? UIImage
        saveButtonOutlet.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    //Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == stokBirimPicker {
            return birimList.count
        }else if pickerView == kdvPicker {
            return kdvList.count
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == stokBirimPicker {
            return birimList[row]
        }else if pickerView == kdvPicker {
            return kdvList[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == stokBirimPicker {
            stokBirimComboText.text = birimList[row]
            self.view.endEditing(false)
        }else if pickerView == kdvPicker {
            kdvTipComboText.text = kdvList[row]
            self.view.endEditing(false)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
            //CoreData Bağlantısı
            let appDelegate = UIApplication.shared.delegate as! AppDelegate //app delegate deki fonksiyonları kullanabilmek için
            let context = appDelegate.persistentContainer.viewContext
            let CardStock = NSEntityDescription.insertNewObject(forEntityName: "CardStock", into: context)//CardStock tablosuna ekleme fonksiyonu için gerekli
            CardStock.setValue(stokKoduText.text!, forKey: "stokKodu")
            CardStock.setValue(stokAdiText.text!, forKey: "stokAdi")
            CardStock.setValue(stokBirimComboText.text!, forKey: "stokBirimi")
            CardStock.setValue(kdvTipComboText.text!, forKey: "kdv")
            CardStock.setValue(aciklamaText.text!, forKey: "aciklama")
            CardStock.setValue(UUID(), forKey: "id") //unique değer set etmek için
            let data = imageView.image!.jpegData(compressionQuality: 0.5) //görseller için (0.5 fotoğraf boyutu küçültme)
            CardStock.setValue(data, forKey: "gorsel")
            
            do{
                try context.save() //veriyi kaydetmesi için try catch yapısı kullanması hata yakalamsı gerekmekte
                print("veri kaydedildi")
            }catch{
                print("Hata Var")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)//verileri güncellemek sayfayayı yenilemek için kullanılır.
           self.navigationController?.popViewController(animated: true)//işlem yapıldıktan sonra bir önceki viewControllera döner
    }
    

}
