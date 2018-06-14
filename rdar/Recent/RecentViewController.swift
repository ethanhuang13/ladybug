//
//  RecentViewController.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import SafariServices

class RecentViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Recent".localized()

        RadarURLOpener.shared.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecentViewController: RadarURLOpenerUI {
    func openRadarInSafariViewController(_ radarID: RadarID, radarOption: RadarOption, readerMode: Bool) {
        // TODO: Prepend radarID to self.array

        let url = radarID.url(by: radarOption)
        presentSafariViewController(url: url, readerMode: readerMode)
    }

    func ask(completion: @escaping (Result<BrowserOption>) -> Void) {
        let alertController = UIAlertController(title: "Open In...".localized(), message: "Select browser/app to open".localized(), preferredStyle: .alert)

        let browserOptions: [BrowserOption] = [.sfvcReader, .safari, .briskApp]

        browserOptions.forEach { (browserOption) in
            if RadarURLOpener.shared.canOpen(in: browserOption) {
                alertController.addAction(UIAlertAction(title: browserOption.title, style: .default, handler: { (_) in
                    completion(.success(browserOption))
                }))
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (_) in
            completion(.error(RadarURLOpenerError.cancelled))
        }))

        present(alertController, animated: true, completion: nil)
    }

    private func presentSafariViewController(url: URL, readerMode: Bool) {
        let sfvc: SFSafariViewController = {
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.barCollapsingEnabled = false
                config.entersReaderIfAvailable = readerMode

                return SFSafariViewController(url: url, configuration: config)
            } else {
                return SFSafariViewController(url: url, entersReaderIfAvailable: readerMode)
            }
        }()

        sfvc.preferredBarTintColor = .barTintColor

        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(sfvc, animated: false, completion: nil)
            }
        } else {
            self.present(sfvc, animated: false, completion: nil)
        }
    }
}
