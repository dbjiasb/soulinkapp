//生成一个枚举，表示页面路由名称，值为字符串
enum Routers {
  login('/login'),
  root('/skeleton'),
  chat('/chat'),
  call('/call'),
  webView('/webView'),
  home('/home'),
  setting('/setting'),
  loginChannel('/loginChannel'),
  rechargeCurrency('/recharge/currency'),
  rechargePremium('/recharge/premium'),
  editMe('/edit_me'),
  person('/chat/person'),
  imageBrowser('/imageBrowser'),
  videoPlayer('/videoPlayer'),
  create('/create'),
  createBasic('/create/basic'),
  createAdvance('/create/advance'),
  createVoice('/create/basic/voice'),
  createGen('/create/gen'),
  chatHistory('/chatHistory');

  final String name;

  const Routers(this.name);
}
