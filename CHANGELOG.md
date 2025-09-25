# Latest Version

| モジュール名 | Description | 最新のバージョン |
| :-- | :-- | :-- |
| KarteCore | イベントトラッキング機能を提供します。 | 2.32.0 |
| KarteInAppMessaging | アプリ内メッセージ機能を提供します。 | 2.22.0 |
| KarteRemoteNotification | プッシュ通知の受信および効果測定機能を提供します。 | 2.13.0 |
| KarteVariables | 設定値配信機能を提供します。 | 2.13.0 |
| KarteVisualTracking | ビジュアルトラッキング機能を提供します。 | 2.14.0 |
| KarteInAppFrame | アプリ内埋め込みコンポーネント機能を提供します。 | 0.6.0 |
| KarteCrashReporting | クラッシュイベントのトラッキング機能を提供します。 | 2.10.0 |
| KarteUtilities | KarteCore モジュール等が利用するUtility機能を提供します。通常直接参照する必要はありません。 | 3.14.0 |
| KarteNotificationServiceExtension | リッチプッシュ通知機能を提供します。 | 1.3.0 |
| KarteDebugger | KARTE for Appのデバッグ機能を提供します。 | 1.1.0 |

# Releases - 2025.09.25
## Version 2.27.0

### InAppMessaging 2.22.0
** 💊FIXED**
- iOS26で、IAMWindowがView階層から正しく除去されない問題を修正しました。
- `InAppMessaging`に`InAppMessagingDelegate`が設定されている、かつその`InAppMessagingDelegate`に`inAppMessaging`メソッドが実装されていない場合に、WebView上のリンクをタップした際にクラッシュする問題を修正しました。

** 🔨CHANGED**
- InAppMessaging2.21.0で追加した接客の非表示対象にHealthKitの権限取得ダイアログを追加しました。

# Releases - 2025.09.12
## Version 2.26.0

### Core 2.32.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### InAppMessaging 2.21.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)
- iOS26以降で、システムが提供する一部のViewController表示時は接客を非表示にするようにしました。
  - この挙動は `isSkipSystemUIDetectionInWebView` フラグをtrueにすることで無効化することができます。デフォルトではこの値は `false` です。
  - 通常の利用では本フラグの設定は必要ありません
  - `isSkipRemoteViewDetectionInWebView` が非推奨になりました。

### RemoteNotification 2.13.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### Variables 2.13.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### VisualTracking 2.14.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### InAppFrame 0.6.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### CrashReporting 2.10.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### KarteUtilities 3.14.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### NotificationServiceExtension 1.3.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

### Debugger 1.1.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS12.0 → iOS15.0)

# Releases - 2025.08.05
## Version 2.25.0

### Core 2.31.0
** 🔨CHANGED**
- API通信実装変更に伴う変更を行いました。

### InAppMessaging 2.20.0
** 💊FIXED**
- ランドスケープ時のアプリ内メッセージ表示時のアニメーションを改善しました。

### RemoteNotification 2.12.0
** 🔨CHANGED**
- Objective-C++との相互運用性を改善しました。

### Variables 2.12.0
** 🔨CHANGED**
- Objective-C++との相互運用性を改善しました。

### VisualTracking 2.13.0
** 🔨CHANGED**
- API通信実装変更に伴う変更を行いました。

### InAppFrame 0.5.0
** 🔨CHANGED**
- LintのWarningを修正しました。

### Utilities 3.13.0
** 🔨CHANGED**
- 一部のAPI通信の実装を3rd partyライブラリから内製のコードに置き換えました。

# Releases - 2025.05.26
## Version 2.24.0

### Debugger 1.0.0
** 🎉 FEATURE**
- デバッグ用のモジュールを追加しました。

# Releases - 2025.04.16
## Version 2.23.0

### InAppFrame 0.4.0
** 🎉 FEATURE**
- UIKitでInAppFrameのコンポーネントのサイズを取得できるインタフェースを追加しました。
- AutolayoutでInAppFrameのコンポーネントのサイズを直接指定できるようにしました。

# Releases - 2025.04.09
## Version 2.22.0

### InAppFrame 0.3.0
** 💊FIXED**
- カルーセルが任意の横幅の場合でも見切れず表示されるように修正しました。

** 🔨CHANGED**
- カルーセルタップ時の処理を行うコンポーネントをItemTapListenerからInAppFrameDelegateに変更しました。

# Releases - 2025.03.25
## Version 2.21.0

### InAppFrame 0.2.0
** 💊FIXED**
- SwiftUIでIAFCarouselを使用した際にIAFCarousel領域の背景色を透過するように修正しました。

# Releases - 2025.02.14
## Version 2.20.1

### InAppFrame 0.1.1
** 💊FIXED**
- SwiftPackageManagerでインストールした際にビルドエラーになる問題を修正しました。

# Releases - 2025.02.14
## Version 2.20.0

### InAppFrame 0.1.0
** 🎉 FEATURE**
- アプリ内に管理画面で設定したネイティブコンポーネントを追加できるモジュールをOSSとして公開しました（β版）。
  - ご利用いただくには別途お手続きが必要です。

### Variables 2.11.0
** 🔨CHANGED**
- 一部のプロパティの可視性をpublicに変更しました。

# Releases - 2025.02.12
## Version 2.19.0

### CrashReporting 2.9.0
** 💊FIXED**
- PLCrashReporterに依存している他のライブラリ(Datadogなど)への依存を追加するとビルドエラーになる問題を修正しました。

# Releases - 2024.12.05
## Version 2.18.0

### Core 2.30.0
** 🎉 FEATURE**
- Native機能呼び出しにATT許諾ダイアログ表示を追加しました。

### InAppMessaging 2.19.0
** 🔨CHANGED**
- InAppMessagingDelegateの処理をMainActorに隔離しました。

# Releases - 2024.08.26
## Version 2.17.0

### Core 2.29.0
** 🔨CHANGED**
- イベント送信のログにイベント内容を付与しました。

### InAppMessaging 2.18.0
** 🔨CHANGED**
- InAppMessagingの画面境界の自動判定のOn/Offを切り替え可能にしました

** 💊FIXED**
- suppressed状態で設定値配信を取得した場合に_message_suppressedが発生しないように変更しました。
- UIActivityViewControllerなどのシェア機能と接客の同時表示時にタップできない領域が発生していたため、当該状況では接客を非表示にするよう修正しました。

# Releases - 2024.06.25
## Version 2.16.0

### Core 2.28.0
** 🔨CHANGED**
- AppTrackingTransparencyの許諾状況をKARTE側に同期する機能を追加しました。

# Releases - 2024.06.13
## Version 2.15.0

### CrashReporting 2.8.0
** 🔨CHANGED**
- Privacy manifestの設定を更新しました。
 
### InAppMessaging 2.17.1
** 💊FIXED**
- 一部の別ライブラリと併用した場合にcrashする不具合を修正しました。

# Releases - 2024.05.09
## Version 2.14.0

### Core 2.27.0
** 🔨CHANGED**
- サポート改善のため、ログにタイムスタンプを出力するようにしました。

### Veriables 2.10.0
** 🔨CHANGED**
- 特定の条件にマッチする変数オブジェクトをリスト形式で取得できるメソッドを追加しました。 

** 💊FIXED**
- getAllKeysでシステムが利用しているlastFetchTimeとlastFetchStatusが返されるのを修正しました

# Releases - 2024.04.18
## Version 2.13.0

### Variables 2.9.0
** 🔨CHANGED**
- 設定値のキーのキャッシュを削除する機能を追加しました。 

# Releases - 2024.03.03
## Version 2.12.0

### Core 2.26.0
** 🔨CHANGED**
- Privacy manifestの設定を最新のDataTypeの定義に合わせて修正しました。

### Variables 2.8.0
** 🔨CHANGED**
- 現在取得できている設定値の全てのキーの一覧を取得できる機能を追加しました。

### Utilities 3.12.0
** 🔨CHANGED**
- Userdefaultsの特定の名前空間に存在する全てのキーを取得する機能を追加しました。

# Releases - 2024.01.31
## Version 2.11.0

### Core 2.25.0
** 🔨CHANGED**
- KARTEのベースURLを Info.plist ファイルから自動で読みこむ機能を追加しました。
- KARTEプロジェクトのデータロケーション設定を追加しました。

** 💊FIXED**
- Xcode14以降でビルド時に発生するwarningを修正しました。

### InAppMessaging 2.17.0
** 🔨CHANGED**
- 接客表示用のhtmlを、KARTEプロジェクトのデータロケーションに対応しました。

### Utilities 3.11.0
** 💊FIXED**
- Xcode14以降でビルド時に発生するwarningを修正しました。

# Releases - 2023.12.25
## Version 2.10.1

### Core 2.24.1
** 🔨CHANGED**
- Privacy manifestの設定を変更しました。

### Variables 2.7.1
** 💊FIXED**
- プライバシーレポート出力時にエラーになる問題を修正しました。

### CrashReporting 2.7.1
** 🔨CHANGED**
- Privacy manifestの設定を変更しました。

### Utilities 3.10.1
** 💊FIXED**
- プライバシーレポート出力時にエラーになる問題を修正しました。

# Releases - 2023.12.06
## Version 2.10.0

### Core 2.24.0
** 🎉 FEATURE**
- Privacy manifestを追加しました。

** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

### InAppMessaging 2.16.0
** 🎉 FEATURE**
- WKWebView配下のRemoteView検出をスキップするオプションを追加しました（通常の利用では本オプションの設定は必要ありません）

** 💊FIXED**
- ImagePickerやKeyboardを開くと不要なWebViewが生成されてしまう問題を修正しました。
- タグv2利用時に、エレメントビルダー（β版）で作成した接客アクションで「アプリで確認」機能が動かない問題を修正しました。

** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)
- サポート改善のため、接客表示失敗時のログを追加しました。

### RemoteNotification 2.11.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

### Variables 2.7.0
** 🎉 FEATURE**
- Privacy manifestを追加しました。

** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

### VisualTracking 2.12.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

** 💊FIXED**
- iOS17でDeprecatedになったAPI(UIGraphicsBeginImageContextWithOptions(_:_:_:))を使用しないように修正しました。

### CrashReporting 2.7.0
** 🎉 FEATURE**
- Privacy manifestを追加しました。

** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

### Utilities 3.10.0
** 🎉 FEATURE**
- Privacy manifestを追加しました。

** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)
- iOS17で導入されたURL初期化時の挙動変更の影響を受けないように対応しました。

### KarteNotificationServiceExtension 1.2.0
** 🔨CHANGED**
- Deployment Targetを変更しました(iOS11.0 → iOS12.0)

# Releases - 2023.08.11
## Version 2.9.0

### Core 2.23.0
** 🎉 FEATURE**
- サブモジュールがイベントを編集できる機能を追加しました。

** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

### InAppMessaging 2.15.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。
- タグv2利用時に、Viewイベントをアクション側に連携する機能を追加しました。

** 💊FIXED**
- 2.14.0におけるmessage_openイベントの送信仕様変更が、適用されていなかった不具合を修正しました。

### RemoteNotification 2.10.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

### Variables 2.6.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

### VisualTracking 2.11.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

** 💊FIXED**
- Swift5.5以降でビルドする際にSendableのWarningが出る問題を修正しました。

### CrashReporting 2.6.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。
- 依存する CrashReporter SDK をバージョンアップしました。

### Utilities 3.9.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

### KarteNotificationServiceExtension 1.1.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS10 → iOS11
- Cocoapodsの下限バージョンを1.10.0に変更しました。

# Releases - 2023.04.11
## Version 2.8.0

### Core 2.22.0
** 🎉 FEATURE**
- KARTEプロジェクトのAPIキーをSDKに設定できるようになりました。
   - Inboxモジュールを使用する場合のみ設定が必要です。
- サブモジュールと連携してイベントの送信を行う機構を追加しました。
- `JSONConvertibleConverter` に `[AnyHashable: Any]` を `[String: JSONConvertible]` に変換するメソッドを追加しました。  

** 🔨CHANGED**
- identifyイベントのuser_idに明示的に空文字が指定された場合に警告だけ出力するように変更しました。
- viewイベントのview_nameが空文字の場合に警告だけ出力するように変更しました。
- 脱獄済みデバイスではSDKが動作しないように変更しました。
- ログの一時保持・収集機能を廃止しました。
- `KarteApp.setLogEnabled()` を deprecated にし、代わりにログレベルOFFを追加しました。
- サブモジュール連携用のインターフェース仕様を一部変更しました。
- 依存する Utilities のバージョンを 3.8.0 に変更しました。  

** 💊FIXED**
- メソッド置換処理を改善し、一部のサードパーティ製SDKとコンフリクトする問題を解消しました。

### InAppMessaging 2.14.0
** 🔨CHANGED**
- message_openイベントの送信仕様をWebの仕様に合わせるようにしました。
- 依存する Core のバージョンを 2.22.0 に変更しました。
- 依存する Utilities のバージョンを 3.8.0 に変更しました。  

** 💊FIXED**
- メソッド置換処理を改善し、一部のサードパーティ製SDKとコンフリクトする問題を解消しました。

### RemoteNotification 2.9.0
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.8.0 に変更しました。  

** 💊FIXED**
- メソッド置換処理を改善し、一部のサードパーティ製SDKとコンフリクトする問題を解消しました。

### Variables 2.5.0
** 🔨CHANGED**
- 効果測定用のイベントにフィールドを追加しました。
- 依存する Core のバージョンを 2.22.0 に変更しました。  

** 💊FIXED**
- ユーザー情報変数の解決に失敗したアクションの場合に `_message_ready` イベントが送信されない問題を修正しました。

### VisualTracking 2.10.0
** 🔨CHANGED**
- 依存する Core のバージョンを 2.22.0 に変更しました。
- 依存する Utilities のバージョンを 3.8.0 に変更しました。  

** 💊FIXED**
- メソッド置換処理を改善し、一部のサードパーティ製SDKとコンフリクトする問題を解消しました。

### Utilities 3.8.0
** 🎉 FEATURE**
- メソッド置換を安全に行うために改良したAPIを追加しました。
- ISO8601形式の日時変換用のDateFormatterを返すAPIを追加しました。

### Inbox 0.1.0
** 🎉 FEATURE**
- Push通知の送信履歴が取得できるモジュールをOSSとして公開しました（β版）。
  - ご利用いただくには別途お手続きが必要です。

# Releases - 2022.12.23
## Version 2.7.0

### InAppMessaging 2.13.0
** 💊FIXED**
- 2.7.0における修正において混入した、接客上の一部色領域（オレンジ、黒等）がタップが透過してしまう不具合を修正しました。

# Releases - 2022.09.09
## Version 2.6.0

### InAppMessaging 2.12.0
** 💊FIXED**

iOS16上で接客内の動画再生時に接客が閉じてしまう問題に対応しました。
この対応により、iOS16以上で接客内の動画はフルスクリーンではなくインラインで再生されます。
なお、iOS16未満のOS上の動作に変更はありません。

### RemoteNotification 2.8.0
** 🔨CHANGED**
- iOS9用の実装の削除しました。
- iOS10の非推奨APIを使った実装を削除しました。

# Releases - 2022.08.04
## Version 2.5.1

### RemoteNotification 2.7.1
** 💊FIXED** 
- 一部のファイルがStatic Library としてビルドできない問題を修正しました
- Xcode 13.3以降でVariablesモジュールとあわせて導入した際にコンパイルエラーになる問題を修正しました

### Variables 2.4.1
** 💊FIXED** 
- 一部のファイルがStatic Library としてビルドできない問題を修正しました
- Xcode 13.3以降でRemoteNotificationモジュールとあわせて導入した際にコンパイルエラーになる問題を修正しました

# Releases - 2022.07.29
## Version 2.5.0

### Core 2.21.0
** 🎉 FEATURE**
- WebView連携のための補助APIとして `UserSync.getUserSyncScript` を追加しました。
  - 返されるスクリプトをWebViewで実行することで、`WKWebView`以外のWebViewに対してもユーザー連携が可能になります。
  - これに伴い、クエリパラメータ連携API `UserSync.appendingQueryParameter` は非推奨になります。

# Releases - 2022.06.28
## Version 2.4.0

### InAppMessaging 2.11.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

### RemoteNotification 2.7.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

### Variables 2.4.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

### VisualTracking 2.9.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

### Utilities 3.7.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

### CrashReporting 2.3.0
** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

# Releases - 2022.06.28
## Version 2.4.0

### Core 2.20.0
** 🎉 FEATURE**
- イベントトラッキングのレスポンス構造体にtriggerフィールドを追加しました。

** 🔨CHANGED**
- Deployment Targetの変更 iOS9 → iOS10

# Releases - 2022.03.31
## Version 2.3.0

### VisualTracking 2.8.0
** 🎉 FEATURE**
- 操作ログの自動収集を無効化する設定項目を追加しました。
  - この機能はFlutterのiOSにて操作ログの重複を防ぐ目的で加えられました。

# Releases - 2022.01.20
## Version 2.2.0

### KarteNotificationServiceExtension 1.0.0
** 🎉 FEATURE**
- リッチプッシュ通知機能のモジュールをOSSとして公開しました。
  - 既存のKarteTrackerAppExtensionsモジュールも引き続きご利用できますが、今後はバグ修正等はこちらのモジュールでのみ行われます。

# Releases - 2022.01.12
## Version 2.1.0

### VisualTracking 2.7.0
** 🎉 FEATURE**
- 動的なフィールドの付与に対応しました。
  - 動的フィールドについては[こちら](https://support.karte.io/post/7JbUVotDwZMvl6h3HL9Zt7#6-0)を参考ください。

# Releases - 2021.11.25
## Version 2.0.0
### Core 2.19.0
** 🎉 FEATURE**
- attributeイベントを送信するためのAPIを追加しました。
  - attributeイベントとidentifyイベントの使い分けについては[こちら](https://support.karte.io/post/1X39NRwR0HXzCtigtRrbLJ#2-0)を参考ください。

** 🔨 CHANGED**
- identifyイベントの第一引数「user_id」パラメータの付与を必須にしました。
- identifyイベントの第一引数「user_id」パラメータに空文字が指定された場合に、イベントが送信されないようにしました。
- viewイベントの第一引数「view_name」パラメータに空文字が指定された場合に、イベントが送信されないようにしました。
- イベント名とフィールド名に非推奨な名前が使われていた場合に、warningログを出力するようにしました。
  - イベント名とフィールド名に関する制限については[こちら](https://developers.karte.io/docs/guide-event#%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%E3%81%AE%E5%88%B6%E9%99%90)を参考ください。

### Utilities 3.6.0
** 💊FIXED**
- コンパイラの警告を修正しました。

### InAppMessaging 2.10.1
** 💊FIXED**
- iOS14以降でまれにクラッシュする問題に対策を加えました。

# Releases - 2021.10.28

### Variables 2.3.0
** 🎉 FEATURE**
- 設定値の最終フェッチ完了時間と最終フェッチ完了ステータスを取得するAPIを追加しました。
- 指定秒数以内にフェッチが成功したかどうかを取得するAPIを追加しました。

** 🔨 CHANGED**
- 依存する Utilities のバージョンを 3.5.0 に変更しました。

### Utilities 3.5.0
** 🔨CHANGED**
- Variables 2.3.0 のリリースに伴う軽微な関数の追加を行いました。

# Releases - 2021.10.20

### Core 2.18.0
** 🔨CHANGED**
- 解析サーバの負荷低減のために、再送が連続して失敗した場合に一時的に再送しないようにしました。
- 再送の回数を調整しました。

# Releases - 2021.09.03

### Core 2.17.0
** 💊FIXED**
- ビジターIDのリセットイベント(native_app_renew_visitor_id)が、リセット後のユーザーストーリーに表示されない問題を修正しました。

# Releases - 2021.07.09

### Core 2.16.0
** 💊FIXED**
- lintの警告を修正しました。

### InAppMessaging 2.10.0
** 💊FIXED**
- lintの警告を修正しました。

### RemoteNotification 2.6.0
** 💊FIXED**
- lintの警告を修正しました。

# Releases - 2021.06.25

### Variables 2.2.0
** 🎉FEATURE**
- Variables.fetch(completion:)メソッドのキャッシュ保存処理を最適化し、処理速度を向上させました。

### Utilities 3.4.0
** 🎉FEATURE**
- UserDefaultsへの保存処理を効率よく行うAPIを追加しました。

# Releases - 2021.06.03

### Core 2.15.0
** 🎉FEATURE**
- サブモジュールの設定をConfigクラス経由で設定・取得するAPIを追加しました。

### RemoteNotification 2.5.0
** 🔨CHANGED**
- モジュール設定の方法をCoreモジュールのConfigクラス経由のものに変更しました。
   以前の方法は非推奨になりました。

### InAppMessaging 2.9.0
** 🔨CHANGED**
- 常駐接客を表示中に画面遷移をすると接客表示イベント(message_open)が発生するように修正しました。

# Releases - 2021.04.20

### Core 2.14.1
** 💊FIXED**
- SDKの初期化時に稀にスレッドセーフでないプロパティへのアクセスでクラッシュが起きていた問題を修正しました。

### VisualTracking 2.6.0
** 💊FIXED**
- ActionFactory.createForUIKitメソッドのimageProvider引数が正しく処理されない問題を修正しました。

# Releases - 2021.03.04
### Core 2.14.0
** 💊FIXED**
- 自動テスト実行時に稀に起きていたクラッシュを修正しました。

### VisualTracking 2.5.0
** 🎉FEATURE**
- ビジュアルトラッキングのペアリング状態を取得できるインターフェースを公開しました。

# Releases - 2021.02.18
### CrashReporting 2.4.0
** 💊FIXED**
- arm64シミュレータでビルドが出来ない問題を修正しました。

# Releases - 2021.02.12
### Core 2.13.1
** 💊FIXED**
- オフラインで設定値取得を呼び出した時に完了処理が呼ばれない問題を修正しました。

# Releases - 2021.02.04
### InAppMessaging 2.8.1
** 💊FIXED**
- 接客内JavaScriptのtrack時の引数に直接Date型のオブジェクトが指定された際にクラッシュする問題を修正しました。
   この修正により、直接Date型のオブジェクトが指定された際は計測が行われません。
   接客内JavaScriptのtrackでDate型を利用したい場合はUnix時間 (秒) で数値型を指定してください。
   詳細については[送信可能なデータ型 - 日付型](https://developers.karte.io/docs/guide-event#%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%E5%90%8D%E3%81%AE%E5%88%B6%E9%99%90)を参照ください。
（[issue](https://github.com/plaidev/karte-ios-sdk/issues/13))

### VisualTracking 2.4.0
** 🎉FEATURE**
- ビジュアルトラッキングの操作ログを送信するインターフェースを公開しました。
   これによりSwiftUIを利用している場合でもActionProtocolを実装することで操作ログの送信が可能となります。

# Releases - 2021.01.15
### Core 2.13.0
** 💊FIXED**
- オプトアウト時にplugin_native_app_identifyイベントが送信されない不具合を修正しました。
- iOS14以上で非推奨になったSKStoreReviewControllerのrequestReview()の使用を廃止し、requestReview(in: UIWindowScene)を使用するよう修正しました。

# Releases - 2020.12.14
### Core 2.12.0
** 🎉FEATURE**
- SDKの初期化時にapp_keyを Info.plist ファイルから自動で読みこむAPIを追加しました。

### VisualTracking 2.3.0
** 🔨CHANGED**
- 試験的なトラッキングモード時にもビジュアルトラッキングを利用可能にしました。

### CrashReporting 2.3.0
** 🔨CHANGED**
- 依存する CrashReporter SDK をバージョンアップしました。

# Releases - 2020.12.07
### Utilities 3.3.0
** 🎉FEATURE**
- CocoaPodsで特定のバージョンのsqlite3をバンドルした際にもビルド可能なsubspecを追加しました。
  `pod 'sqlite3'`など特定のバージョンのsqlite3をバンドルするときは、 `pod 'KarteUtilities/sqlite-standalone'` とKarteUtilitiesのsubspecを明示的にdependenciesに追記してください。

# Releases - 2020.11.16
### Utilities 3.2.0
** 💊FIXED** 
- 端末のストレージ不足時にクラッシュしていた問題を修正しました。（[issue](https://github.com/plaidev/karte-ios-sdk/issues/5))

# Releases - 2020.10.09
### Core 2.11.0
** 💊FIXED** 
- SDKの初期化時に稀にクラッシュしていた問題を修正しました。（[issue](https://github.com/plaidev/karte-ios-sdk/issues/2))
  この対応により、同原因によるクラッシュが発生する状況では SDK の初期化自体が行われなくなります。
- アプリ実行中の端末の広告トラッキング許可状況の変化時にイベントにIDFAを含む/除外する処理が次回起動時まで遅れる問題を修正しました。
   本問題は広告IDの送信をアプリで実装している場合に限り発生する問題です。

# Releases - 2020.09.29
### Core 2.10.0
** 💊FIXED** 
- SDKの初期化時に稀にクラッシュしていた問題を修正しました。

# Releases - 2020.09.29
### Core 2.9.0
** 🔨CHANGED**
- 試験的な設定を追加しました。通常のSDK利用において当設定を有効化する必要はありません。

# Releases - 2020.09.17
### InAppMessaging 2.8.0
** 🎉FEATURE**
- App-Bound Domains を有効にしたアプリケーションでアプリ内メッセージが動作するようにしました。（InAppMessaging 2.8.0 を利用するには Xcode 12以上 が必要です。）

# Releases - 2020.09.12
### InAppMessaging 2.7.0
** 💊FIXED** 
- どの操作ができない範囲が一部の接客において背後のコンテンツに対してスクロールなどの操作ができない範囲があった問題を修正しました。

# Releases - 2020.09.09
### Core 2.8.0
** 🔨CHANGED**
- サポート改善のため、SDKのログを一時保持・収集するようにしました。

### InAppMessaging 2.6.0
** 🔨CHANGED**
- 接客表示時のVERBOSEなログの表示を調整しました。

### RemoteNotification 2.4.0
** 🎉FEATURE**
- Method swizzling を利用した通知開封イベントの自動送信を無効にできるようにしました。

# Releases - 2020.08.31
### Core 2.7.1
** 💊FIXED** 
- 設定値配信取得処理のコールバックが呼び出されない問題を修正しました。

# Releases - 2020.08.28
### Core 2.7.0
** 🔨CHANGED**
- イベントのバッファリングロジックを見直し、以前よりも効率的かつパフォーマンスよく送信が行えるようになりました。
  これにより接客の表示パフォーマンスが若干向上します。

### RemoteNotification 2.3.0
** 💊FIXED** 
- 通知をタップした際にクラッシュする問題を修正しました。
  本問題は Xamarin.iOS 上で動作させた場合に限り発生する問題であるため、Xamarin以外ではアップデートの必要はありません。

# Releases - 2020.07.22
### Core 2.6.0
** 🔨CHANGED**
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。([issue](https://github.com/plaidev/karte-ios-sdk/issues/3))

### InAppMessaging 2.5.0
** 🎉FEATURE**
- アクションを常駐させるオプションに対応しました。
  詳細は[こちら](https://developers.karte.io/docs/appendix-iam-control-ios-sdk-v2#%E3%82%A2%E3%83%97%E3%83%AA%E5%86%85%E3%83%A1%E3%83%83%E3%82%BB%E3%83%BC%E3%82%B8%E3%82%92%E5%B8%B8%E9%A7%90%E3%81%95%E3%81%9B%E3%82%8B)をご覧ください

** 🔨CHANGED**
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。

### RemoteNotification 2.2.0
** 🔨CHANGED**
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。

### Variables 2.1.0
** 🔨CHANGED**
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。

### VisualTracking 2.2.0
** 🔨CHANGED**　
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。

### CrashReporting 2.2.0
** 🔨CHANGED**
- Static Library としてビルドできるようにするために一部のヘッダーファイルのインポート方法を変更しました。

# Releases - 2020.07.08
### Core 2.5.0
** 🎉FEATURE**
- KARTE固有のURLスキームからNative機能の呼び出しが出来るようになりました。
  詳細は [アクションからNative機能を呼び出す](https://developers.karte.io/docs/appendix-native-command-ios-sdk-v2) をご覧ください。

### InAppMessaging 2.4.0
** 🎉FEATURE**
- SDK側で管理しているWebViewを任意のプロセスプール上で動かせるようになりました。
  詳細については [こちら](https://plaidev.github.io/karte-sdk-docs/ios/latest/KarteInAppMessaging/Classes/InAppMessaging.html#/c:@M@KarteInAppMessaging@objc(cs)KRTInAppMessaging(py)processPool) をご確認ください。

### RemoteNotification 2.1.0
** 🎉FEATURE**
- KARTE固有のURLスキームからNative機能の呼び出しが出来るようになりました。
  詳細は [アクションからNative機能を呼び出す](https://developers.karte.io/docs/appendix-native-command-ios-sdk-v2) をご覧ください。

### CrashReporting 2.1.0
** 🔨CHANGED**
- 依存する CrashReporter SDK をバージョンアップしました。

# Releases - 2020.06.29
### Core 2.4.0
** 🔨CHANGED**
- イベント送信中にアプリがバックグラウンドに入った場合に送信が完了するまでバックグラウンドで処理を継続するようにしました。

### InAppMessaging 2.3.0
** 🎉FEATURE**
- suppressメソッドを利用により接客の表示抑制が有効な状態で、接客の表示が抑制された時に表示抑制イベント（_message_suppressed）を飛ばすようにしました。

### RemoteNotification 2.0.3
** 💊FIXED** 
- バックグラウンドから復帰した際に最新の通知設定が送信されない問題を修正しました。
- 通知設定で `ロック画面` `通知センター` のみ有効かつ `バナー` `サウンド` `バッジ` が無効な場合に通知のsubscribe値が `false` となってしまう問題を修正しました（iOS10以上の場合に限る）

### VisualTracking 2.1.0
** 🔨CHANGED**
- バックグラウンドタスクの状態管理にUtilitiesにある共通クラスを利用するようにしました。

### Utilities 3.1.0
** 🔨CHANGED**
- VisualTrackingモジュールに実装されていたバックグラウンドタスクの状態管理クラスをUtilitiesに移しました。

# Releases - 2020.06.23
### InAppMessaging 2.2.1
** 💊FIXED** 
- 特定の条件下において接客表示時に無限ループが発生する問題を修正しました。([issue](https://github.com/plaidev/karte-ios-sdk/issues/4))

# Releases - 2020.06.22
### Core 2.3.0
** 🎉FEATURE**
- ディープリンクによるアプリ流入時に自動で送信するイベントを追加しました。

** 🔨CHANGED**
- KarteDetectors に依存しないようにしました。

### InAppMessaging 2.2.0
** 🔨CHANGED**
- KarteDetectors に依存しないようにしました。

# Releases - 2020.06.10
### Core 2.2.2
** 💊FIXED** 
- SDKが自動で発火させる一部のイベントが特定の条件下においてキューに滞留し意図したタイミングで送信されない問題を修正しました。

# Releases - 2020.05.14
### Core 2.2.1
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.0.0 に変更しました。

### InAppMessaging 2.1.1
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.0.0 に変更しました。

### RemoteNotification 2.0.2
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.0.0 に変更しました。

### Variables 2.0.1
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.0.0 に変更しました。

### VisualTracking 2.0.1
** 🔨CHANGED**
- 依存する Utilities のバージョンを 3.0.0 に変更しました。

** 💊FIXED** 
- ペアリング中に送信する操作ログに ViewController の一部の操作（viewDidAppear / present / dismiss）が含まれない問題を修正しました。

### Utilities 3.0.0
** 🔨CHANGED**
- Utilities 内に定義されている標準ライブラリを拡張した一部のメソッドが Core をインポートした場合にも読み込まれてしまうことにより、シンボルの衝突が発生する可能性がある問題を修正しました。
  なお本問題は Xcode 11.3.x 以下を利用する場合に発生します。

# Releases - 2020.05.12
### Core 2.2.0
** 💊FIXED**
- SDK内部で利用するconfigurationのoverlayBaseURLのcopy処理を修正しました。
- AppInfoやSystemInfoをJSONにエンコードする際に値がnilとなる要素のキーが含まれる問題を修正しました。

# Releases - 2020.04.24
### Core 2.1.0
** 🔨CHANGED**
- InAppMessagingモジュールから参照するためのフィールドを追加
- イベント送信時のリクエストボディをgzip圧縮するよう変更しました。
- イベントトラッキングを一時的に抑止するためのメソッドを追加しました。

### InAppMessaging 2.1.0
** 🎉FEATURE**
- 接客表示に利用するhtmlの取得エンドポイントを変更（CDN化）しました。
  この変更により、キャッシュにヒットした場合に初回の接客表示時のパフォーマンスが向上します。
- 接客の表示制限オプションにより表示が抑制された時に表示抑制イベント（_message_suppressed）を飛ばすようにしました。
  これにより接客の表示制限オプションにより接客が抑制されたことを検知できるようになります。

** 💊FIXED**
- プレビュー中にイベントトラッキングが行われてしまう問題を修正しました。

### RemoteNotification 2.0.1
** 💊FIXED**
- アプリケーションの実装によっては Method swizzling 行われない問題を修正しました。

### Utilities 2.1.0
** 🎉FEATURE**
- Gzip圧縮用の処理を追加しました。

# Releases - 2020.04.07
### Core 2.0.0
** 🎉FEATURE**
- イベントの送信失敗時に再送が行われるようになりました。
  詳細は [FAQ](https://developers.karte.io/docs/faq-ios-sdk-v2#section-%E9%80%81%E4%BF%A1%E3%81%AB%E5%A4%B1%E6%95%97%E3%81%97%E3%81%9F%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%E3%81%A9%E3%81%86%E3%81%AA%E3%82%8A%E3%81%BE%E3%81%99%E3%81%8B) をご覧ください。
- 画面サイズの情報を送るようになりました。
  詳細は [イベントに自動追加されるフィールド](doc:appendix-fields-ios-sdk-v2) をご覧ください。
- `native_app_open` 等のデフォルトイベントに任意のフィールドを付与できるようになりました。

** 🔨CHANGED**
- インターフェースを全面的に見直しました。
  詳細は [SDK v1からv2のアップグレード方法](doc:appendix-upgrade-ios-sdk-v2) をご覧ください。
- 複数アプリケーションキーへの対応を廃止しました。

### InAppMessaging 2.0.0
** 🎉FEATURE**
- Window表示時に `Key window` として表示するかどうか設定できるようになりました。
- Windowの表示や接客の表示・非表示を検知できるようになりました。
  詳細は [アプリ内メッセージを表示する](https://developers.karte.io/docs/iam-ios-sdk-v2#section-%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E7%8A%B6%E6%85%8B%E5%A4%89%E5%8C%96%E3%82%92%E6%A4%9C%E7%9F%A5%E3%81%99%E3%82%8B) をご覧ください。
- アクションのリンクをクリックした時に、アクションを閉じないように設定することができるようになりました。
  詳細は [アクションが非表示となる条件](https://developers.karte.io/docs/appendix-action-hidden-condition-ios-sdk-v2#section-%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E5%86%85%E3%81%AE%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%AF%E3%83%AA%E3%83%83%E3%82%AF%E3%81%AB%E3%82%88%E3%82%8B%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E9%9D%9E%E8%A1%A8%E7%A4%BA%E6%9D%A1%E4%BB%B6) をご覧ください。

** 💊FIXED**
- 配信頻度が `ユーザー毎` に設定されたアクションを表示した後にビジターIDをリセットした場合、リセット後のビジターに対して同アクションが表示されない問題を修正しました。

** 🔨CHANGED**
- インターフェースを全面的に見直しました。
  詳細は [SDK v1からv2のアップグレード方法](doc:appendix-upgrade-ios-sdk-v2) をご覧ください。
- 画面境界を自動で認識するようになりました。
  詳細は [アプリ内メッセージを表示する](https://developers.karte.io/docs/iam-ios-sdk-v2#section-%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%82%92%E8%A1%A8%E7%A4%BA%E3%81%99%E3%82%8B%E7%94%BB%E9%9D%A2%E3%82%92%E9%99%90%E5%AE%9A%E3%81%99%E3%82%8B) をご覧ください。
- `location.href` による遷移時に `inAppMessaging(_:shouldOpenURL:)` を呼び出すように変更しました。
- リンククリック時に `UIApplication.canOpenURL(_:)` を呼び出さないように変更しました。

### RemoteNotification 2.0.0
** 🔨CHANGED**
- インターフェースを全面的に見直しました。
  詳細は [SDK v1からv2のアップグレード方法](doc:appendix-upgrade-ios-sdk-v2) をご覧ください。
- `RemoteNotification#handle()` メソッドの内部で `UIApplication.canOpenURL(_:)` を呼び出さないように変更しました。

### Variables 2.0.0
** 🔨CHANGED**
- インターフェースを全面的に見直しました。
  詳細は [SDK v1からv2のアップグレード方法](doc:appendix-upgrade-ios-sdk-v2) をご覧ください。

### VisualTracking 2.0.0
** 🎉FEATURE**
- 同一の階層にある同じ種類のコンポーネントを識別できるようになりました。
- ペアリング中にアプリがバックグラウンドに遷移してもペアリングが切れづらくなりました。
- ペアリング中は端末がスリープ状態にならないようにしました。

** 🔨CHANGED**　

- インターフェースを全面的に見直しました。
  詳細は [SDK v1からv2のアップグレード方法](doc:appendix-upgrade-ios-sdk-v2) をご覧ください。

### CrashReporting 2.0.0
** 🔨CHANGED**
- インターフェースを全面的に見直しました。

### Utilities 2.0.0
初回リリース

<div style="display:none;">
テンプレ

# Releases - 2022.01.12
## Version 2.1.0

### Core 2.0.0
** 🎉FEATURE**
- xxx

** 💊FIXED**
- xxx

** 🔨CHANGED**
- xxx
</div>
