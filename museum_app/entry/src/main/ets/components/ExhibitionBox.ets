import { font } from "@kit.ArkUI"
import { IntroduceData, introduceDataMap}from "../model/IntroduceData"

@Component
export struct ExhibitionBox {
  @Prop introduceData:IntroduceData
  aboutToAppear() {
    font.registerFont({
      familyName: 'yaSong', // 注册的字体名称
      familySrc: '/font/ShanHaiJiGuMingKe.ttf' // font文件夹与pages目录同级
    })
    font.registerFont({
      familyName: 'hy65', // 注册的字体名称
      familySrc: '/font/HYRunYuan-65W.ttf' // font文件夹与pages目录同级
    })
    font.registerFont({
      familyName: 'timesi', // 注册的字体名称
      familySrc: '/font/timesi.ttf' // font文件夹与pages目录同级
    })
  }

  imageSizeLimit: string = '40%'
  build() {
    Column(){
      Image($rawfile(this.introduceData?.imageName))
        .width('100%')// .height('100%')
        .border({ width: 0 })
        .objectFit(ImageFit.Contain)
        .padding({ left: 5, right: 10, top: 5 ,bottom:30})
        .constraintSize({ maxWidth: this.imageSizeLimit })
        .shadow({ radius: 20, type:ShadowType.BLUR})
        .borderRadius(5)
        // .geometryTransition(this.introduceData.chineseTitle)
        Text(this.introduceData?.chineseTitle)
          .fontFamily('hy65')
          .textAlign(TextAlign.Start)
          .fontSize(26)
          .fontColor(Color.Black)
          // .geometryTransition('sharedItemChinese')
        Text(this.introduceData?.englishTitle)
          .fontSize(18)
          .fontColor(Color.Gray)
          .fontWeight(80)
          .fontFamily('timesi')
          .alignSelf(ItemAlign.Center)
          // .geometryTransition('sharedItemEnglish')

    }
    // .border({width:0,color:Color.Gray,radius:5})

    // .backgroundColor(0xF5E9B3)

  }
}