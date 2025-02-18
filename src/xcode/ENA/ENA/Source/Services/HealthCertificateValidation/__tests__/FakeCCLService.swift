//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import jsonfunctions
import OpenCombine

@testable import ENA
import class CertLogic.Rule

class FakeCCLService: CCLServable {

	// MARK: - Protocol CCLServable

	var shouldShowNoticeTile = CurrentValueSubject<Bool, Never>(false)
	
	var configurationVersion: String = "configurationVersion"

	var dccAdmissionCheckScenariosEnabled: Bool = false
	
	func updateConfiguration(completion: (Bool) -> Void) {
		completion(didChange)
	}

	func dccWalletInfo(for certificates: [DCCWalletCertificate], with identifier: String?) -> Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		return dccWalletInfoResult
	}
	
	func statusTabNotice() -> Swift.Result<StatusTabNotice, StatusTabNoticeAccessError> {
		return statusTabNoticeResult
	}

	func dccAdmissionCheckScenarios() -> Swift.Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError> {
		return dccAdmissionCheckScenariosResult
	}
	
	func evaluateFunctionWithDefaultValues<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T {
		guard let castedType = functionEvaluationResult as? T else {
			Log.info("Cast to T type failed")
			throw  jsonfunctions.ParseError.GenericError("Test failed to cast to type T")
		}
		return castedType
	}

	// MARK: - Internal

	var didChange: Bool = false
	var dccWalletInfoResult: Result<DCCWalletInfo, DCCWalletInfoAccessError> = .success(DCCWalletInfo.fake())
	var dccAdmissionCheckScenariosResult: Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError> = .success(DCCAdmissionCheckScenarios.fake())
	var statusTabNoticeResult: Result<StatusTabNotice, StatusTabNoticeAccessError> = .success(StatusTabNotice.fake())
	var functionEvaluationResult: Any?

}
