//
//  TableViewController.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/11/24.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource {
    private var tableView: UITableView!
    var data: [(color: UIColor, value: Float)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the table view
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(ColorValueCell.self, forCellReuseIdentifier: ColorValueCell.identifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.widthAnchor.constraint(equalToConstant: 200),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorValueCell.identifier, for: indexPath) as? ColorValueCell else {
            return UITableViewCell()
        }
        let item = data[indexPath.row]
        cell.configure(with: item.color, value: item.value)
        return cell
    }

    func updateData(_ data: [(color: UIColor, value: Float)]) {
        self.data = data
        tableView.reloadData()
    }
}

import UIKit

class ColorValueCell: UITableViewCell {
    static let identifier = "ColorValueCell"

    let colorView = UIView()
    let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Color view setup
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.heightAnchor.constraint(equalToConstant: 24)
        ])
        colorView.layer.cornerRadius = 12

        // Label setup
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        valueLabel.textColor = .black
        backgroundColor = .clear
    }

    func configure(with color: UIColor, value: Float) {
        colorView.backgroundColor = color
        valueLabel.text = String(value)
    }
}
