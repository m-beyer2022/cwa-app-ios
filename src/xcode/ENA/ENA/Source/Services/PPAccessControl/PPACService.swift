////
// 🦠 Corona-Warn-App
//

import Foundation

protocol PrivacyPreservingAccessControl {
	func getPPACTokenEDUS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void)
	func getAPITokenPPAC(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void)
	func checkSRSFlowPrerequisites(
		minTimeSinceOnboardingInHours: Int,
		minTimeBetweenSubmissionsInDays: Int,
		completion: @escaping (Result<Void, SRSPreconditionError>) -> Void
	)
	#if !RELEASE
	func generateNewAPITokenPPAC() -> TimestampedToken
	#endif
}

class PPACService: PrivacyPreservingAccessControl {

	// MARK: - Init

	init(
		store: Store,
		deviceCheck: DeviceCheckable
	) {
		self.store = store
		self.deviceCheck = deviceCheck
	}

	// MARK: - Protocol PrivacyPreservingAccessControl

	func checkSRSFlowPrerequisites(
		minTimeSinceOnboardingInHours: Int,
		minTimeBetweenSubmissionsInDays: Int,
		completion: @escaping (Result<Void, SRSPreconditionError>) -> Void
	) {
		#if !RELEASE
		if !store.isSrsPrechecksEnabled {
			Log.warning("SRS pre-checks disabled!")
			completion(.success(()))
			return
		}
		#endif

		// check if time isn't incorrect
		if store.deviceTimeCheckResult == .incorrect {
			Log.error("SRSError: device time is incorrect", log: .ppac)
			completion(.failure(.deviceTimeError(.timeIncorrect)))
			return
		}
		
		// check if time isn't unknown
		if store.deviceTimeCheckResult == .assumedCorrect {
			Log.error("SRSError: device time is unverified", log: .ppac)
			completion(.failure(.deviceTimeError(.timeUnverified)))
			return
		}
		
		// we have two parameters from the appconfig for pre-checks:
		// 1- a minimum number of hours since onboarding until user can self submit result.
		// 2- a minimum number of days since last submission user can self submit result again.
		
		// 1- Check FIRST_RELIABLE_TIMESTAMP
		if let appInstallationDate = store.appInstallationDate,
		   let difference = Calendar.current.dateComponents([.hour], from: appInstallationDate, to: Date()).hour {
			let minTimeSinceOnboarding = minTimeSinceOnboardingInHours <= 0 ? 24 : minTimeSinceOnboardingInHours
			Log.debug("Device time last state change: \(store.deviceTimeLastStateChange)")
			Log.debug("First reliable time stamp: \(String(describing: store.firstReliableTimeStamp))")
			Log.debug("App installation date: \(appInstallationDate)")
			Log.debug("Actual time since onboarding: \(minTimeSinceOnboardingInHours) hours.", log: .ppac)
			Log.debug("Corrected default time since onboarding: \(minTimeSinceOnboarding) hours.", log: .ppac)
			
			if difference <= minTimeSinceOnboarding {
				Log.error("SRSError: too short time since onboarding", log: .ppac)
				
				// Default is 1 to avoid texts like "wait for 0 hours" ...
				var timeStillToWaitInHours = 1
				
				// Remaining time when fresh app installation
				if difference == 0 {
					timeStillToWaitInHours = minTimeSinceOnboarding
				}
				// Remaining time, also if calculated remaining time is 0 hours
				else if difference == minTimeSinceOnboarding {
					timeStillToWaitInHours = 1
				}
				// Remaining time
				else {
					timeStillToWaitInHours = minTimeSinceOnboarding - difference
				}

				completion(
					.failure(
						.insufficientAppUsageTime(
							timeSinceOnboardingInHours: minTimeSinceOnboarding,
							timeStillToWaitInHours: timeStillToWaitInHours
						)
					)
				)
				return
			}
		}
		
		// 2- Check time since previous submission
		if let mostRecentKeySubmissionDate = store.mostRecentKeySubmissionDate,
		   let difference = Calendar.current.dateComponents([.day], from: mostRecentKeySubmissionDate, to: Date()).day {
			let minTimeBetweenSubmissions = minTimeBetweenSubmissionsInDays <= 0 ? 90 : minTimeBetweenSubmissionsInDays
			Log.debug("minTimeBetweenSubmissionsInDays = \(minTimeBetweenSubmissionsInDays) days.", log: .ppac)
			Log.debug("Corrected default minTimeBetweenSubmissionsInDays = \(minTimeBetweenSubmissions) days.", log: .ppac)
			
			if difference < minTimeBetweenSubmissions {
				Log.error("SRSError: submission too early", log: .ppac)
				completion(.failure(
					.positiveTestResultWasAlreadySubmittedWithinThreshold(
						timeBetweenSubmissionsInDays: minTimeBetweenSubmissionsInDays
					)
				))
				return
			}
		}
		completion(.success(()))
	}

	func getPPACTokenEDUS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {

		// check if time isn't incorrect
		if store.deviceTimeCheckResult == .incorrect {
			Log.error("device time is incorrect", log: .ppac)
			completion(.failure(PPACError.timeIncorrect))
			return
		}

		// check if time isn't unknown
		if store.deviceTimeCheckResult == .assumedCorrect {
			Log.error("device time is unverified", log: .ppac)
			completion(.failure(PPACError.timeUnverified))
			return
		}

		// check if device supports DeviceCheck
		guard deviceCheck.isSupported else {
			Log.error("device token not supported", log: .ppac)
			completion(.failure(PPACError.deviceNotSupported))
			return
		}

		deviceCheck.deviceToken(
			apiToken: apiTokenPPAC.token,
			previousApiToken: store.previousAPITokenPPAC?.token,
			completion: completion
		)
	}
	
	func getAPITokenPPAC(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		// no device time checks for ELS
		deviceCheck.deviceToken(
			apiToken: apiTokenPPAC.token,
			previousApiToken: store.previousAPITokenPPAC?.token,
			completion: completion
		)
	}

	#if !RELEASE
	// needed to make it possible to get called from the developer menu
	func generateNewAPITokenPPAC() -> TimestampedToken {
		let token = generateAndStoreFreshAPIToken()
		store.apiTokenPPAC = token
		return token
	}
	#endif

	// MARK: - Private

	private let deviceCheck: DeviceCheckable
	private let store: Store

	/// will return the current API Token and create a new one if needed
	private var apiTokenPPAC: TimestampedToken {
		let today = Date()
		/// check if we already have a token and if it was created in this month / year
		guard let storedToken = store.apiTokenPPAC,
			  storedToken.timestamp.isEqual(to: today, toGranularity: .month),
			  storedToken.timestamp.isEqual(to: today, toGranularity: .year)
		else {
            store.previousAPITokenPPAC = store.apiTokenPPAC
			let newToken = generateAndStoreFreshAPIToken()
			store.apiTokenPPAC = newToken
			return newToken
		}
		Log.info("fetched existing valid API token: \(private: storedToken)", log: .ppac)
		
		return storedToken
	}

	/// generate a new API Token and store it
	private func generateAndStoreFreshAPIToken() -> TimestampedToken {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)

		Log.info("Generated new API token: \(private: token)", log: .ppac)
		return token
	}
}
