//
//  AnazyleView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 11.07.2025.
//

import UIKit
import SwiftUI
import PieChart

final class AnalyzeViewController: UITableViewController {
    private var pieChartView: PieChartView!
    private var transactions: [TransactionResponse] = []
    private var pieChartContainer = UIView()
    private var startDate = Date().addingTimeInterval(-86400 * 7)
    private var endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: .now) ?? .now
    private var totalAmount: Decimal = 0
    private let filtersSection = 0
    private let chartSection = 1
    private let transactionsSection = 2
    private var sortOrder: TransactionSortOrder = .amountAscending
    weak var coordinator: AnalyzeCoordinator?
    var direction: Direction = .income
    var service: TransactionService = TransactionService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPieChart()
        loadTransactions()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == transactionsSection else { return }
        
        let transaction = transactions[indexPath.row]
        coordinator?.selectedTransaction = transaction
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func setupTableView() {
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.reuseId)
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCell.reuseId)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseId)
        tableView.register(PickerCell.self, forCellReuseIdentifier: PickerCell.reuseId)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadTransactions), for: .valueChanged)
        tableView.allowsSelection = true
    }
    
    private func sortTransactions() {
        transactions.sort {
            switch sortOrder {
            case .dateAscending:
                return $0.transactionDate < $1.transactionDate
            case .dateDescending:
                return $0.transactionDate > $1.transactionDate
            case .amountAscending:
                return $0.amount < $1.amount
            case .amountDescending:
                return $0.amount > $1.amount
            }
        }
    }
    
    @objc func loadTransactions() {
        Task {
            do {
                let account = try await BankAccountService().bankAccount()
                let mockTransactions = try await service.transactions(accountId: account.id, startDate: startDate, endDate: endDate)
                
                transactions = mockTransactions.filter { $0.category.direction == direction }
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
                
                updateChartData()
                
                tableView.reloadData()
                tableView.refreshControl?.endRefreshing()
            } catch {
                print("error loading transactions: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupPieChart() {
        pieChartView = PieChartView()
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        pieChartView.isHidden = true
        pieChartView.backgroundColor = .clear

    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 20
        }
        return 0.1
    }
    
    private func updateChartData() {
        let entities = transactions
            .reduce(into: [String: Decimal]()) { result, transaction in
                result[transaction.category.name, default: 0] += transaction.amount
            }
            .map { Entity(value: $0.value, label: $0.key) }
        
        if pieChartView.isHidden {
            pieChartView.entities = entities
            pieChartView.isHidden = entities.isEmpty
        } else {
            pieChartView.animateToNewData(entities, duration: 0.8)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == chartSection {
            return 220
        }
        return UITableView.automaticDimension
    }
    
}

extension AnalyzeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        case 2: return transactions.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Операции"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == chartSection {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .clear
            
            cell.isUserInteractionEnabled = false
            
            cell.contentView.addSubview(pieChartView)
            
            NSLayoutConstraint.activate([
                pieChartView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                pieChartView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
                pieChartView.widthAnchor.constraint(equalToConstant: 220),
                pieChartView.heightAnchor.constraint(equalToConstant: 220),
                pieChartView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4)
            ])
            
            return cell
        }
        else if indexPath.section == filtersSection {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.reuseId, for: indexPath) as! DatePickerCell
                cell.configure(title: "Период: начало", date: startDate) { [weak self] newDate in
                    guard let self else { return }
                    startDate = newDate
                    if startDate > endDate {
                        endDate = startDate
                        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                    loadTransactions()
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.reuseId, for: indexPath) as! DatePickerCell
                cell.configure (
                    title: "Период: конец",
                    date: endDate
                ) { [weak self] newDate in
                    guard let self else { return }
                    endDate = newDate
                    if endDate < startDate {
                        startDate = endDate
                        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                    loadTransactions()
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: PickerCell.reuseId, for: indexPath) as! PickerCell
                cell.configure(
                    title: "Сортировка",
                    sortOrder: self.sortOrder
                ) { [weak self] newOrder in
                    self?.sortOrder = newOrder
                    self?.sortTransactions()
                    tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.reuseId, for: indexPath) as! TextCell
                cell.configure(
                    title: "Сумма",
                    value: totalAmount
                        .formatted(
                            .currency(code: transactions.first?.account.currency ?? "RUB")
                            .presentation(.narrow)
                            .precision(.fractionLength(0...2))
                        )
                )
                return cell
            default:
                fatalError("Unexpected row")
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseId, for: indexPath) as! TransactionCell
            let transaction = transactions[indexPath.row]
            let percent = (transaction.amount / totalAmount)
            cell.configure(
                emoji: transaction.category.emoji,
                title: transaction.category.name,
                comment: transaction.comment ?? "",
                amount: transaction.amount.formatted(
                    .currency(code: transactions.first?.account.currency ?? "RUB")
                    .presentation(.narrow)
                    .precision(.fractionLength(0...2))
                ),
                percentage: percent.formatted(.percent.precision(.fractionLength(0...2))),
            )
            return cell
        }
    }
}

final class DatePickerCell: UITableViewCell {
    static let reuseId = "DatePickerCell"
    private var onDateChanged: ((Date) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        picker.maximumDate = Date()
        picker.tintColor = .accent
        
        return picker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(datePicker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: datePicker.leadingAnchor, constant: -8),
            
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, date: Date, onDateChanged: @escaping (Date) -> Void) {
        titleLabel.text = title
        datePicker.date = date
        self.onDateChanged = onDateChanged
    }
    
    @objc private func dateChanged() {
        onDateChanged?(datePicker.date)
    }
}

final class TextCell: UITableViewCell {
    static let reuseId = "TextCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, value: String) {
        textLabel?.text = title
        detailTextLabel?.text = value
    }
}

final class PickerCell: UITableViewCell {
    static let reuseId = "PickerCell"
    
    private var onSelectionChanged: ((Int) -> Void)?
    private var options: [String] = []
    private var selectedIndex: Int = 0
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выбрать", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        button.sizeToFit()
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryView = menuButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        title: String,
        sortOrder: TransactionSortOrder,
        onSelectionChanged: @escaping (TransactionSortOrder) -> Void
    ) {
        textLabel?.text = title
        self.options = TransactionSortOrder.allCases.map { $0.rawValue }
        
        let selected = TransactionSortOrder.allCases.firstIndex(of: sortOrder) ?? 0
        self.selectedIndex = selected
        
        menuButton.setTitle(options[selected], for: .normal)
        
        self.onSelectionChanged = { index in
            onSelectionChanged(TransactionSortOrder.allCases[index])
        }
        
        menuButton.setTitle(options[selected], for: .focused)
        menuButton.tintColor = .secondaryLabel
        menuButton.sizeToFit()
        accessoryView = menuButton
        
        
        menuButton.menu = UIMenu(children: options.enumerated().map { index, option in
            UIAction(title: option, state: index == selected ? .on : .off) { [weak self] _ in
                self?.selectedIndex = index
                self?.menuButton.setTitle(option, for: .normal)
                self?.onSelectionChanged?(index)
                self?.updateMenuSelection()
            }
        })
    }
    
    private func updateMenuSelection() {
        guard menuButton.menu != nil else { return }
        let updatedMenu = UIMenu(children: options.enumerated().map { index, option in
            UIAction(title: option, state: index == selectedIndex ? .on : .off) { [weak self] _ in
                self?.selectedIndex = index
                self?.menuButton.setTitle(option, for: .normal)
                self?.onSelectionChanged?(index)
                self?.updateMenuSelection()
            }
        })
        menuButton.menu = updatedMenu
    }
}


extension PickerCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onSelectionChanged?(row)
    }
}

final class TransactionCell: UITableViewCell {
    static let reuseId = "TransactionCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .transactionIconBackground
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        iconContainer.addSubview(iconLabel)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.widthAnchor.constraint(equalToConstant: 22),
            iconLabel.heightAnchor.constraint(equalToConstant: 22),
            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
        ])
        
        let tittleStack = UIStackView(arrangedSubviews: [titleLabel, commentLabel])
        tittleStack.axis = .vertical
        tittleStack.spacing = 4
        
        let numberStack = UIStackView(arrangedSubviews: [percentageLabel, amountLabel])
        numberStack.axis = .vertical
        numberStack.spacing = 4
        numberStack.alignment = .trailing
        
        let mainStack = UIStackView(arrangedSubviews: [iconContainer, tittleStack, UIView(), numberStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainer.widthAnchor.constraint(equalToConstant: 24),
            iconContainer.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(emoji: Character, title: String, comment: String, amount: String, percentage: String) {
        iconLabel.text = String(emoji)
        titleLabel.text = title
        commentLabel.text = comment
        amountLabel.text = amount
        percentageLabel.text = "\(percentage)"
    }
}

protocol AnalyzeViewControllerDelegate: AnyObject {
    func didSelectTransaction(_ transaction: TransactionResponse)
}

struct AnalyzeView: UIViewControllerRepresentable {
    let direction: Direction
    let service: TransactionService
    let coordinator: AnalyzeCoordinator
    
    func makeUIViewController(context: Context) -> AnalyzeViewController {
        let controller = AnalyzeViewController(style: .insetGrouped)
        controller.direction = direction
        controller.service = service
        controller.coordinator = coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AnalyzeViewController, context: Context) {
        uiViewController.direction = direction
        uiViewController.service = service
    }
}

extension AnalyzeView {
    func edgesIgnoringSafeArea() -> some View {
        if #available(iOS 14.0, *) {
            return self.ignoresSafeArea()
        } else {
            return self.edgesIgnoringSafeArea(.all)
        }
    }
}
