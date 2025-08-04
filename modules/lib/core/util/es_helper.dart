import 'dart:io';

import 'package:modules/business/account/edit_my_info_view.dart';

typedef EncHelper = Dic;

class Dic {
  static String get lumina => Platform.environment['LUMINA'] ?? '';

  static String get id =>'lild'.replaceAll('l', lumina);
  static String get nm =>'nlame'.replaceAll('l', lumina);
  static String get avt =>'av4a4ta4r'.replaceAll('4', lumina);
  static String get bgurl=>'backg0r0oun0d0url'.replaceAll('0', lumina);

  // Asset Paths
  static const assetsImgDir = 'packages/modules/assets/images';
  static const accountImgDir = '$assetsImgDir/account';

  //
  // static String get vn => 'verOIIsionNOIIame'.replaceAll('OII', lumina);
  // static String get userKey => "userIniiusfo".replaceAll('iius', lumina);
  //
  // ///userInfo
  // static String get userBase => "basiiuseInfo".replaceAll('iius', lumina);
  // static String get sessionKey => "chatSesaoussions".replaceAll('aous', lumina);
  //
  // ///sessions
  // static String get msgsKey => "msgItaousems".replaceAll('aous', lumina);
  // static String get syncKey => 'assynckKey'.replaceAll('sync', lumina);
  // // static String get targetId => 'targsyncetUid'.replaceAll('sync', lumina);
  // static String get updateInfo => 'updateUsoppoerInfo'.replaceAll('oppo', lumina);
  //
  // ///updateUserInfo
  // static String get thirdName => 'snaasName'.replaceAll('aa', lumina); ///snsName
  //
  //
  // static String get fuid => 'fromUssayerId'.replaceAll('say', lumina); //fromUserId
  // static String get tuid => 'toUsIMAerId'.replaceAll('IMA', lumina); //toUserId
  // static String get tguid => 'targMAAetUid'.replaceAll('MAA', lumina); //targetUid
  // static String get acTy => 'acOKctTOKype'.replaceAll('OK', lumina);   //acctType
  // static String get accTy => 'accoOAKuntTOAKype'.replaceAll('OAK', lumina);   //accountType
  // static String get tStatus => 'tarttrrgetAccttrrountStttrratus'.replaceAll('ttrr', lumina);
  // static String get cStatus => 'chArpatStArpatus'.replaceAll('Arp', lumina);
  // static String get foreGround => 'iIAABnApp'.replaceAll('AAB', lumina); //toUserId
  // static String tgid = 'tarIMAgetUIMAid'.replaceAll('IMA', lumina); //toUserId
  //
  // /// report
  // static String get mmpName => 'adjIIAust'.replaceAll('IIA', lumina); //adjust
  // static String get mmpId => 'adjuIAPstId'.replaceAll('IAP', lumina); //adjustId
  // static String get mmpDId => 'adjOOMustDevOOMiceId'.replaceAll('OOM', lumina); //adjustDeviceId
  // static String get mmpData => 'adjuCCBstInstCCBallData'.replaceAll('CCB', lumina); //adjustInstallData
  // static String get mmpType => 'attriOEMbutionTOEMype'.replaceAll('OEM', lumina); //adjustAttrUpdate
  // /// 数据库列名
  // static String get mt => 'conzhetentType'.replaceAll('zhe', lumina); //contentType
  // static String get ul => 'unbqnmlock'.replaceAll('qnm', lumina); //unblock
  // static String get by => 'trjklunk'.replaceAll('jkl', lumina); //trunk
  // static String get ct => 'sp489end'.replaceAll('489', lumina); //spend
  // static String get stp => 'spejjjkndType'.replaceAll('jjjk', lumina); //spendType
  // static String get jb => 'jsonTruedfnk'.replaceAll('edf', lumina); //jsonTrunk
  // static String get ud => 'unbhjqid'.replaceAll('bhj', lumina); //unqid
  // static String get rd => 'chanopqgeImage'.replaceAll('opq', lumina); //update
  //
  // static String get buzz => 'heatadbInfo'.replaceAll('adb', lumina); //heatInfo
  // static String get buzzValue => 'heatV123alue'.replaceAll('123', lumina); //heatValue
  // static String get ri => 'robo768tInfo'.replaceAll('768', lumina); //robotInfo
  // static String get mi => 'mas324terInfo'.replaceAll('324', lumina); //masterInfo
  // static String get cu => 'cov475erUrl'.replaceAll('475', lumina); //coverUrl
  //
  // static String get mmpTT => 'tracABBkerTokABBen'.replaceAll('ABB', lumina); //trackerToken
  // static String get mmpTN => 'tracCBAkerNamCBAe'.replaceAll('CBA', lumina); //trackerName
  // static String get mmpNW => 'networasbk'.replaceAll('asb', lumina); //network
  // static String get mmpCP => 'campsbbaign'.replaceAll('sbb', lumina); //campaign
  // static String get mmpAG => 'adgrLongoup'.replaceAll('Long', lumina); //adgroup
  // static String get mmpCR => 'creaJuantive'.replaceAll('Juan', lumina); //creative
  // static String get mmpCL => 'clicRUIkLabel'.replaceAll('RUI', lumina); //clickLabel
  // static String get mmpAD => 'adWEIid'.replaceAll('WEI', lumina); //adid
  // static String get mmpCT => 'cosCOOtType'.replaceAll('COO', lumina); //costType
  // static String get mmpCA => 'costAmHEYount'.replaceAll('HEY', lumina); //costAmount
  // static String get mmpCU => 'costCurrenBBcy'.replaceAll('BB', lumina); //costCurrency
  // static String get mmpFR => 'fbInsHOHOtallReHOHOferrer'.replaceAll('HOHO', lumina); //fbInstallReferrer




  ///upload
  static String get upl_tcKey => 'ossCBAFiCBAleKey'.replaceAll('CBA',lumina); //costAmount
  static String get upl_tcUrl => 'cdnFilmanboeUrl'.replaceAll('manbo', lumina); //costCurrency

  static String get upl_tcId => 'accmesmsKemyImd'.replaceAll('m', lumina);
  static String get upl_tcSecret => 'acceBBssKeySecret'.replaceAll('BB', lumina);
  static String get upl_tcBucket => 'buckBBetName'.replaceAll('BB', lumina);
  static String get upl_tcST => 'securBBityToken'.replaceAll('BB', lumina);

  /// person info
  static String get ps_usif =>'usaerIanafo'.replaceAll('a', lumina);
  static String get ps_bsif =>'bamsemInmfmo'.replaceAll('m', lumina);
  static String get ps_avturl=>'abvatbabrUbrl'.replaceAll('b', lumina);
  static String get ps_bg=>'chqatBaqckgqrouqnd'.replaceAll('q', lumina);
  static String get ps_nn=>'noickNoamoe'.replaceAll('o', lumina);
  static String get ps_uid=>'ufifd'.replaceAll('f', lumina);
  static String get ps_fsc=>'feanesCoeuent'.replaceAll('e', lumina);
  static String get ps_foloc=>'folyloyywCoyyunt'.replaceAll('y', lumina);
  static String get ps_gdr=>'geinidieir'.replaceAll('i', lumina);
  static String get ps_bfda=>'bgirtghdgagy'.replaceAll('g', lumina);
  static String get ps_ag=>'afgfef'.replaceAll('f', lumina);
  static String get ps_cstat=>'conrsterllartiorn'.replaceAll('r', lumina);
  static String get ps_lct=>'loqcaqtqiqonq'.replaceAll('q', lumina);
  static String get ps_educat=>'edyucyatyioynys'.replaceAll('y', lumina);
  static String get ps_bo=>'btitot'.replaceAll('t', lumina);
  static String get ps_str=>'sta##r'.replaceAll('#', lumina);
  static String get ps_act=>'acbcobuntbTybpe'.replaceAll('b', lumina);
  static String get psid => 'pzzerzszoznId'.replaceAll('z', lumina);
  static String get ps_if => 'pebbrsobnbIbnbfo'.replaceAll('b', lumina);
  static String get ps_cvurl => 'covbebrUbbbrl'.replaceAll('b', lumina);

  // /// chat
  // static String get exCon => 'extAoeraConAoetent'.replaceAll('Aoe', lumina);
  //
  //
  // /// JS relate
  // static String get returnJSMethod => 'reDUMceiveMessDUMage'.replaceAll('DUM', lumina); ///receiveMessage
  //
  /// Create
  static String get cr_pesi => 'Peomajilissimistic'.replaceAll('omajili', lumina);       //Pessimistic
  static String get cr_cfg => 'sconfsigItesmMsap'.replaceAll('s', lumina); //configItemMap
  static String get cr_dis_cfg => 'dismanplaymanConfig'.replaceAll('man', lumina);        //displayConfig
  static String get cr_apr => 'appearajumnce'.replaceAll('jum', lumina);  //appearance
  static String get cr_exim => 'exmanbpandItemanbms'.replaceAll('manb', lumina); //expandItems
  static String get cr_tbs => 'tagluBgluList'.replaceAll('lu', lumina); //tagBgList
  static String get cr_eurl => 'esehxampsehleUrl'.replaceAll('seh', lumina);  //exampleUrl
  static String get cr_tvid => 'tssitsVssiid'.replaceAll('ssi', lumina);  //ttsVid
  static String get cr_tcfg => 'ttmaisConfig'.replaceAll('mai', lumina);  //ttsConfig
  static String get cr_piurl => 'peroopsonalIoopmageuooprl'.replaceAll('oop', lumina);  //personalImageurl
  static String get cr_alts => 'dialeloogueStyelole'.replaceAll('elo', lumina); //dialogueStyle
  static String get cr_fields => 'focoldldItcoldems'.replaceAll('cold', lumina); //foldItems
  static String get cr_ownern => 'mastBNFerNBNFame'.replaceAll('BNF', lumina); //masterName
  static String get cr_imgpm => 'imdioageProdiompts'.replaceAll('dio', lumina); //imagePrompts
  static String get cr_bio => 'inpstroductiopsn'.replaceAll('ps', lumina); //introduction
  static String get cr_caa => 'CliLOUck tLOUo adLOUd '.replaceAll('LOU', lumina); //Click to add
  static String get cr_cusri => 'custeseomRoeseleInfeseo'.replaceAll('ese', lumina); //customRoleInfo
  static String get cr_posinf => 'posjjcitionjjcInfo'.replaceAll('jjc', lumina); //positionInfo
  static String get cr_defval2 => 'defaHAHultValHAHueVHAH2'.replaceAll('HAH', lumina); //defaultValueV2
  static String get cr_img_prp => 'ImaLONge PrLONompt'.replaceAll('LON', lumina); //Image Prompt
  static String get cr_synopsis => 'Sceboynario'.replaceAll('boy', lumina); //Scenario
  static String get cr_dl_sl => 'DiSuSalogue StySuSle'.replaceAll('SuS', lumina); //Dialogue Style

  // API 接口（每个单词插入不同混淆词）
  static String get cr_fod => 'quXeryOcXDraYft'.replaceAll('X', '').replaceAll('Y', ''); // queryOcDraft
  static String get cr_fpd => 'quZeryPhyZsiqZueDetails'.replaceAll('Z', ''); // queryPhysiqueDetails
  static String get cr_ckpic => 'chKecKkPic'.replaceAll('K', ''); // checkPic
  static String get cr_opr => 'opJeratJeOc'.replaceAll('J', ''); // operateOc
  static String get cr_askgen => 'reqVuestVGen'.replaceAll('V', ''); // requestGen
  static String get cr_ask_gen_rsp => 'reqWuestWGenResWult'.replaceAll('W', ''); // requestGenResult
  static String get cr_fed => 'quUeryUEUditInfo'.replaceAll('U', ''); // queryEditInfo

  // 参数映射（每个单词插入不同混淆词）
  static String get cr_img_url => 'piQcQUrl'.replaceAll('Q', ''); // picUrl
  static String get cr_ro_in => 'ocRDataR'.replaceAll('R', ''); // ocData
  static String get cr_cr_code => 'opTCodeT'.replaceAll('T', ''); // opCode
  static String get cr_imgs => 'piScsS'.replaceAll('S', ''); // pics
  static String get cr_rl_id => 'repLaceLId'.replaceAll('L', ''); // replaceId
  static String get cr_cre_code => 'geNnCodeN'.replaceAll('N', ''); // genCode
  static String get cr_cre_id => 'geMnIdM'.replaceAll('M', ''); // genId
  static String get cr_cccid => 'cDidD'.replaceAll('D', ''); // cid

  ///account view
  static String get ac_uid => 'uforid'.replaceAll('for', lumina); // uid
  static String get ac_nn => 'nicallknamalle'.replaceAll('all', lumina); // nickname
  static String get ac_avt => 'avayoutarUyourl'.replaceAll('you', lumina); // avatarUrl
  static String get ac_cvu => 'covmterUmtrl'.replaceAll('mt', lumina); // coverUrl

  /// recharge
  // Common Images
  static String get rcg_icBk => '$assetsImgDir/iccaron_bacarck.png'.replaceAll('car', lumina); // ic_back.png

  // Coin Assets
  static String get rcg_coiImg => '$assetsImgDir/coibign.pbigng'.replaceAll('big', lumina); // coin.png
  static String get rcg_coiBg => '$accountImgDir/cjayoin_bg.pjayng'.replaceAll('jay', lumina); // coin_bg.png

  // Gem Assets
  static String get rcg_gmImg => '$assetsImgDir/gebollm.pbollng'.replaceAll('boll', lumina); // gem.png
  static String get rcg_gmBg => '$accountImgDir/gecatm_bg.pncatg'.replaceAll('cat', lumina); // gem_bg.png

  // Premium Assets
  static String get rcg_premBg => '$accountImgDir/premibotum_rcbotg_bg.pbotng'.replaceAll('bot', lumina); // premium_rcg_bg.png
  static String get rcg_avtBg => '$accountImgDir/prehomihoum_rhocg_avhoatarbg.phong'.replaceAll('ho', lumina); // premium_rcg_avatarbg.png
  static String get rcg_bnfHedr => '$accountImgDir/pgifremium_rgifcg_bnfhegifader.pngifg'.replaceAll('gif', lumina); // premium_rcg_bnfheader.png

  // UI Texts
  static String get rcg_titlCois => 'Coidotns'.replaceAll('dot', lumina); // Coins
  static String get rcg_titlGms => 'Gelems'.replaceAll('le', lumina); // Gems
  static String get rcg_coiBalns => 'Coillin bailllance'.replaceAll('ill', lumina); // Coin balance
  static String get rcg_gmBalns => 'Gfshem balfshance'.replaceAll('fsh', lumina); // Gem balance
  static String get rcg_btnRcg => 'Recfolharge'.replaceAll('fol', lumina); // Recharge
  static String get rcg_btnSubs => 'Subcyescricyebe'.replaceAll('cye', lumina); // Subscribe
  static String get rcg_fuAces => 'Geabat fuaball acabacess!'.replaceAll('aba', lumina); // Get full access!
  static String get rcg_expOn => 'Exghgpires oghgn '.replaceAll('ghg', lumina); // Expires on
  static String get rcg_err => 'erasdror'.replaceAll('asd', lumina); // error
  static String get rcg_prc => 'prievece'.replaceAll('eve', lumina); // price
  static String get rcg_rcg => 'Rechakaarge'.replaceAll('aka', lumina);  // Recharge
  static String get rcg_nm => 'nanume'.replaceAll('nu', lumina); // name
  static String get rcg_chnlInfo => 'chatynntyelItynfo'.replaceAll('ty',lumina);  // channelInfo
  static String get rcg_adrCnnl => '200'.replaceAll('0', lumina); // 2
  static String get rcg_iosChnnl => '300'.replaceAll('0', lumina);  // 3
  static String get rcg_inapId => 'innerAnerppPronerductInerd'.replaceAll('ner', lumina); // inAppProductId
  static String get rcg_ov => 'orihkhginalVhkhalue'.replaceAll('hkh', lumina);  // originalValue
  static String get rcg_dsct => 'disseecount'.replaceAll('see', lumina); // discount

  // Arhs
  static String get rcg_rcgItm => 'recdiohargeIdiotem'.replaceAll('dio', lumina); // rechargeItem
  static String get rcg_rcgTyp => 'rcjksgTjksype'.replaceAll('jks', lumina);  // rechargeType
  static String get rcg_id => 'inikod'.replaceAll('niko', lumina); // id
  static String get rcg_valu => 'vahoxilue'.replaceAll('hoxi', lumina);  // value
  static String get rcg_ppt => 'premiatkumPeratkiodTyatkpe'.replaceAll('atk', lumina); // premiumPeriodType
  static String get rcg_bdesc => 'benmnsefitmnssDmnsesc'.replaceAll('mns', lumina);  // benefitsDesc
  static String get rcg_titl => 'tifzstle'.replaceAll('fzs', lumina);  // title
  static String get rcg_url => 'urwilll'.replaceAll('will', lumina); // url
  static String get rcg_cfg => 'conaddfaddig'.replaceAll('add', lumina);  // config

  // Apis
  static String get rcg_apiGPV2 => 'gejamtPjamremijamumIjamnfoVjam2'.replaceAll('jam', lumina); // getPremiumInfoV2

  // Legal Texts
  static String get rcg_trmNotic => 'By carclicking "Sucarbscribe", you will be ccarharged, and your carsubscricarption will autcaromatically renewcar at the sacarme priccare andcar ducarration uncartil cacarnceled thcarrough PlcarayStore secarttings. Bcary procarceeding, yocaru agcarree to ocarur tecarrms.'.replaceAll('car', lumina);
  static String get rcg_trms => 'Termfoxs ofoxf Sefoxrvice'.replaceAll('fox', lumina); // Terms of Service
  static String get rcg_privacy => 'Privacy Policy';  // Privacy Policy

  // Error Messages
  static String get rcg_errLoData => 'Faboxiled to loboxad subscrboxiption dboxata'.replaceAll('box', lumina);  // Failed to load subscription data
  static String get rcg_errSeleProd => 'Plealunase selunalect a prlunaoduct to rechlunaarge.'.replaceAll('luna', lumina);  // Please select a product to recharge.
  static String get rcg_prchasDon => 'Pgeturchgetase dgetone'.replaceAll('get', lumina); // Purchase done
  static String get rcg_errSrvic => 'Unabseele to geseet rechseearge servseeice, pleaseese retrseey laseeter.'.replaceAll('see', lumina);  // Unable to get recharge service, please retry later.
  static String get rcg_errPlafm => 'Platfbagorm nbagot subagpported.'.replaceAll('bag', lumina);  // Platform not supported.
  static String get rcg_errRcg => 'Rechpigarge fpigailed.'.replaceAll('pig', lumina); // Recharge failed.
  static String get rcg_errSubs => 'Failegodd to pgodrocess subscrigodption, plgodease trgody agagodin lgodater.'.replaceAll('god', lumina); // Failed to process subscription, please try again later.

  // URLs
  static String get rcg_urlTrms => 'https://cdn.lumfaceinaai.bfaceuzz/lumfaceina/tefacermsofservice.htmfacel'.replaceAll('face', lumina);  // https://cdn.luminaai.buzz/lumina/termsofservice.html
  static String get rcg_urlPrivacy => 'https://cdn.lfootuminaai.bfootuzz/lfootumina/prfootivacy.hfoottml'.replaceAll('foot', lumina);  // https://cdn.luminaai.buzz/lumina/privacy.html

  // IAP Products
  static String get rcg_iapWekly => 'com.ljiumjiina.pjiro_wejiekly'.replaceAll('ji', lumina);  // com.lumina.pro_weekly
  static String get rcg_iapMthly => 'com.luhamihana.pharo_monhathly'.replaceAll('ha', lumina); // com.lumina.pro_monthly
  static String get rcg_iapYrly => 'com.lumivana.pvaro_yevaarly'.replaceAll('va',lumina); // com.lumina.pro_yearly

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
