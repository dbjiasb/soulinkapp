typedef EncHelper = Dic;

class Dic {
  // static String get lumina => Platform.environment['LUMINA'] ?? '';

  static String get id => 'id';
  static String get nm => 'name';
  static String get avt => 'avatar';
  static String get bgurl => 'backgroundurl';

  // Asset Paths
  static const assetsImgDir = 'packages/modules/assets/images';
  static const accountImgDir = '$assetsImgDir/account';

  //
  // static String get vn => 'versionName';
  // static String get userKey => "userIniiusfo".replaceAll('iius', lumina);
  //
  // ///userInfo
  // static String get userBase => "basiiuseInfo".replaceAll('iius', lumina);
  // static String get sessionKey => "chatSesaoussions".replaceAll('aous', lumina);
  //
  // ///sessions
  // static String get msgsKey => "msgItaousems".replaceAll('aous', lumina);
  // static String get syncKey => 'askKey';
  // // static String get targetId => 'targetUid';
  // static String get updateInfo => 'updateUserInfo';
  //
  // ///updateUserInfo
  // static String get thirdName => 'snsName'; ///snsName
  //
  //
  // static String get fuid => 'fromUserId'; //fromUserId
  // static String get tuid => 'toUserId'; //toUserId
  // static String get tguid => 'targetUid'; //targetUid
  // static String get acTy => 'acctType';   //acctType
  // static String get accTy => 'accountType';   //accountType
  // static String get tStatus => 'targetAccountStatus';
  // static String get cStatus => 'chatStatus';
  // static String get foreGround => 'iInApp'; //toUserId
  // static String tgid = 'tarIMAgetUIMAid'.replaceAll('IMA', lumina); //toUserId
  //
  // /// report
  // static String get mmpName => 'adjust'; //adjust
  // static String get mmpId => 'adjustId'; //adjustId
  // static String get mmpDId => 'adjustDeviceId'; //adjustDeviceId
  // static String get mmpData => 'adjustInstallData'; //adjustInstallData
  // static String get mmpType => 'attributionType'; //adjustAttrUpdate
  // /// 数据库列名
  // static String get mt => 'contentType'; //contentType
  // static String get ul => 'unblock'; //unblock
  // static String get by => 'trunk'; //trunk
  // static String get ct => 'spend'; //spend
  // static String get stp => 'spendType'; //spendType
  // static String get jb => 'jsonTrunk'; //jsonTrunk
  // static String get ud => 'unqid'; //unqid
  // static String get rd => 'changeImage'; //update
  //
  // static String get buzz => 'heatInfo'; //heatInfo
  // static String get buzzValue => 'heatValue'; //heatValue
  // static String get ri => 'robotInfo'; //robotInfo
  // static String get mi => 'masterInfo'; //masterInfo
  // static String get cu => 'coverUrl'; //coverUrl
  //
  // static String get mmpTT => 'trackerToken'; //trackerToken
  // static String get mmpTN => 'trackerName'; //trackerName
  // static String get mmpNW => 'network'; //network
  // static String get mmpCP => 'campaign'; //campaign
  // static String get mmpAG => 'adgroup'; //adgroup
  // static String get mmpCR => 'creative'; //creative
  // static String get mmpCL => 'clickLabel'; //clickLabel
  // static String get mmpAD => 'adid'; //adid
  // static String get mmpCT => 'costType'; //costType
  // static String get mmpCA => 'costAmount'; //costAmount
  // static String get mmpCU => 'costCurrency'; //costCurrency
  // static String get mmpFR => 'fbInstallReferrer'; //fbInstallReferrer

  ///upload
  static String get upl_tcKey => 'ossFileKey'; //costAmount
  static String get upl_tcUrl => 'cdnFileUrl'; //costCurrency

  static String get upl_tcId => 'accessKeyId';
  static String get upl_tcSecret => 'accessKeySecret';
  static String get upl_tcBucket => 'bucketName';
  static String get upl_tcST => 'securityToken';

  /// person info
  static String get ps_usif => 'userInfo';
  static String get ps_bsif => 'baseInfo';
  static String get ps_avturl => 'avatarUrl';
  static String get ps_bg => 'chatBackground';
  static String get ps_nn => 'nickName';
  static String get ps_uid => 'uid';
  static String get ps_fsc => 'fansCount';
  static String get ps_foloc => 'followCount';
  static String get ps_gdr => 'gender';
  static String get ps_bfda => 'birthday';
  static String get ps_ag => 'age';
  static String get ps_cstat => 'constellation';
  static String get ps_lct => 'location';
  static String get ps_educat => 'educations';
  static String get ps_bo => 'bio';
  static String get ps_str => 'star';
  static String get ps_act => 'accountType';
  static String get psid => 'personId';
  static String get ps_if => 'personInfo';
  static String get ps_cvurl => 'coverUrl';

  // /// chat
  // static String get exCon => 'extraContent';
  //
  //
  // /// JS relate
  // static String get returnJSMethod => 'receiveMessage'; ///receiveMessage
  //
  /// Create
  static String get cr_pesi => 'Pessimistic'; //Pessimistic
  static String get cr_cfg => 'configItemMap'; //configItemMap
  static String get cr_dis_cfg => 'displayConfig'; //displayConfig
  static String get cr_apr => 'appearance'; //appearance
  static String get cr_exim => 'expandItems'; //expandItems
  static String get cr_tbs => 'tagBgList'; //tagBgList
  static String get cr_eurl => 'exampleUrl'; //exampleUrl
  static String get cr_tvid => 'ttsVid'; //ttsVid
  static String get cr_tcfg => 'ttsConfig'; //ttsConfig
  static String get cr_piurl => 'personalImageurl'; //personalImageurl
  static String get cr_alts => 'dialogueStyle'; //dialogueStyle
  static String get cr_fields => 'foldItems'; //foldItems
  static String get cr_ownern => 'masterName'; //masterName
  static String get cr_imgpm => 'imagePrompts'; //imagePrompts
  static String get cr_bio => 'introduction'; //introduction
  static String get cr_caa => 'Click to add '; //Click to add
  static String get cr_cusri => 'customRoleInfo'; //customRoleInfo
  static String get cr_posinf => 'positionInfo'; //positionInfo
  static String get cr_defval2 => 'defaultValueV2'; //defaultValueV2
  static String get cr_img_prp => 'Image Prompt'; //Image Prompt
  static String get cr_synopsis => 'Scenario'; //Scenario
  static String get cr_dl_sl => 'Dialogue Style'; //Dialogue Style

  // API 接口（每个单词插入不同混淆词）
  static String get cr_fod => 'queryOcDraft'; // queryOcDraft
  static String get cr_fpd => 'queryPhysiqueDetails'; // queryPhysiqueDetails
  static String get cr_ckpic => 'checkPic'; // checkPic
  static String get cr_opr => 'operateOc'; // operateOc
  static String get cr_askgen => 'requestGen'; // requestGen
  static String get cr_ask_gen_rsp => 'requestGenResult'; // requestGenResult
  static String get cr_fed => 'queryEditInfo'; // queryEditInfo

  // 参数映射（每个单词插入不同混淆词）
  static String get cr_img_url => 'picUrl'; // picUrl
  static String get cr_ro_in => 'ocData'; // ocData
  static String get cr_cr_code => 'opCode'; // opCode
  static String get cr_imgs => 'pics'; // pics
  static String get cr_rl_id => 'replaceId'; // replaceId
  static String get cr_cre_code => 'genCode'; // genCode
  static String get cr_cre_id => 'genId'; // genId
  static String get cr_cccid => 'cid'; // cid

  ///account view
  static String get ac_uid => 'uid'; // uid
  static String get ac_nn => 'nickname'; // nickname
  static String get ac_avt => 'avatarUrl'; // avatarUrl
  static String get ac_cvu => 'coverUrl'; // coverUrl

  /// recharge
  // Common Images
  static String get rcg_icBk => '$assetsImgDir/icon_back.png'; // ic_back.png

  // Coin Assets
  static String get rcg_coiImg => '$assetsImgDir/coin.png'; // coin.png
  static String get rcg_coiBg => '$accountImgDir/coin_bg.png'; // coin_bg.png

  // Gem Assets
  static String get rcg_gmImg => '$assetsImgDir/gem.png'; // gem.png
  static String get rcg_gmBg => '$accountImgDir/gem_bg.png'; // gem_bg.png

  // Premium Assets
  static String get rcg_premBg => '$accountImgDir/premium_rcg_bg.png'; // premium_rcg_bg.png
  static String get rcg_avtBg => '$accountImgDir/premium_rcg_avatarbg.png'; // premium_rcg_avatarbg.png
  static String get rcg_bnfHedr => '$accountImgDir/premium_rcg_bnfheader.png'; // premium_rcg_bnfheader.png

  // UI Texts
  static String get rcg_titlCois => 'Coins'; // Coins
  static String get rcg_titlGms => 'Gems'; // Gems
  static String get rcg_coiBalns => 'Coin balance'; // Coin balance
  static String get rcg_gmBalns => 'Gem balance'; // Gem balance
  static String get rcg_btnRcg => 'Recharge'; // Recharge
  static String get rcg_btnSubs => 'Subscribe'; // Subscribe
  static String get rcg_fuAces => 'Get full access!'; // Get full access!
  static String get rcg_expOn => 'Expires on '; // Expires on
  static String get rcg_err => 'error'; // error
  static String get rcg_prc => 'price'; // price
  static String get rcg_rcg => 'Recharge'; // Recharge
  static String get rcg_nm => 'name'; // name
  static String get rcg_chnlInfo => 'channelInfo'; // channelInfo
  static String get rcg_adrCnnl => '2'; // 2
  static String get rcg_iosChnnl => '3'; // 3
  static String get rcg_inapId => 'inAppProductId'; // inAppProductId
  static String get rcg_ov => 'originalValue'; // originalValue
  static String get rcg_dsct => 'discount'; // discount

  // Arhs
  static String get rcg_rcgItm => 'rechargeItem'; // rechargeItem
  static String get rcg_rcgTyp => 'rcgType'; // rechargeType
  static String get rcg_id => 'id'; // id
  static String get rcg_valu => 'value'; // value
  static String get rcg_ppt => 'premiumPeriodType'; // premiumPeriodType
  static String get rcg_bdesc => 'benefitsDesc'; // benefitsDesc
  static String get rcg_titl => 'title'; // title
  static String get rcg_url => 'url'; // url
  static String get rcg_cfg => 'config'; // config

  // Apis
  static String get rcg_apiGPV2 => 'getPremiumInfoV2'; // getPremiumInfoV2

  // Legal Texts
  static String get rcg_trmNotic =>
      'By clicking "Subscribe", you will be charged, and your subscription will automatically renew at the same price and duration until canceled through PlayStore settings. By proceeding, you agree to our terms.';
  static String get rcg_trms => 'Terms of Service'; // Terms of Service
  static String get rcg_privacy => 'Privacy Policy'; // Privacy Policy

  // Error Messages
  static String get rcg_errLoData => 'Failed to load subscription data'; // Failed to load subscription data
  static String get rcg_errSeleProd => 'Please select a product to recharge.'; // Please select a product to recharge.
  static String get rcg_prchasDon => 'Purchase done'; // Purchase done
  static String get rcg_errSrvic => 'Unable to get recharge service, please retry later.'; // Unable to get recharge service, please retry later.
  static String get rcg_errPlafm => 'Platform not supported.'; // Platform not supported.
  static String get rcg_errRcg => 'Recharge failed.'; // Recharge failed.
  static String get rcg_errSubs => 'Failed to process subscription, please try again later.'; // Failed to process subscription, please try again later.

  // URLs
  static String get rcg_urlTrms => 'https://cdn.luminaai.buzz/lumina/termsofservice.html'; // https://cdn.luminaai.buzz/lumina/termsofservice.html
  static String get rcg_urlPrivacy => 'https://cdn.luminaai.buzz/lumina/privacy.html'; // https://cdn.luminaai.buzz/lumina/privacy.html

  // IAP Products
  static String get rcg_iapWekly => 'com.lumina.pro_weekly'; // com.lumina.pro_weekly
  static String get rcg_iapMthly => 'com.lumina.pro_monthly'; // com.lumina.pro_monthly
  static String get rcg_iapYrly => 'com.lumina.pro_yearly'; // com.lumina.pro_yearly

  static List get rcg_coiProds => [
    {'id': 'com.lumina.coin_9.99', 'price': '\$9.99', 'value': 1000},
    {'id': 'com.lumina.coin_29.99', 'price': '\$29.99', 'value': 3000},
    {'id': 'com.lumina.coin_99.99', 'price': '\$99.99', 'value': 10000},
  ];

  static List get rcg_gmProds => [
    {'id': 'com.lumina.gem_9.99', 'price': '\$9.99', 'value': 80},
    {'id': 'com.lumina.gem_29.99', 'price': '\$29.99', 'value': 240},
    {'id': 'com.lumina.gem_99.99', 'price': '\$99.99', 'value': 800},
  ];

  // Helper Methods
  static String rcg_savPct(int pct) => 'Save $pct%';
  static String rcg_dailyPrc(double price) => '\$$price/day';
  static String rcg_geRcgBg(int rcgType) => rcgType == 0 ? rcg_coiBg : rcg_gmBg;
  static String rcg_geRcgBalns(int rcgType) => rcgType == 0 ? rcg_coiBalns : rcg_gmBalns;
}
