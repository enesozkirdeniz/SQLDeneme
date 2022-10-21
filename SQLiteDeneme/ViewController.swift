//
//  ViewController.swift
//  SQLiteDeneme
//
//  Created by Enes Özkırdeniz on 21.10.2022.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    
    var selected = ""
    
    var heroList = [Hero]()
    
    private let table : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let txt1 : UITextField = {
        let txt = UITextField()
        txt.placeholder = "Hero Names"
        txt.layer.borderWidth = 1
        txt.textAlignment = .center
        txt.textColor = .black
        txt.translatesAutoresizingMaskIntoConstraints = false
        return txt
    }()
    
    private let txt2 : UITextField = {
        let txt = UITextField()
        txt.placeholder = "Powers"
        txt.layer.borderWidth = 1
        txt.textAlignment = .center
        txt.textColor = .black
        txt.translatesAutoresizingMaskIntoConstraints = false
        return txt
    }()
    
    private let btn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Kaydet", for: .normal)
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(kaydetTapped), for: .touchUpInside)
        return btn
    }()
    
    
    @objc func kaydetTapped(){
        
        let name = txt1.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let power = txt2.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (name?.isEmpty)! {
            txt1.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if (power?.isEmpty)!{
            txt2.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt : OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        // Sorgunun Hazırlanması
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Parametleri bağlama
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("AD parametresi bağlanamadı kanka \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (power! as NSString).intValue) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Gücü bağlayamadın kanka \(errmsg)")
            return
        }
        
        // değerleri bağlamak için sorguyu bitiriyon
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print(errmsg)
            return
        }
        
        // textfieldları temizliyoruz
        txt1.text = ""
        txt2.text = ""
        
        print("Kaydedildi agam")
        
        readValues()
    }
    
    var db : OpaquePointer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        constrains()
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        
        // database dosyası
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroDatabase.sqlite")
        
        // databaseyi açıyor
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // tabloyu oluşturuyor
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT , powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table : \(errmsg)")
        }
        
        readValues()
    }
    
    func readValues(){
        
        // öncelikle öncekileri kaldırıyoruz
        heroList.removeAll()
        
        // sonra seçme sorgusunu yazıyom
        let queryString = "SELECT * FROM Heroes"
        
        var stmt : OpaquePointer?
        
        // sorguyu hazırla
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print(errmsg)
            return
        }
        
        // bütün kayıtları gezcez kanka şimdi
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let power = sqlite3_column_int(stmt, 2)
            
            // sonra listeye ekleme kaldı
            heroList.append(Hero(id: Int(id), name: String(describing: name), power: Int(power)))
        }
        
        self.table.reloadData()
    }
    
    
    func constrains(){
        view.addSubview(txt1)
        view.addSubview(txt2)
        view.addSubview(btn)
        view.addSubview(table)
        
        txt1.topAnchor.constraint(equalTo: view.topAnchor , constant: 100).isActive = true
        txt1.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 50).isActive = true
        txt1.trailingAnchor.constraint(equalTo: view.trailingAnchor , constant: -50).isActive = true
        txt1.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        txt2.topAnchor.constraint(equalTo: txt1.bottomAnchor , constant: 25).isActive = true
        txt2.leadingAnchor.constraint(equalTo: txt1.leadingAnchor).isActive = true
        txt2.trailingAnchor.constraint(equalTo: txt1.trailingAnchor).isActive = true
        txt2.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        btn.topAnchor.constraint(equalTo: txt2.bottomAnchor , constant: 25).isActive = true
        btn.leadingAnchor.constraint(equalTo: txt2.leadingAnchor).isActive = true
        btn.trailingAnchor.constraint(equalTo: txt2.trailingAnchor).isActive = true
        
        table.topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 30).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }


}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let hero : Hero
        hero = heroList[indexPath.row]
        cell.textLabel?.text = hero.name
        return cell
    }
    

}
