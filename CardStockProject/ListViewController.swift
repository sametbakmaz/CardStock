//
//  ListViewController.swift
//  CardStockProject
//
//  Created by Abdulsamet Bakmaz on 19.09.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var stokAdiDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenAd = ""
    var secilenUUID : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Stok Kart Listesi"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        verileriAl()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    
    @objc func addButton(){
        secilenAd = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    @objc func verileriAl(){
        stokAdiDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardStock")
        fetchRequest.returnsObjectsAsFaults = false //çok büyük verileri çekerken cache mekanizmasındna faydalanabilmek için gerekli
        
        do {
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let stokAdi = sonuc.value(forKey: "stokAdi") as? String{
                        stokAdiDizisi.append(stokAdi)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
            
        }catch{
            print("hata var")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stokAdiDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = stokAdiDizisi[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenStokAdi = secilenAd
            destinationVC.secilenStokUUID = secilenUUID
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenAd = stokAdiDizisi[indexPath.row]
        secilenUUID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardStock")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject]{
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                stokAdiDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("hata")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("hata var")
            }
        }
    }
    
}
