import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { curves, font, KeyboardAvoidMode, LengthMetrics, router } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';
import { Chat } from './Chat';
import { ExhibitionBox } from '../components/ExhibitionBox';
import { introduceDataMap } from '../model/IntroduceData';

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

@Entry({storage: LocalStorage.getShared()})
@Component
struct ImageExample1 {
  @LocalStorageLink('nfcPageText') nfcPageText: string ='';
  @LocalStorageLink('pageStack') pageStack: NavPathStack = new NavPathStack()

  aboutToAppear() {
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
      familyName: 'hy65', // 注册的字体名称
      familySrc: '/font/HYRunYuan-65W.ttf' // font文件夹与pages目录同级
    })
    if(introduceDataMap.has(this.nfcPageText)){
      console.info('pageInfoFind:' + this.nfcPageText);
      this.pageStack.pushPath({ name: 'pageInfo', param: introduceDataMap.get(this.nfcPageText) })
    }
  }

  build() {
    Navigation(this.pageStack) {
      Row({space:20}){
        ExhibitionBox({ introduceData: introduceDataMap.get("The Starry Night") })
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 600, curve: curves.springMotion() }, () => {
              this.pageStack.pushPath({ name: 'pageInfo', param: introduceDataMap.get("The Starry Night") })
            })
            // this.pageStack.pushPath({ name: 'pageInfo' })
          })
          .transition(TransitionEffect.OPACITY)
        ExhibitionBox({ introduceData: introduceDataMap.get("Tang Sancai") })
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 600, curve: curves.springMotion() }, () => {
            this.pageStack.pushPath({ name: 'pageInfo', param: introduceDataMap.get("Tang Sancai") })
            })
            // this.pageStack.pushPath({ name: 'pageInfo' })
          })
          .transition(TransitionEffect.OPACITY)
      }.padding({top:20})
    }.backgroundColor(0xF5DEB3)
    .mode(NavigationMode.Stack)
    .title(this.title())
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    // .hideTitleBar(true)
  }

  @Builder
  title(){
    Text( '三分之一博物馆')
      .fontSize(30)
      .fontFamily('hy75')
      .padding({left:20,top:20})
      .fontColor(Color.Black)
  }
}
