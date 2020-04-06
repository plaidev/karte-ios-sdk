install: scripts/setup.sh
	cd scripts && bash setup.sh

docs: .jazzy.yaml
	cd scripts && ruby generate_docs.rb

rh: ../karte-ios-tools/scripts/rh/replace_header.sh
	find -E KarteCore KarteCrashReporting KarteInAppMessaging KarteRemoteNotification KarteTests KarteVariables KarteVisualTracking KarteUtilities KarteDetectors -type d -name ThirdParty -prune -o -name PLCrashReporter -prune -o -type f -iregex ".*\.(swift|h|m)" -exec ../karte-ios-tools/scripts/rh/replace_header.sh {} \;

.PHONY:	install docs rh