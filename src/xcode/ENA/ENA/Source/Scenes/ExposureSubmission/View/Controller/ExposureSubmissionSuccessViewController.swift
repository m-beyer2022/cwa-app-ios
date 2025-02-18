//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionSuccessViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	
	// MARK: - Init
	
	init(
		submissionTestType: SubmissionTestType,
		dismiss: @escaping () -> Void
	) {
		self.submissionTestType = submissionTestType
		self.dismiss = dismiss
		
		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .background)
		title = AppStrings.ExposureSubmissionSuccess.title
		
		setupTableView()

		navigationItem.hidesBackButton = true
		
		footerView?.primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionSuccess.closeButton
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		footerView?.isHidden = false
	}
	
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		self.dismiss()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		
	}
	
	// MARK: - Private

	private let submissionTestType: SubmissionTestType
	private let dismiss: () -> Void
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionSuccess.button
		item.isPrimaryButtonEnabled = true
		item.isPrimaryButtonHidden = false
		item.isSecondaryButtonEnabled = false
		item.isSecondaryButtonHidden = true
		item.title = AppStrings.ExposureSubmissionSuccess.title
		return item
	}()
	
	// swiftlint:disable:next function_body_length
	private func setupTableView() {
		tableView.separatorStyle = .none
		
		tableView.register(ExposureSubmissionStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		
		var cells: [DynamicCell] = [
			.body(
				text: AppStrings.ExposureSubmissionSuccess.description,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.description
			),
			.title2(
				text: AppStrings.ExposureSubmissionSuccess.listTitle,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.listTitle
			)
		]
		
		switch submissionTestType {
		case .registeredTest(let coronaTestType):
			switch coronaTestType {
			case .pcr:
				cells.append(contentsOf: [
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemPCR0,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.PCR.firstBulletPoint,
						icon: UIImage(named: "Icons - Home"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemPCR1,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.PCR.secondBulletPoint,
						icon: UIImage(named: "Icons - ContactJournal"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemPCR2,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.PCR.thirdBulletPoint,
						icon: UIImage(named: "Icons - Hotline"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemPCR3,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.PCR.fourthBulletPoint,
						icon: UIImage(named: "Icons - Red Plus"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					)
				])
			case .antigen:
				cells.append(contentsOf: [
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemRAT0,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.RAT.firstBulletPoint,
						icon: UIImage(named: "Icons - Home"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemRAT1,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.RAT.secondBulletPoint,
						icon: UIImage(named: "Icons - ContactJournal"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemRAT2,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.RAT.thirdBulletPoint,
						icon: UIImage(named: "Icons - Test Tube"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionSuccess.listItemRAT3,
						accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.RAT.fourthBulletPoint,
						icon: UIImage(named: "Icons - Hotline"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .medium
					)
				])
			case .none:
				break
			}
		case .srs:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItemSRS0,
					accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.SRS.firstBulletPoint,
					icon: UIImage(named: "Icons - Home"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItemSRS1,
					accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.SRS.secondBulletPoint,
					icon: UIImage(named: "Icons - ContactJournal"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItemSRS2,
					accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.SRS.thirdBulletPoint,
					icon: UIImage(named: "Icons - Test Tube"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItemSRS3,
					accessibilityIdentifier: AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.SRS.fourthBulletPoint,
					icon: UIImage(named: "Icons - Hotline"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				)
			])
		}
		
		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionSuccess.subTitle,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.subTitle
			),
			.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_1, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_2, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_3, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_4, spacing: .large)
		])

		dynamicTableViewModel = DynamicTableViewModel(
			[
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_VielenDank"),
						accessibilityLabel: AppStrings.ExposureSubmissionSuccess.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription
					),
					separators: .none,
					cells: cells
				)
			]
		)
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionSuccessViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
