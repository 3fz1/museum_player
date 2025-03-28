import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { font } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';

@Extend(Text)
function style(TextAlign: TextAlign) {
  .textAlign(TextAlign)
  .fontSize(18)
  // .fontStyle(0)
  .border({ width: 0 })
  // .padding(10)
  .width('100%')
  // .margin(1)
}

// let video: string = "man2";
// let selection: number = 1;

async function get_video():Promise<number> {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用
  return new Promise<number>((resolve, reject) => {
    let httpRequest = http.createHttp();
    let select: number = 1;
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
      "http://120.46.75.132:8080/app/get_video?device=1",
      {
        method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
        // 开发者根据自身业务需要添加header字段
        header: {
          'Content-Type': 'application/json'
        },
        // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
        extraData: "",
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: true, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: 60000, // 可选，默认为60000ms
        readTimeout: 60000, // 可选，默认为60000ms
        usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
        usingProxy: false, // 可选，默认不使用网络代理，自API 10开始支持该属性
        caPath: '/path/to/cacert.pem', // 可选，默认使用系统预制证书，自API 10开始支持该属性
        clientCert: {
          // 可选，默认不使用客户端证书，自API 11开始支持该属性
          certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性
          keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性
          certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性
          keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性
        }
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析

        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
        // 当该请求使用完毕时，调用destroy方法主动销毁
        select = JSON.parse(JSON.stringify(data.result));
        console.info('selection:' + (select));
        resolve(select)
        httpRequest.off('headersReceive');
        httpRequest.destroy();
      } else {
        console.error('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
        reject(0);
      }
    }
    );
  });
}
function control_device(volume: number, play_speed: number) {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用。
  let httpRequest = http.createHttp();
  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息。
  // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
  httpRequest.on('headersReceive', (header: Object) => {
    console.info('header: ' + JSON.stringify(header));
  });

  httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定。
    "http://120.46.75.132:8080/app/control",
    {
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET。
      // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定。
      extraData: '{\n' +
        '    "volume": '+volume+',\n' +
        '    "play_speed": '+play_speed+'\n' +
        '}',
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型。
      usingCache: true, // 可选，默认为true。
      priority: 1, // 可选，默认为1。
      // 开发者根据自身业务需要添加header字段。
      header: { 'Accept': 'application/json' },
      readTimeout: 60000, // 可选，默认为60000ms。
      connectTimeout: 60000, // 可选，默认为60000ms。
      usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定。
      usingProxy: false, //可选，默认不使用网络代理，自API 10开始支持该属性。
      caPath: '/path/to/cacert.pem', // 可选，默认使用系统预设CA证书，自API 10开始支持该属性。
      clientCert: {
        // 可选，默认不使用客户端证书，自API 11开始支持该属性。
        certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性。
        keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性。
        certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性。
        keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性。
      },
      certificatePinning: [// 可选，支持证书锁定配置信息的动态设置，自API 12开始支持该属性。
        {
          publicKeyHash: 'Pin1', // 由应用传入的证书PIN码，自API 12开始支持该属性。
          hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
        }, {
        publicKeyHash: 'Pin2', // 由应用传入的证书PIN码，自API 12开始支持该属性。
        hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
      }
      ]
    },
    (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        console.info('type:' + JSON.stringify(data.resultType));
        // data.header为HTTP响应头，可根据业务需要进行解析。
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 自API version 8开始支持cookie。
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      } else {
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    });
}
function play_from_start(device: number) {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用。
  let httpRequest = http.createHttp();
  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息。
  // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
  httpRequest.on('headersReceive', (header: Object) => {
    console.info('header: ' + JSON.stringify(header));
  });

  httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定。
    "http://120.46.75.132:8080/app/replay",
    {
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET。
      // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定。
      extraData: '{\n' +
        '    "device":' + device + '\n' +
        '}',
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型。
      usingCache: true, // 可选，默认为true。
      priority: 1, // 可选，默认为1。
      // 开发者根据自身业务需要添加header字段。
      header: { 'Accept': 'application/json' },
      readTimeout: 60000, // 可选，默认为60000ms。
      connectTimeout: 60000, // 可选，默认为60000ms。
      usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定。
      usingProxy: false, //可选，默认不使用网络代理，自API 10开始支持该属性。
      caPath: '/path/to/cacert.pem', // 可选，默认使用系统预设CA证书，自API 10开始支持该属性。
      clientCert: {
        // 可选，默认不使用客户端证书，自API 11开始支持该属性。
        certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性。
        keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性。
        certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性。
        keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性。
      },
      certificatePinning: [// 可选，支持证书锁定配置信息的动态设置，自API 12开始支持该属性。
        {
          publicKeyHash: 'Pin1', // 由应用传入的证书PIN码，自API 12开始支持该属性。
          hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
        }, {
        publicKeyHash: 'Pin2', // 由应用传入的证书PIN码，自API 12开始支持该属性。
        hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
      }
      ]
    },
    (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        console.info('type:' + JSON.stringify(data.resultType));
        // data.header为HTTP响应头，可根据业务需要进行解析。
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 自API version 8开始支持cookie。
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      } else {
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    });
}
function play_video(device:number,video: string) {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用。
  let httpRequest = http.createHttp();
  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息。
  // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
  httpRequest.on('headersReceive', (header: Object) => {
    console.info('header: ' + JSON.stringify(header));
  });

  httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定。
    "http://120.46.75.132:8080/app/video",
    {
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET。
      // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定。
      extraData: '{\n' +
        '    "device": '+device+',\n' +
        '    "video": "'+video+'"\n' +
        '}',
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型。
      usingCache: true, // 可选，默认为true。
      priority: 1, // 可选，默认为1。
      // 开发者根据自身业务需要添加header字段。
      header: { 'Accept': 'application/json' },
      readTimeout: 60000, // 可选，默认为60000ms。
      connectTimeout: 60000, // 可选，默认为60000ms。
      usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定。
      usingProxy: false, //可选，默认不使用网络代理，自API 10开始支持该属性。
      caPath: '/path/to/cacert.pem', // 可选，默认使用系统预设CA证书，自API 10开始支持该属性。
      clientCert: {
        // 可选，默认不使用客户端证书，自API 11开始支持该属性。
        certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性。
        keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性。
        certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性。
        keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性。
      },
      certificatePinning: [// 可选，支持证书锁定配置信息的动态设置，自API 12开始支持该属性。
        {
          publicKeyHash: 'Pin1', // 由应用传入的证书PIN码，自API 12开始支持该属性。
          hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
        }, {
        publicKeyHash: 'Pin2', // 由应用传入的证书PIN码，自API 12开始支持该属性。
        hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性。
      }
      ]
    },
    (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        console.info('type:' + JSON.stringify(data.resultType));
        // data.header为HTTP响应头，可根据业务需要进行解析。
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 自API version 8开始支持cookie。
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      } else {
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    });
}

@Entry
@Component
struct ImageExample1 {
  @State changeTextAlignIndex: number = 0;
  @State changeDecorationIndex: number = 0;
  @State TextAlign: TextAlign[] = [TextAlign.Start, TextAlign.Center, TextAlign.End];
  @State TextAlignStr: string[] = ['Start', 'Center', 'End'];
  @State TextDecorationType: TextDecorationType[] =
    [TextDecorationType.LineThrough, TextDecorationType.Overline, TextDecorationType.Underline];
  @State TextDecorationTypeStr: string[] = ['LineThrough', 'Overline', 'Underline'];
  @State TextDecorationStyle: TextDecorationStyle[] =
    [TextDecorationStyle.SOLID, TextDecorationStyle.DOTTED, TextDecorationStyle.WAVY];
  @State TextDecorationStyleStr: string[] = ['SOLID', 'DOTTED', 'WAVY'];
  @State isShow: boolean = false
  scroller: Scroller = new Scroller();
  @State selection: number = 1;
  @State video_choice: string = "man1";
  @State btn_play_from_start: number = 0;

  aboutToAppear() {
    // 注册黑色斜字体
    font.registerFont({
      familyName: 'timesi', // 注册的字体名称
      familySrc: '/font/timesi.ttf' // font文件夹与pages目录同级
    })

    font.registerFont({
      familyName: 'hy55', // 注册的字体名称
      familySrc: '/font/HYRunYuan-55W.ttf' // font文件夹与pages目录同级
    })

    font.registerFont({
      familyName: 'hy75', // 注册的字体名称
      familySrc: '/font/HYRunYuan-75W.ttf' // font文件夹与pages目录同级
    })

    font.registerFont({
      familyName: 'hy65', // 注册的字体名称
      familySrc: '/font/HYRunYuan-65W.ttf' // font文件夹与pages目录同级
    })
  }

  @Builder
  myBuilder() {
    Column() {
      Row() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          Button({ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(20)
            .borderWidth(this.selection == 1 ? 5 : 0)
            .borderColor(Color.Blue)
            .backgroundImage($rawfile('man1.png'))
            .backgroundImagePosition(Alignment.Center)
            .backgroundImageSize(ImageSize.Cover)
            .width(160)
            .height(180)
            .onClick(() => {
              this.selection = 1
              this.video_choice = "man1"
              play_video(1,this.video_choice)
            })
        }.padding({ left: 10, right: 10, top: 0 })

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          Button({ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(20)
            .borderWidth(this.selection == 2 ? 5 : 0)
            .borderColor(Color.Blue)
            .backgroundImage($rawfile('man2.png'))
            .backgroundImagePosition(Alignment.Center)
            .backgroundImageSize(ImageSize.Cover)
            .width(160)
            .height(180)
            .onClick(() => {
              this.selection = 2
              this.video_choice = "man2"
              play_video(1,this.video_choice)
            })
        }.padding({ left: 10, right: 10, top: 0 })
      }

      Row() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          Button({ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(20)
            .borderWidth(this.selection == 3 ? 5 : 0)
            .borderColor(Color.Blue)
            .backgroundImage($rawfile('woman1.png'))
            .backgroundImagePosition(Alignment.Center)
            .backgroundImageSize(ImageSize.Cover)
            .width(160)
            .height(180)
            .onClick(() => {
              this.selection = 3
              this.video_choice = "woman1"
              play_video(1,this.video_choice)
            })
        }.padding({ left: 10, right: 10, top: 20 })

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          Button({ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(20)
            .borderWidth(this.selection == 4 ? 5 : 0)
            .borderColor(Color.Blue)
            .backgroundImage($rawfile('woman2.png'))
            .backgroundImagePosition(Alignment.Center)
            .backgroundImageSize(ImageSize.Cover)
            .width(160)
            .height(180)
            .onClick(() => {
              this.selection = 4
              this.video_choice = "woman2"
              play_video(1,this.video_choice)
            })
        }.padding({ left: 10, right: 10, top: 20 })
      }
    }
  }

  build() {
    Column() {
        Row() {
          // 加载png格式图片
          Image($rawfile('starsky.png'))
            .width('100%')
            .height('100%')
            .border({ width: 0 })
            .objectFit(ImageFit.Auto)
            .padding({ left: 5, right: 5, top: 5 })
          // .margin(15)
          // .overlay('Auto', { align: Alignment.Bottom, offset: { x: 0, y: 20 } })
        }

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        Row() {
          Column() {
            Text('《星月夜》')
              .fontSize(28)
              .fontColor(Color.Black)
              .fontWeight(120)
              .fontStyle(FontStyle.Normal)
              .alignSelf(ItemAlign.Center)
              .padding({
                left: 0,
                right: 0,
                top: 10,
                bottom: 6
              })
            Text('The Starry Night')
              .fontSize(20)
              .fontColor(Color.Gray)
              .fontWeight(80)
              .fontFamily('timesi')
              .alignSelf(ItemAlign.Center)
              .padding({
                left: 0,
                right: 0,
                top: 3,
                bottom: 15
              })
          }.padding({ left: 100, right: 0, top: 0 })

          Button('从头播放', { type: ButtonType.Capsule, stateEffect: true })
            .onClick(() => {
              this.btn_play_from_start = 1
              play_from_start(this.btn_play_from_start)
            })
        }

        Scroll(this.scroller) {
          Column() {
            Row() {
              Column() {
                ForEach(['作者','类型','创作时间','规格','纽约现代艺术博物馆'],(item: string, index)=>{
                  Text(item)
                    .fontSize(16)
                    .fontColor(Color.Black)
                    .fontWeight(80)
                    .fontStyle(FontStyle.Italic)
                    .alignSelf(ItemAlign.Start)
                })
              }
              .padding({
                left: 10,
                right: 40,
                top: 0,
                bottom: 0
              })
              Column() {
                ForEach(['文森特·梵高','油画','1889年6月','73.0x92.0cm','纽约现代艺术博物馆'],(item: string, index)=>{
                  Text(item)
                    .fontSize(16)
                    .fontColor(Color.Gray)
                    .fontWeight(80)
                    .fontStyle(FontStyle.Italic)
                    .alignSelf(ItemAlign.Start)
                })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .alignSelf(ItemAlign.Start)
            .padding({
              left: 0,
              right: 0,
              top: 8,
              bottom: 10
            })

            Text('    《星月夜》是荷兰后印象派画家文森特·梵高于1889年在法国圣雷米的精神病院创作的一幅油画，现收藏于纽约现代艺术博物馆。\n' +
              '    这幅画描绘了一个充满运动和变化的星空。画面中，夜晚的天空高远而深邃，大星、小星在夜空中回旋，金黄的月亮形成巨大的漩涡，星云的' +
              '短线条纠结、盘旋，仿佛让人看见时光的流逝。画面下方是宁静安详的村庄，与旋转的天空形成鲜明对比。画面中还有一棵暗绿褐色的柏树，像巨大的火焰，' +
              '是星夜狂欢的响应者。\n' +
              '    在色彩上，《星月夜》以蓝和紫罗兰为主色调，星星和月亮则用明亮的白色和黄色来描绘，给人以温暖光明的感觉。梵高运用浓厚且短促的笔触，' +
              '交织成弯曲的旋转线条，使画面呈现出炫目的奇幻景象。\n' +
              '    这幅画并非梵高对现实星空的简单描绘，而是他内心情感的强烈表达。他通过这幅画传达出一种不向命运低头的精神，同时也表现出人类的挣扎与奋斗。' +
              '    《星月夜》是荷兰后印象派画家文森特·梵高于1889年在法国圣雷米的精神病院创作的一幅油画，现收藏于纽约现代艺术博物馆。' +
              '  \n\n\n')
              .style(TextAlign.Start)
              .fontFamily('hy65')
              .lineHeight(35)
          }
        }
        // .backgroundColor(0xDCDCDC)
        .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
        .scrollBar(BarState.Off) // 滚动条常驻显示
        // .scrollBarColor(Color.Gray) // 滚动条颜色
        // .scrollBarWidth(10) // 滚动条宽度
        .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
      }.height(560).width('100%').padding({ left: 30, right: 30, top: 0 }).backgroundColor(0xF5DEB3)

      // Button() {
      //   Text('声音选择')
      //     .style(TextAlign.Start)
      //     .lineHeight(20)
      //     .margin(1)
      //     .padding(10)
      // }
      // .buttonStyle(1)
      // .width(60)
      // .height(60)
      // .position({ x: '80%', y: '80%' })
      // .shadow({ radius: 10 })
      // .onClick(async () => {
      //   this.selection = await get_video();
      //   console.info("这里要变:::"+this.selection.toString())
      //   this.isShow = true
      // })
      // .fontSize(20)
      // .margin(10)
      // .bindSheet($$this.isShow, this.myBuilder(), {
      //   detents: [SheetSize.MEDIUM, SheetSize.LARGE, 300],
      //   backgroundColor: Color.Gray,
      //   blurStyle: BlurStyle.Thick,
      //   showClose: true,
      //   title: { title: "声音选择", subtitle: "选择您喜欢的讲解员" },
      // })
    }.height(245).width('100%').backgroundColor(0xF5DEB3)
  }
}
