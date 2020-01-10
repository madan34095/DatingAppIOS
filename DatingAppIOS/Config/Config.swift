//
//  Config.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/09/28.
//  Copyright © 2019 ADV. All rights reserved.
//

import Foundation
import UIKit

func SCALE(value : CGFloat) -> CGFloat{
    return value * Config.SCREEN_WIDTH / 414
}
func BORDER_WIDTH() -> CGFloat{
    if(Config.SCREEN_WIDTH>375){
        return 0.33
    }else{
        return 0.5
    }
}

class Config {
    
    static let BASEURL = "http://160.16.208.69/datingapp/api/index.php?p="
//    static let BASEURL = "http://192.168.207.85/datingapp/api/index.php?p="

    static let SIGNUP = "signup"
    static let EDIT_PROFILE = "edit_profile"
    static let GET_USER_INFO = "getUserInfo"
    static let UPLOAD_IMAGES = "uploadImages"
    static let DELETE_IMAGES = "deleteImages"
    static let USER_NEARBY_ME = "userNearByMe"
    static let FLAT_USER = "flat_user"
    static let LIKE_ME = "likeMe"
    static let MY_MATCH = "myMatch"
    static let FIRST_CHAT = "firstchat"
    static let UNMATH = "unMatch"
    static let SHOW_HIDE_PROFILE = "show_or_hide_profile"
    static let UPDATE_PURCHASE_STATUS = "update_purchase_Status"
    static let DELETE_ACCOUNT = "deleteAccount"
    static let SEND_PUSH_NOTIFICATION = "sendPushNotification"

    //Firebase Config
    static let FIREUSEREMAIL = "dev01@gmail.com"
    static let FIREPASSWORD = "111111"

    static let BASE = UIColor(red: 0.0, green: 161/255, blue: 154/255, alpha: 1.0)
    static let BACK = UIColor(hexString: "D9E6EB")
    static let GRAY = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    static let BLACK = UIColor(red: 29/255, green: 29/255, blue: 27/255, alpha: 1.0)
    static let BUBBLE = UIColor(red: 203/255, green: 187/255, blue: 159/255, alpha: 1.0)
    static let TabUnderLineColor = UIColor.red
    
    static let half_transfer = UIColor(hexString: "42000000")
    static let transfer = UIColor(hexString: "00000000")
    static let white = UIColor(hexString: "FFFFFF")
    static let black = UIColor(hexString: "000000")
    static let border_color = UIColor(hexString: "8C8C8C")
    static let background = UIColor(hexString: "EFEFEF")
    static let button = UIColor(hexString: "E0E0E0")
    static let SEPARATER_BCOLOR = UIColor(hexString: "C8C7CC")
    static let text_black = UIColor(hexString: "222222")
    static let text_gray = UIColor(hexString: "8F8F8F")
    static let text_code = UIColor(hexString: "FA7268")
    static let text_name = UIColor(hexString: "C4C4C4")
    static let phone_separate = UIColor(hexString: "DCDCDC")
    static let photo_back = UIColor(hexString: "F4F4F4")
    static let photo_alert = UIColor(hexString: "F52D56")
    static let no_purchased_like = UIColor(hexString: "8763E6")
    static let purchased_like = UIColor(hexString: "FA7268")

    static let app_name = "DatingApp"
//    <!--　共通　-->
    static let OK = "OK"
    static let Cancel = "キャンセル"
    static let YES = "はい"
    static let NO = "いいえ"
    static let Delete = "削除"
    static let Save = "保存"
    static let Back = "戻り"
    static let Edit = "編集"
    static let Send = "送信"
    static let next = "次へ"
    static let Connect = "接続"
    static let Register = "登 録"
    static let Exit = "通話終了"

//    <!--　splash画面　-->
    static let splash_logo = "LOGO"
    static let intro = "＊＊のための\nマッチングサービス"
    static let fb_warning = "※Facebookには一切投稿されません"
    static let fb_login_btn = "Facebookでログイン"
    static let phone_login_btn = "電話番号でログイン"
    static let terms = "利用規約"
    static let privacy = "プライバシーポリシー"

//    <!--　phone画面　-->
    static let phone_num = "電話番号"
    static let phone_num_intro = "電話番号を入力してください。SMSで認証コードを送信します。"
    static let sending_code_title = "認証コード送信中"
    static let verifying_code_title = "コード検証中"
    static let location_title = "位置情報取得中"
    static let sending_code_msg = "しばらくお待ちください。"

//    <!--　phone verify画面　-->
    static let phone_verify = "認証コード"
    static let phone_verify_intro = "SMSで認証コードを送信しました。認証コードを入力してください。"
    static let no_sms = "SMSが届かない？"

//    <!--　性別画面　-->
    static let gender_txt = "性別"
    static let gender_intro = "性別を選択してください。"

//    <!--　名前画面　-->
    static let name_txt = "名前"
    static let name_intro = "10文字以内で名前を入力してください。"

//    <!--　生年月日画面　-->
    static let birthday_txt = "生年月日"
    static let birthday_intro = "生年月日を入力してください。"

//    <!--　写真画面　-->
    static let photo_txt = "写真"
    static let photo_intro = "プロフィール写真をアップしてください。"
    static let photo_lert = "写真を追加する"
    static let photo_camera = "カメラ"
    static let photo_cameraroll = "カメラロール"

//    <!--　位置情報画面　-->
    static let location_txt = "位置情報"
    static let location_intro = "アプリを利用するには位置情報をオンにしてください。"

//    <!--　自己紹介画面　-->
    static let intro_txt = "自己紹介"
    static let intro_intro = "プロフィール写真をアップしてください。"


//    <!--　ログイン画面　-->
    static let database_connect_loading = "ログイン中・・・"
    static let webrtc_connect_loading = "接続中・・・"
    static let user_id = "ユーザーID"
    static let password = "パスワード"
    static let login = "ログイン"
    static let input_err_title = "入力エラー"
    static let input_err_msg = "生年月日を正確に入力してください。"
    static let login_err_title = "ログイン失敗"
    static let login_err_msg = "ログインが失敗しました。"
    static let server_connect_error_msg = "データベースサーバーに接続できませんでした。スタンドアロンモードで起動しますか？"
    static let login_err_msg1 = "データベース接続が失敗したため、ログインできません。\nネットワークの状態を確認してください。"
    static let login_err_msg2 = "XMLファイルが存在しないため、ログインできません。\n本アプリを終了し、XMLファイルを追加した後、再度起動してください。"
    static let login_err_msg3 = "本アプリは起動できません。\n本アプリを終了し、XMLファイルを追加した後、再度起動してください。"
    static let select_xml_title = "XMLファイルを選択してください。"
    static let no_xml_title = "エラー"
    static let no_xml_msg = "XMLファイルが存在しません。"
    static let roomname_msg = "room名を入力してください"
    static let setting_msg = "起動方式を選択してください"
    static let setting_auto = "自動"
    static let setting_manual = "手動"
    static let start_msg = "WEBコールチャイム\n\nコール中！"
    static let start_btn = "開 始"

//        <!--　 Detail画面　-->
        static let report = "通報"
        static let report_msg = "このユーザーを通報してもよろしいですか？"
    
//        <!--　 いいね画面　-->
        static let like_num = "いいね！"
    
//        <!--　 課金画面　-->
        static let inapp_close = "閉じる"
        static let inapp_intro_1 = "あなたへのいいね！を見れる"
        static let inapp_intro_2 = "メッセージ無制限"
        static let inapp_intro_3 = "いいね！3倍"
    
//        <!--　 match画面　-->
        static let match_continue = "閲覧を続ける"
        static let match_intro = "マッチしました！今すぐメッセージを送りましょう！"

//        <!--　 Inbox画面　-->
        static let inbox_title = "メッセージ"
        static let inbox_all_tab = "全て"
        static let inbox_match_tab = "マッチ"
        static let inbox_like_num = "いいね"
    
//        <!--　 設定画面　-->
        static let setting_title = "設定"
        static let purchase_title = "有料会員購入"
        static let unpurchase_state = "現在 無料会員"
        static let purchase_state = "現在 有料会員"
        static let show_title = "表示"
        static let filter_title = "フィルター"
        static let notification_title = "通知"
        static let privacy_title = "プライバシーポリシー"
        static let terms_title = "利用規約"
        static let restore_title = "購入を復元"
        static let report_title = "サポート"
        static let passport_title = "身分証明書"
        static let delete_account = "アカウントを削除"
    
//        <!--　 設定画面　-->
        static let profile_title = "プロフィール"
        static let job_title = "職業"
        static let preview_title = "プレビュー"

    static let LIKETITLE = "いいね通知"
    static let LIKEBODY = "さんがあなたをいいねしました。"
    static let MESSAGETITLE = "メッセージ通知"
    static let MESSAGEBODY = "さんから新しいメッセージが到着しました。"
    static let MATCHEDTITLE = "マッチ通知"
    static let MATCHEDBODY = "さんがあなたをマッチしました。"

    //UIConfig
    
    static let SCREEN_WIDTH  = CGFloat(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT = CGFloat(UIScreen.main.bounds.size.height)
    static let SCALE         = SCREEN_WIDTH / 414.0
    static let HEADER_HEIGHT = 70 * SCALE
    static let TABBAR_HEIGHT = 60 * SCALE
    static let NAV_BAR_OFFSET: Int = 50
    
    static let EXPIRED_TIME: NSInteger = 3600 * 72
    static let PER_PAGE: Int = 10
    static let TIMEOUT_TIME: TimeInterval = 10
    
    static let MAXCHARACTER: Int = 500
    static let MAXDATANUM: Int = 50

}
