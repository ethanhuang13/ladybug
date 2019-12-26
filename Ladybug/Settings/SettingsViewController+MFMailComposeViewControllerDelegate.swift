//
//  SettingsViewController+MFMailComposeViewControllerDelegate.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/23.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import MessageUI

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func presentOptionsActionSheet() {
        let optionsAlert = UIAlertController(title: "Select a Feedback Option".localized(), message: nil, preferredStyle: .actionSheet)
        optionsAlert.addAction(UIAlertAction(title: "Send Email".localized(), style: .default, handler:
            { _ in
                self.presentFeedbackMailComposer()
        }))
        optionsAlert.addAction(UIAlertAction(title: "Submit GitHub Issue".localized(), style: .default, handler:
            { _ in
                UIApplication.shared.open(AppConstants.githubIssueURL, options: SharedUtils.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        optionsAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        self.present(optionsAlert, animated: true, completion: nil)
    }
    
    func presentFeedbackMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: "Setup iOS Mail".localized(), message: "Setup iOS Mail accounts first, or...".localized(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let vc = MFMailComposeViewController()
        vc.setToRecipients([AppConstants.feedbackEmail])
        vc.setSubject("[Ladybug Feedback]")
        vc.setMessageBody("Hello Developer,\n\n\n\n\n\n\(AppConstants.aboutString)", isHTML: false)
        vc.mailComposeDelegate = self
        self.present(vc, animated: true, completion: { })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { }
    }
}
