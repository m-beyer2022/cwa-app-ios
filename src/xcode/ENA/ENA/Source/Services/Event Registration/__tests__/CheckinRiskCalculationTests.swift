////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// swiftlint:disable type_body_length
class CheckinRiskCalculationTests: CWATestCase {

	// For all the test scenarios, please consider the risk calculation parameters in the mocked app configuration.

	// 1 match with 10m overlap. Overlap time sum from all checkins is 10m.
	// Result: Low checkin risk. No day risk.
	func test_Szenario_1() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:40:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T09:50:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfLowDayRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .low ? $0 + 1 : $0
		}

		let numberOfLowCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .low ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfLowDayRisks, 0)
		XCTAssertEqual(numberOfLowCheckinRisks, 1)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 0)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 1)
	}

	// 1 match with 20m overlap. Overlap time sum from all checkins is 20m.
	// Result: High checkin risk. No day risk.
	func test_Szenario_2() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:40:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfHighDayRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .high ? $0 + 1 : $0
		}

		let numberOfHighCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .high ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfHighDayRisks, 0)
		XCTAssertEqual(numberOfHighCheckinRisks, 1)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 0)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 1)
	}

	// 1 match with 30m overlap. Overlap time sum from all checkins is 30m.
	// Result: High checkin risk. Low day risk.
	func test_Szenario_3() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:40:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T10:10:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfLowDayRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .low ? $0 + 1 : $0
		}

		let numberOfHighCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .high ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfLowDayRisks, 1)
		XCTAssertEqual(numberOfHighCheckinRisks, 1)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 1)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 1)
	}

	// 1 match with 60m overlap. Overlap time sum from all checkins is 60m.
	// Result: High checkin risk. High day risk.
	func test_Szenario_4() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T10:30:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfHighDayRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .high ? $0 + 1 : $0
		}

		let numberOfHighCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .high ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfHighDayRisks, 1)
		XCTAssertEqual(numberOfHighCheckinRisks, 1)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 1)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 1)
	}

	// Test 2 Checkins with a match, spanning over both checkins.
	// Results in several high risk checkins and days.
	func test_Szenario_5() {
		guard let checkin1StartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkin1EndDate = utcFormatter.date(from: "2021-03-05T09:30:00+01:00"),
			  let checkin2StartDate = utcFormatter.date(from: "2021-03-05T13:30:00+01:00"),
			  let checkin2EndDate = utcFormatter.date(from: "2021-03-06T19:30:00+01:00"),
			  let match1StartDate = utcFormatter.date(from: "2021-03-04T10:30:00+01:00"),
			  let match1EndDate = utcFormatter.date(from: "2021-03-06T15:30:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let eventStore = MockEventStore()
		let checkinSplittingService = CheckinSplittingService()
		let traceWarningMatcher = TraceWarningMatcher(eventStore: eventStore)

		let result1 = eventStore.createCheckin(
			Checkin.mock(
				checkinStartDate: checkin1StartDate,
				checkinEndDate: checkin1EndDate
			)
		)

		let result2 = eventStore.createCheckin(
			Checkin.mock(
				checkinStartDate: checkin2StartDate,
				checkinEndDate: checkin2EndDate
			)
		)

		guard case .success(let checkinId1) = result1 else {
			XCTFail("Success result expected.")
			return
		}

		guard case .success(let checkinId2) = result2 else {
			XCTFail("Success result expected.")
			return
		}

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId1,
				startIntervalNumber: create10MinutesInterval(from: match1StartDate),
				endIntervalNumber: create10MinutesInterval(from: match1EndDate),
				transmissionRiskLevel: 1
			)
		)

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId2,
				startIntervalNumber: create10MinutesInterval(from: match1StartDate),
				endIntervalNumber: create10MinutesInterval(from: match1EndDate),
				transmissionRiskLevel: 1
			)
		)

		let riskCalculation = CheckinRiskCalculation(
			eventStore: eventStore,
			checkinSplittingService: checkinSplittingService,
			traceWarningMatcher: traceWarningMatcher
		)

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfHighRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .high ? $0 + 1 : $0
		}

		let numberOfHighRisksPerCheckin: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .high ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfHighRisks, 3)
		XCTAssertEqual(numberOfHighRisksPerCheckin, 4)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 3)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 3)
	}

	func test_When_StoreHasSubmittedCheckins_Then_SubmittedCheckinsAreIgnored_And_NoHighRiskIsReturned() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T10:30:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let eventStore = MockEventStore()
		let checkinSplittingService = CheckinSplittingService()
		let traceWarningMatcher = TraceWarningMatcher(eventStore: eventStore)

		let result1 = eventStore.createCheckin(
			Checkin.mock(
				checkinStartDate: checkinStartDate,
				checkinEndDate: checkinEndDate,
				checkinSubmitted: true
			)
		)

		guard case .success(let checkinId1) = result1 else {
			XCTFail("Success result expected.")
			return
		}

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId1,
				startIntervalNumber: create10MinutesInterval(from: matchStartDate),
				endIntervalNumber: create10MinutesInterval(from: matchEndDate),
				transmissionRiskLevel: 1
			)
		)

		let riskCalculation = CheckinRiskCalculation(
			eventStore: eventStore,
			checkinSplittingService: checkinSplittingService,
			traceWarningMatcher: traceWarningMatcher
		)

		let checkinRiskCalculationResult = riskCalculation.calculateRisk(
			with: createAppConfig(),
			now: nowDate
		)

		let numberOfHighDayRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .high ? $0 + 1 : $0
		}

		let numberOfHighCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .high ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfHighDayRisks, 0)
		XCTAssertEqual(numberOfHighCheckinRisks, 0)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 0)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 0)
	}
	
	func test_Given_maxCheckInAgeInDays_When_Equals_checkinEndDate_Then_Checkin_is_NOT_Filtered() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:40:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T09:50:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-07T010:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		var appConfig = createAppConfig()
		
		// The injected reference date 'now' is exactly 3 days older then checkinEndDate.
		// With maxCheckInAgeInDays set to 3, the checkin should not be filtered and the risk calculation should lead to a risk entry.
		appConfig.presenceTracingParameters.riskCalculationParameters.maxCheckInAgeInDays = 3
		let checkinRiskCalculationResult = riskCalculation.calculateRisk(with: appConfig, now: nowDate)

		let numberOfLowCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .low ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfLowCheckinRisks, 1)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 1)
	}
	
	func test_Given_maxCheckInAgeInDays_When_Smaller_checkinEndDate_Then_Checkin_is_Filtered() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:30:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T09:40:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T09:50:00+01:00"),
			  let nowDate = utcFormatter.date(from: "2021-03-07T010:30:01+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		guard let riskCalculation = makeRiskCalculation(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			matchStartDate: matchStartDate,
			matchEndDate: matchEndDate
		) else {
			XCTFail("Could not create CheckinRiskCalculation.")
			return
		}

		var appConfig = createAppConfig()
		
		// The injected reference date 'now' is exactly 3 days and 1 second older then checkinEndDate.
		// With maxCheckInAgeInDays set to 3, the checkin should be filtered and the risk calculation should not lead to a risk entry.
		appConfig.presenceTracingParameters.riskCalculationParameters.maxCheckInAgeInDays = 3
		let checkinRiskCalculationResult = riskCalculation.calculateRisk(with: appConfig, now: nowDate)

		let numberOfLowCheckinRisks: Int = checkinRiskCalculationResult.checkinIdsWithRiskPerDate.reduce(0) {
			$1.value.reduce($0) {
				$1.riskLevel == .low ? $0 + 1 : $0
			}
		}

		XCTAssertEqual(numberOfLowCheckinRisks, 0)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 0)
	}
	
	private func createAppConfig() -> SAP_Internal_V2_ApplicationConfigurationIOS {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		var tracingParameters = SAP_Internal_V2_PresenceTracingParameters()
		var transmissionRiskValueMapping = [SAP_Internal_V2_TransmissionRiskValueMapping]()
		var normalizedTimePerCheckInToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var normalizedTimePerDayToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var riskCalculationParameters = SAP_Internal_V2_PresenceTracingRiskCalculationParameters()

		var riskMapping1 = SAP_Internal_V2_TransmissionRiskValueMapping()
		riskMapping1.transmissionRiskLevel = 1
		riskMapping1.transmissionRiskValue = 1
		transmissionRiskValueMapping.append(riskMapping1)

		var riskMapping2 = SAP_Internal_V2_TransmissionRiskValueMapping()
		riskMapping2.transmissionRiskLevel = 2
		riskMapping2.transmissionRiskValue = 2
		transmissionRiskValueMapping.append(riskMapping2)

		var timeToRiskMappingLow = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var rangeLow = SAP_Internal_V2_Range()
		rangeLow.min = 5
		rangeLow.max = 15
		timeToRiskMappingLow.normalizedTimeRange = rangeLow
		timeToRiskMappingLow.riskLevel = .low

		var timeToRiskMappingHigh = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var rangeHigh = SAP_Internal_V2_Range()
		rangeHigh.minExclusive = true
		rangeHigh.min = 15
		rangeHigh.max = Double.greatestFiniteMagnitude
		timeToRiskMappingHigh.normalizedTimeRange = rangeHigh
		timeToRiskMappingHigh.riskLevel = .high

		normalizedTimePerCheckInToRiskLevelMapping.append(timeToRiskMappingLow)
		normalizedTimePerCheckInToRiskLevelMapping.append(timeToRiskMappingHigh)

		var dayTimeToRiskMappingLow = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var dayRangeLow = SAP_Internal_V2_Range()
		dayRangeLow.min = 30
		dayRangeLow.max = 50
		dayTimeToRiskMappingLow.normalizedTimeRange = dayRangeLow
		dayTimeToRiskMappingLow.riskLevel = .low

		var dayTimeToRiskMappingHigh = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var dayRangeHigh = SAP_Internal_V2_Range()
		dayRangeHigh.minExclusive = true
		dayRangeHigh.min = 50
		dayRangeHigh.max = Double.greatestFiniteMagnitude
		dayTimeToRiskMappingHigh.normalizedTimeRange = dayRangeHigh
		dayTimeToRiskMappingHigh.riskLevel = .high

		normalizedTimePerDayToRiskLevelMapping.append(dayTimeToRiskMappingLow)
		normalizedTimePerDayToRiskLevelMapping.append(dayTimeToRiskMappingHigh)

		riskCalculationParameters.transmissionRiskValueMapping = transmissionRiskValueMapping
		riskCalculationParameters.normalizedTimePerCheckInToRiskLevelMapping = normalizedTimePerCheckInToRiskLevelMapping
		riskCalculationParameters.normalizedTimePerDayToRiskLevelMapping = normalizedTimePerDayToRiskLevelMapping

		tracingParameters.riskCalculationParameters = riskCalculationParameters
		config.presenceTracingParameters = tracingParameters

		return config
	}

	private func makeRiskCalculation(
		checkinStartDate: Date,
		checkinEndDate: Date,
		matchStartDate: Date,
		matchEndDate: Date
	) -> CheckinRiskCalculation? {
		let eventStore = MockEventStore()
		let checkinSplittingService = CheckinSplittingService()
		let traceWarningMatcher = TraceWarningMatcher(eventStore: eventStore)

		let result1 = eventStore.createCheckin(
			Checkin.mock(
				checkinStartDate: checkinStartDate,
				checkinEndDate: checkinEndDate
			)
		)

		guard case .success(let checkinId1) = result1 else {
			XCTFail("Success result expected.")
			return nil
		}

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId1,
				startIntervalNumber: create10MinutesInterval(from: matchStartDate),
				endIntervalNumber: create10MinutesInterval(from: matchEndDate),
				transmissionRiskLevel: 1
			)
		)

		return CheckinRiskCalculation(
			eventStore: eventStore,
			checkinSplittingService: checkinSplittingService,
			traceWarningMatcher: traceWarningMatcher
		)
	}

	private func makeDummyMatch(
		checkinId: Int,
		startIntervalNumber: Int,
		endIntervalNumber: Int,
		transmissionRiskLevel: Int
	) -> TraceTimeIntervalMatch {
		TraceTimeIntervalMatch(
			id: 0,
			checkinId: checkinId,
			traceWarningPackageId: 0,
			traceLocationId: Data(),
			transmissionRiskLevel: transmissionRiskLevel,
			startIntervalNumber: startIntervalNumber,
			endIntervalNumber: endIntervalNumber
		)
	}

	private func create10MinutesInterval(from date: Date) -> Int {
		Int(date.timeIntervalSince1970 / 600)
	}

	private var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	private lazy var uctCalendar: Calendar = {
		Calendar.utc()
	}()
}
