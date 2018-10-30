//
//  AppDelegate.swift
//  Weather App
//
//  Created by Anastasia Veremiichyk on 10/26/18.
//  Copyright © 2018 Anastasia Veremiichyk. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().setBackgroundImage((UIImage(named: "cityListBackground.jpg")!), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func getDocumentsDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        let appName: String = "DataModel"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        let storeUrl = self.getDocumentsDirectory().appendingPathComponent("DataModel.sqlite")
        
        if !FileManager.default.fileExists(atPath: (storeUrl.path)) {
            if let seededDataUrl = Bundle.main.url(forResource: appName, withExtension: "sqlite") {
                try! FileManager.default.copyItem(at: seededDataUrl, to: storeUrl)
            }
        }
        let description = NSPersistentStoreDescription()
        
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
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
}
