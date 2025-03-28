import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { curves, font, KeyboardAvoidMode, LengthMetrics, router } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';
import { Chat } from './Chat';
import { IntroduceData, introduceInfoList } from '../model/IntroduceData';

@Builder
export function PageInfoBuilder(name:string,param:IntroduceData){
  InfoPage({introduce:param})
}

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

async function get_video(device: number): Promise<number> {
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
      "http://120.46.75.132:8080/app/get_video?device="+device.toString(),
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
        '    "volume": ' + volume + ',\n' +
        '    "play_speed": ' + play_speed + '\n' +
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

function play_video(device: number, video: string) {
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
        '    "device": ' + device + ',\n' +
        '    "video": "' + video + '"\n' +
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

@Entry({storage: LocalStorage.getShared()})
@Component
struct InfoPage {
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
  // 模态转场控制变量
  @State isChatPresent: boolean = false;
  @State imageSizeLimit:string='100%';
  @StorageProp('topRectHeight')  topRectHeight: number = 0;
  @LocalStorageLink('nfcPageText') nfcPageText: string ='';
  pageStack: NavPathStack = new NavPathStack();
  @ObjectLink introduce:IntroduceData;
  infoKeyList:string[]=[];
  infoValueList:string[]=[];
  aboutToAppear() {
    let infoTuple=introduceInfoList.get(this.introduce.chineseTitle)
    if(infoTuple!=undefined){
      this.infoKeyList=infoTuple[0]
      this.infoValueList=infoTuple[1]
    }
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
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
      familyName: 'yaSong', // 注册的字体名称
      familySrc: '/font/ShanHaiJiGuMingKe.ttf' // font文件夹与pages目录同级
    })
    font.registerFont({
      familyName: 'hy65', // 注册的字体名称
      familySrc: '/font/HYRunYuan-65W.ttf' // font文件夹与pages目录同级
    })
    console.info('pageInfo:' + this.nfcPageText);
  }

  @Builder
  myBuilder() {
    Column() {
      Row() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          this.videoSelectButton('man1',1)
        }.padding({ left: 10, right: 10, top: 0 })
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          this.videoSelectButton('man2',2)
        }.padding({ left: 10, right: 10, top: 0 })
      }

      Row() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          this.videoSelectButton('woman1',3)
        }.padding({ left: 10, right: 10, top: 20 })

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          this.videoSelectButton('woman2',4)
        }.padding({ left: 10, right: 10, top: 20 })
      }
    }
  }

  @Builder
  videoSelectButton(choice:string,selection:number) {
      Button({ type: ButtonType.Normal, stateEffect: true })
        .borderRadius(20)
        .borderWidth(this.selection == selection ? 5 : 0)
        .borderColor(Color.Blue)
        .backgroundImage($rawfile(`${choice}.png`))
        .backgroundImagePosition(Alignment.Center)
        .backgroundImageSize(ImageSize.Cover)
        .width(160)
        .height(180)
        .onClick(() => {
          this.selection = selection;
          this.video_choice = choice;
          play_video(this.introduce.deviceId, this.video_choice);
        });

  }

  build() {
    NavDestination() {
      // Blank().backgroundColor(0xF5DEB3).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      // 加载png格式图片
        Image($rawfile(this.introduce.imageName))
          .width('100%')// .height('100%')
          .border({ width: 0 })
          .objectFit(ImageFit.Contain)
          .padding({ left: 5, right: 5, top: 5 })
          .constraintSize({ maxHeight: this.imageSizeLimit, maxWidth: this.imageSizeLimit })
          .animation({curve: curves.springMotion() })
          .transition(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END), TransitionEffect.move(TransitionEdge.START))
            .combine(TransitionEffect.OPACITY))
          // .geometryTransition(this.introduce.chineseTitle)
        // .margin(15)
        // .overlay('Auto', { align: Alignment.Bottom, offset: { x: 0, y: 20 } })

        Column() {
          Text(this.introduce.chineseTitle)
            .fontSize(28)
            .fontColor(Color.Black)
            .fontWeight(120)
            .fontStyle(FontStyle.Normal)
            .alignSelf(ItemAlign.Center)
            .fontFamily('hy75')
            .padding({
              left: 0,
              right: 0,
              top: 10,
              bottom: 6
            })
          // .geometryTransition('sharedItemChinese')
          Text(this.introduce.englishTitle)
            .fontSize(20)
            .fontColor(Color.Gray)
            .fontWeight(80)
            .fontFamily('timesi')
            .alignSelf(ItemAlign.Center)
            .padding({
              left: 0,
              right: 0,
              top: 3,
              bottom: 2
            })
          // .geometryTransition('sharedItemEnglish')

      }
      // .geometryTransition('sharedItem')
      // .transition(TransitionEffect.OPACITY)

      Stack({alignContent:Alignment.BottomEnd}){
        Scroll(this.scroller) {
          Column() {
            Row() {
              Column() {
                ForEach(this.infoKeyList, (item: string, index) => {
                  Text(item)
                    .fontSize(16)
                    .fontColor(Color.Black)
                    .fontWeight(80)
                    .fontStyle(FontStyle.Italic)
                    .alignSelf(ItemAlign.Start)
                })
              }

              Column() {
                ForEach(this.infoValueList,
                  (item: string, index) => {
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

            Text(this.introduce.introduction)
              .style(TextAlign.Start)
              .fontFamily('hy65')
              .lineHeight(35)
              .fontColor(Color.Black)
          }.padding({ left: 30, right: 30 })
        }
        .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
        // .scrollBar(BarState.Off) // 滚动条常驻显示
        .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
        .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(20) })
        .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
          let absYOffset = this.scroller.currentOffset().yOffset
          let heightLim=(300-absYOffset)/3
          if(heightLim<0)
            heightLim=0
          this.imageSizeLimit=(heightLim+60).toFixed(1)+'%'
          // console.info(absYOffset.toString())
        })

        Button() {
          Text('声音选择')
            .style(TextAlign.Start)
            .lineHeight(20)
            .margin(1)
            .padding(10)
            .fontColor(Color.Black)
        }
        .buttonStyle(1)
        .width(60)
        .height(60)
        // .position({ x: '80%', y: '83%' })
        .offset({ x: -5, y: -3 })
        .shadow({ radius: 30 ,color:Color.Gray,type:ShadowType.BLUR})
        .onClick(async () => {
          this.selection = await get_video(this.introduce.deviceId);
          console.info("这里要变:::" + this.selection.toString())
          this.isShow = true
        })
        // .linearGradient({
        //   direction:GradientDirection.Top,
        //   colors:[[0xEFAEB3,0],[0xF5CFB3,1]]
        // })
        .radialGradient({
          center:[50,10],
          radius: 40,
          colors:[[0xF5CFB3,0],[0xEFAEB3,1]]
        })
        .fontSize(20)
        .margin(10)
        .bindSheet($$this.isShow, this.myBuilder(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 300],
          backgroundColor: Color.Gray,
          blurStyle: BlurStyle.Thick,
          showClose: true,
          title: { title: "声音选择", subtitle: "选择您喜欢的讲解员" },
        })
      }        .layoutWeight(1)

      Row() {
        Button('有问题？这里问！')// 通过选定的模态接口，绑定模态展示界面，ModalTransition是内置的ContentCover转场动画类型，这里选择None代表系统不加默认动画，通过onDisappear控制状态变量变换
          // .bindContentCover(this.isChatPresent, this.PageChatBuilder(), {
          //   modalTransition: ModalTransition.DEFAULT,
          //   onDisappear: () => {
          //     if (this.isChatPresent) {
          //       this.isChatPresent = !this.isChatPresent;
          //     }
          //   }
          // })
          .shadow({ radius: 20, type:ShadowType.BLUR})
          .fontColor(Color.Black)
          .onClick(() => {
            // 改变状态变量，显示模态界面
            // this.isChatPresent = !this.isChatPresent;
              this.getUIContext()?.animateTo({ duration: 600, curve: curves.springMotion() }, () => {
                this.pageStack.pushPath({ name: 'pageChat', param: this.introduce },false)
            // this.pageInfos.pushPath({ name: 'pageChat', param: this.introduce })
          })})
          .linearGradient({
            direction:GradientDirection.Left,
            colors:[[0xEFAEB3,0],[0xF5CFB3,1]]
          })
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row({space:5}) {
            SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
              .fontColor([Color.Black])
              .fontWeight(FontWeight.Bold)
            Text('从头播放').fontColor(Color.Black)
          }.padding(10)
        }
        .linearGradient({
          direction:GradientDirection.Left,
          colors:[[0xEFAEB3,0],[0xF5CFB3,1]]
        })
        .shadow({ radius: 20, type:ShadowType.BLUR})
        .onClick(() => {
          play_from_start(this.introduce.deviceId)
        })
      }
      .padding({
        left: 10,
        right: 10,
        top: 1,
        bottom: 0
      })
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%').expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]).backgroundColor(0xF5DEB3)
    }.width('100%').backgroundColor(0xF5DEB3)
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      console.info("current page config info is " + JSON.stringify(context.getConfigInRouteMap()));
    })
    .hideTitleBar(true)
    .transition(TransitionEffect.OPACITY)
  }

  // @Builder
  // PageChatBuilder() {
  //   Chat()
  //     .transition(TransitionEffect.translate({ y: 1000 }).animation({ curve: curves.springMotion(0.6, 0.8) }))
  //     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  //     // .backgroundBlurStyle(BlurStyle.Regular,{policy:BlurStyleActivePolicy.ALWAYS_ACTIVE,inactiveColor:Color.White})
  //     // .backdropBlur(100)
  //     // .backgroundColor(Color.White)
  //     // .opacity(0.8)
  // }
}
