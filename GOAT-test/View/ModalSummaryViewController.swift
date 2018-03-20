//
//  ModalSummaryViewController.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

class ModalSummaryViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    var viewModel: BaseViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else { return }

        dateLabel.text = viewModel.dateTimeString
        forecastLabel.text = viewModel.temperatureString
        summaryTextView.text = viewModel.summary
    }
}
