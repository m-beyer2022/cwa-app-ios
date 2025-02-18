//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable

enum MaskStateIdentifier: String, Codable {

	case maskRequired = "MASK_REQUIRED"
	case maskOptional = "MASK_OPTIONAL"
	case other = "OTHER"

}

struct StatusTabNotice: Codable, Equatable {

	let visible: Bool
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCWalletInfo: Codable, Equatable {

	var admissionState: DCCAdmissionState
	var vaccinationState: DCCVaccinationState
	let maskState: DCCMaskState?
	let boosterNotification: DCCBoosterNotification
	let mostRelevantCertificate: DCCCertificateContainer
	let verification: DCCVerification
	let validUntil: Date?
	var certificateReissuance: DCCCertificateReissuance?
	let certificatesRevokedByInvalidationRules: [DCCCertificateContainer]?

}

struct DCCAdmissionCheckScenarios: Codable, Equatable {
	
	let labelText: DCCUIText
	let scenarioSelection: DCCScenarioSelection

}

struct DCCScenarioSelection: Codable, Equatable {
	
	let titleText: DCCUIText
	let items: [DCCScenarioSelectionItem]

}

struct DCCScenarioSelectionItem: Codable, Equatable {
	
	let identifier: String
	let titleText: DCCUIText
	let subtitleText: DCCUIText?
	let enabled: Bool

}

struct DCCAdmissionState: Codable, Equatable {

	let identifier: String?
	var visible: Bool
	let badgeText: DCCUIText?
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let stateChangeNotificationText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}


struct DCCVaccinationState: Codable, Equatable {

	var visible: Bool
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCMaskState: Codable, Equatable {

	let visible: Bool
	let badgeText: DCCUIText?
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?
	let identifier: MaskStateIdentifier

}

struct DCCBoosterNotification: Codable, Equatable {

	let visible: Bool
	let identifier: String?
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCCertificateContainer: Codable, Equatable {

	let certificateRef: DCCCertificateReference

 }

struct DCCReissuanceCertificateContainer: Codable, Equatable {

	let certificateToReissue: DCCCertificateContainer
	let accompanyingCertificates: [DCCCertificateContainer]
	let action: String

}

struct DCCVerification: Codable, Equatable {

	let certificates: [DCCVerificationCertificate]

}

struct DCCVerificationCertificate: Codable, Equatable {

	let buttonText: DCCUIText
	let certificateRef: DCCCertificateReference

}

struct DCCCertificateReference: Codable, Equatable {

	let barcodeData: String?

}

struct DCCCertificateReissuance: Codable, Equatable {

	var reissuanceDivision: DCCCertificateReissuanceDivision
	// legacy from CCL config-v2 - needed for backward compatibility
	let certificateToReissue: DCCCertificateContainer?
	// legacy from CCL config-v2 - needed for backward compatibility
	let accompanyingCertificates: [DCCCertificateContainer]?
	let certificates: [DCCReissuanceCertificateContainer]?

}

struct DCCCertificateReissuanceDivision: Codable, Equatable {

	var visible: Bool
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?
	let identifier: String?
	let listTitleText: DCCUIText?
	let consentSubtitleText: DCCUIText?

}
