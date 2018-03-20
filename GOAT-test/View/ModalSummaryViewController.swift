//
//  ModalSummaryViewController.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

class ModalSummaryViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var summaryText: String?

    override func viewWillAppear(_ animated: Bool) {
        textView.text = summaryText
    }
}
