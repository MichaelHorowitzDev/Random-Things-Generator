//
//  MailView.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/12/21.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  private var toRecipients: [String]?
  private var messageBody: (body: String, isHTML: Bool)?
  private var subject: String = ""
  private var ccRecipients: [String]?
  private var bccRecipients: [String]?
  private var preferredSendingEmailAddress: String = ""
  private var attachmentData: (attachment: Data, mimeType: String, fileName: String)?
  private var errorResult: ((Result<MFMailComposeResult, Error>) -> Void)? = nil
  private var mailResult: ((MailResult) -> Void)? = nil

  enum MailResult {
    case success, failure
  }
  func makeUIViewController(context: Context) -> MFMailComposeViewController {
    let mailView = MFMailComposeViewController()
    mailView.mailComposeDelegate = context.coordinator
    mailView.setToRecipients(toRecipients)
    if let messageBody = messageBody {
      mailView.setMessageBody(messageBody.body, isHTML: messageBody.isHTML)
    }
    mailView.setSubject(subject)
    mailView.setCcRecipients(ccRecipients)
    mailView.setBccRecipients(bccRecipients)
    mailView.setPreferredSendingEmailAddress(preferredSendingEmailAddress)
    if let attachmentData = attachmentData {
      mailView.addAttachmentData(attachmentData.attachment, mimeType: attachmentData.mimeType, fileName: attachmentData.fileName)
    }
    return mailView
  }
  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {

  }
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    let mailView: MailView
    init(_ mailView: MailView) {
      self.mailView = mailView
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      defer {
        mailView.presentationMode.wrappedValue.dismiss()
      }
      if let boolResult = mailView.mailResult {
        if error != nil {
          boolResult(.failure)
        } else {
          boolResult(.success)
        }
      } else if let mailResult = mailView.errorResult {
        if let error = error {
          mailResult(.failure(error))
        } else {
          mailResult(.success(result))
        }
      }
    }
  }
}

extension MailView {
  func setToRecipients(_ toRecipients: [String]?) -> Self {
    var copy = self
    copy.toRecipients = toRecipients
    return copy
  }
  func setMessageBody(_ body: String, isHTML: Bool) -> Self {
    var copy = self
    copy.messageBody = (body, isHTML)
    return copy
  }
  func setSubject(_ subject: String) -> Self {
    var copy = self
    copy.subject = subject
    return copy
  }
  func setCcRecipients(_ ccRecipients: [String]?) -> Self {
    var copy = self
    copy.ccRecipients = ccRecipients
    return copy
  }
  func setBccRecipients(_ bccRecipients: [String]?) -> Self {
    var copy = self
    copy.bccRecipients = bccRecipients
    return copy
  }
  func setPreferredSendingEmailAddress(_ emailAddress: String) -> Self {
    var copy = self
    copy.preferredSendingEmailAddress = emailAddress
    return copy
  }
  func addAttachmentData(_ attachment: Data, mimeType: String, fileName: String) -> Self {
    var copy = self
    copy.attachmentData = (attachment, mimeType, fileName)
    return copy
  }
  func errorResult(_ result: @escaping (Result<MFMailComposeResult, Error>) -> Void) -> Self {
    var copy = self
    copy.errorResult = result
    return copy
  }
  func mailResult(_ result: @escaping (MailResult) -> Void) -> Self {
    var copy = self
    copy.mailResult = result
    return copy
  }
}
