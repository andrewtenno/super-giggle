//
//  ForecastCell.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {
    @IBOutlet private weak var dateTimeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!

    var viewModel: BaseViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            dateTimeLabel.text = viewModel.dateTimeString
            temperatureLabel.text = viewModel.temperatureString
        }
    }
}
