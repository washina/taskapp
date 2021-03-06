//
//  ViewController.swift
//  taskapp
//
//  Created by YutaIwashina on 2017/04/10.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import ChameleonFramework           // 色関連のライブラリ

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /* デザイン変更処理 --------------------------------------------------------------------------------*/
    // cellのデザイン変更
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        // cell背景色
        cell.backgroundColor = ContrastColorOf(UINavigationBar.appearance().barTintColor!, returnFlat: true)
        // cellテキスト色
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.detailTextLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        // cell境界線
        tableView.separatorColor = UIColor.flatGrayDark

    }
    /* デザイン変更処理 end-----------------------------------------------------------------------------*/
    
    /* cell登録表示処理 -------------------------------------------------------------------------------*/
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // cell表示内容
    var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)

    // カテゴリの絞り込み処理
    @IBAction func searchButton(_ sender: Any) {
        // 文字が入力された上でボタンが押されれば処理開始
        if searchTextField.text != "" {
            // 検索のUITextFieldに入力された文字とカテゴリ名が一致するTaskを調べる
            let predicate = NSPredicate(format: "category CONTAINS %@",searchTextField.text!)
            let resultArray = realm.objects(Task.self).filter(predicate).sorted(byProperty: "date", ascending: false)
            print(resultArray)
            taskArray = resultArray
            tableView.reloadData()
        } else {
            // 空白処理
            taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Deleteボタンが押されたときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/------------")
                    print(request)
                    print("------------/")
                }
            }
        }
    }
    /* cell表示登録処理 end----------------------------------------------------------------------------*/
    
    /* 画面遷移 --------------------------------------------------------------------------------------*/
    // segueで画面遷移したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきたときに、TableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    /* 画面遷移 end-----------------------------------------------------------------------------------*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // searchTextFieldのcaret色変更
        searchTextField.tintColor = UIColor.flatGrayDark
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

