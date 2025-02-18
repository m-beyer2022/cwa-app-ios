////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMSRSOptionsViewModel {
	
	// MARK: - Init
	
	init(
		store: Store
	) {
		self.store = store
	}
	
	// MARK: - Internal

	var refreshTableView: (IndexSet) -> Void = { _ in }
	
	var numberOfSections: Int {
		TableViewSections.allCases.count
	}
	
	func numberOfRows(in section: Int) -> Int {
		guard TableViewSections.allCases.indices.contains(section) else {
			return 0
		}
		// at the moment we assume one cell per section only
		return 1
	}
	
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}
		
		switch section {
		case .preChecks:
			return DMSwitchCellViewModel(
				labelText: "Enable pre-checks for SRS",
				isOn: { [store] in
					return store.isSrsPrechecksEnabled
				},
				toggle: { [store] in
					store.isSrsPrechecksEnabled.toggle()
				})
		case .srsStateValues:
			return DMStaticTextCellViewModel(
				staticText: srsStateValueStaticText(),
				font: .enaFont(for: .footnote),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .apiToken:
			return DMStaticTextCellViewModel(
				staticText: apiTokenStaticText(),
				font: .enaFont(for: .footnote),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .resetMostRecentKeySubmission:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.mostRecentKeySubmissionDate = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				}
			)
		case .resetSRSStateValues:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.mostRecentKeySubmissionDate = nil
					store.otpTokenSrs = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				}
			)
		case .restApiTokenPPAC:
			return DMButtonCellViewModel(
				text: "Reset API Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.apiTokenPPAC = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				}
			)
		}
	}

	// MARK: - Private

	private let store: Store
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
		return dateFormatter
	}()
	
	private func srsStateValueStaticText() -> String {
		"""

		Most Recent Key Submission Date
		\(createDateString(from: store.mostRecentKeySubmissionDate))

		SRS OTP Token
		\(store.otpTokenSrs?.token ?? "No OTP Token set yet")

		SRS OTP Token Expiration Date
		\(createDateString(from: store.otpTokenSrs?.expirationDate))

		"""
	}
	
	private func apiTokenStaticText() -> String {
	   """
	   
	   [DEPRECATED] API Token EDUS
	   \(store.ppacApiTokenEdus?.token ?? "No Existing EDUS API Token in the store")
	   
	   [DEPRECATED] API Token ELS
	   \(store.ppacApiTokenEls?.token ?? "No Existing ELS API Token in the store")

	   PPAC API Token
	   \(store.apiTokenPPAC?.token ?? "No API Token generated yet")
	   
	   PPAC API Token Creation Date
	   \(createDateString(from: store.apiTokenPPAC?.timestamp))
	   
	   Previous PPAC API Token
	   \(store.previousAPITokenPPAC?.token ?? "No API Token available")
	   
	   Previous PPAC API Token Creation Date
	   \(createDateString(from: store.previousAPITokenPPAC?.timestamp, fallback: "No Date available"))
	   
	   """
	}
	
	private func createDateString(
		from date: Date?,
		fallback: String = "No Date set yet"
	) -> String {
		if let date = date {
			return dateFormatter.string(from: date)
		} else {
			return fallback
		}
	}
}

extension DMSRSOptionsViewModel {
	enum TableViewSections: Int, CaseIterable {
		case preChecks
		case srsStateValues
		case apiToken
		case resetMostRecentKeySubmission
		case resetSRSStateValues
		case restApiTokenPPAC
		
		var sectionTitle: String {
			switch self {
			case .preChecks:
				return "SRS Prerequisites"
			case .srsStateValues:
				return "SRS State Values"
			case .apiToken:
				return "API Token"
			case .resetMostRecentKeySubmission:
				return "Most Recent Key Submission"
			case .resetSRSStateValues:
				return "All SRS State Values"
			case .restApiTokenPPAC:
				return "Rest API Token"
			}
		}
	}
}

#endif
