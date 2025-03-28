import { curves, ListItemModifier } from '@kit.ArkUI';

@Component
struct OpeningChatBox{
  @Prop text:string
  @Prop questions:string[]
  @Prop enableButton:boolean
  basicRadius=15
  onQuestionClicked=(item:string)=>{}

  // instructRadius=4
  build() {
    Column() {
      Text(this.text)
        .textAlign(TextAlign.JUSTIFY)
        .lineBreakStrategy(LineBreakStrategy.HIGH_QUALITY)
        .padding(13)
        .width('100%')
        .transition(TransitionEffect.OPACITY)

      List({space:10}){
        ForEach(this.questions,(item:string,index:number)=>{
          ListItem() {
            Button(item)
              .enabled(this.enableButton)
              .onClick(() => {
                this.onQuestionClicked(item)
              })
              .margin({bottom:10})
              .linearGradient({
                direction:GradientDirection.Left,
                colors:[[0xF5E9B3,0],[0xF5CFB3,1]]
              })
              .fontColor(Color.Black)
          }
          .transition(TransitionEffect.OPACITY)
        })
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .lanes(2)
      .margin({left:10,right:10})

    }.width('100%')
    .borderColor('#F5DEB3')
    .borderRadius(this.basicRadius)
    .borderWidth(4)
    .margin({bottom:20})
  }
}
export default OpeningChatBox
