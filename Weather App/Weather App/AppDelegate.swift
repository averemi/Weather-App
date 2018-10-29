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
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
        
        UINavigationBar.appearance().setBackgroundImage((UIImage(named: "cityListBackground.jpg")!), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        setStatusBarBackgroundColor()
        
        
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
      //  UINavigationBar.appearance().shadowImage = UIImage()
   //     UINavigationBar.appearance().backgroundColor = .clear
   //     UINavigationBar.appearance().isTranslucent = true
        
    /*    UINavigationBar.appearance().setBackgroundImage((UIImage(named: "cityListBackground.jpg")!), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true*/
        return true
    }
    
    func setStatusBarBackgroundColor() {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = UIColor(patternImage: UIImage(named: "cityListBackground.jpg")!)
        
    }


    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
 /*   lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        return container
    }()*/
    /*
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            let sourceSqliteURLs = [NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite")!, NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite-wal")!, NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite-shm")!]
            
            let destSqliteURLs = [self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite"),
                                  self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite-wal"),
                                  self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite-shm")]
            
            var error:NSError? = nil
            for index in 0..< sourceSqliteURLs.count {
                NSFileManager.defaultManager().copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index], error: &error)
            }
        }
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()*/
    
    func getDocumentsDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        
        let appName: String = "DataModel"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let storeUrl = self.getDocumentsDirectory().appendingPathComponent("DataModel.sqlite")
        
        if !FileManager.default.fileExists(atPath: (storeUrl.path)) {
            let seededDataUrl = Bundle.main.url(forResource: appName, withExtension: "sqlite")
            try! FileManager.default.copyItem(at: seededDataUrl!, to: storeUrl)
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
        
    /*
    
        - (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    /* ... */
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Foobar.sqlite"];
    NSLog(@"CoreData Location: %@", storeURL);
    */
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


}

