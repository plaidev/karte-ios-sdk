#!/bin/bash

rm -r output
for i in `seq 1 20`
do
echo $i
xcodebuild test -workspace Karte.xcworkspace \
                            -scheme KarteTests \
                            -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
                            -derivedDataPath DerivedData \
                            -resultBundlePath "output/KarteTests_iPhone_11_13_6_$i.xcresult"
done
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_1.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_2.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_3.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_4.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_5.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_6.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_7.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_8.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_9.xcresult"
# xcodebuild test -workspace Karte.xcworkspace \
#                             -scheme KarteTests \
#                             -destination "platform=iOS Simulator,name=iPhone 11,OS=13.6" \
#                             -derivedDataPath DerivedData \
#                             -resultBundlePath "output/KarteTests_iPhone_11_13_6_10.xcresult"


