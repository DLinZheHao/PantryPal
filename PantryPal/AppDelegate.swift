//
//  AppDelegate.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/19.
//

import UIKit
import CoreData
import Firebase
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        //-- 注册推送
        let center = UNUserNotificationCenter.current()
        center.delegate = self as UNUserNotificationCenterDelegate
        center.getNotificationSettings { (setting) in
            if setting.authorizationStatus == .notDetermined {
                // 未注册
                center.requestAuthorization(options: [.badge,.sound,.alert]) { (result, error) in
                    print("显示内容：\(result) error：\(String(describing: error))")
                    if(result){
                        if !(error != nil){
                            print("注册成功了！")
                            DispatchQueue.main.async {
                                application.registerForRemoteNotifications()
                            }
                        }
                    } else{
                        print("用户不允许推送")
                    }
                }
            } else if (setting.authorizationStatus == .denied){
                //用户已经拒绝推送通知
                //-- 弹出页面提示用户去显示
                
            } else if (setting.authorizationStatus == .authorized){
                //已注册 已授权 --注册同志获取 token
                // 请求授权时异步进行的，这里需要在主线程进行通知的注册
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }else{
                // 其餘條件
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PantryPal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // 在前景收到通知時所觸發的 function
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("在前景收到通知...")
        completionHandler([.badge, .sound, .banner])
    }
}
