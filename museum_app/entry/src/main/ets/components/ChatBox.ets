import { ListItemModifier } from '@kit.ArkUI';
import { ChatData, ChatRole, NodeDataList } from '../model/ChatData';
import { lvMarkdownIn } from '@luvi/lv-markdown-in'
import { curves } from '@kit.ArkUI';
import { lvText } from '@luvi/lv-markdown-in'
import { NodeData } from '../model/ChatData';

lvText.setTextSize(18)                   // 设置文本字号20

@Component
export struct ChatBox {
  @Prop chatData: ChatData
  isUser = ()=>{ return this.chatData.role == ChatRole.USER}
  // @State chatText: string = this.chatData.message
  basicRadius = 15
  instructRadius = 4
  private effect: object =
    TransitionEffect.OPACITY
      .combine(TransitionEffect.SLIDE)

  build() {
    // if (this.chatData.isLoading) {
      Column() {
        Text(this.chatData.message.trim())
          .textAlign(TextAlign.JUSTIFY)
          .lineBreakStrategy(LineBreakStrategy.HIGH_QUALITY)
          .padding(13)
          .fontColor(this.isUser() ? Color.White : Color.Black)
          .backgroundColor(this.isUser() ? '#A98645' : Color.Pink)
          .borderRadius({
            topLeft: this.isUser() ? this.basicRadius : this.instructRadius,
            topRight: this.isUser() ? this.instructRadius : this.basicRadius,
            bottomLeft: this.basicRadius,
            bottomRight: this.basicRadius
          })
          .alignSelf(ItemAlign.End)

        // Row() {
        // }
      }.width('100%')
    }
  // }
}

@Component
export struct MdChatBox {
  @Prop chatData: ChatData;
  @ObjectLink nodeList: NodeDataList;
  @State isShowThinking: boolean = true;
  @State animate: boolean = false;
  @State heightAnimateVal: number |string = 'auto';

  thinkHeight:number=30
  private effect: object = TransitionEffect.OPACITY
      .animation({
        curve: curves.springMotion(),
        duration: 600
      })

  build() {
    Column() {
      ForEach(this.nodeList,(item:NodeData,index:number)=>{
        if(item.info!= ''){
          Row({ space: 8 }) {
            if (!item.isFinished){
              LoadingProgress()
                .size({ width: 15, height: 15 })
                .transition(this.effect)
            }
            SymbolGlyph(item.isFinished ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle'))
              .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), item.isFinished?0:-1)
              .fontColor([Color.Green])
              .animation({ curve: curves.springMotion()})
            Text(item.info)
              .fontColor(Color.Gray)
              .animation({ curve: curves.springMotion()})
          }.width('100%')
          .align(Alignment.Start)
          .animation({ curve: curves.springMotion()})
        }
      })
      if (this.chatData.thinking != '') {
        Column({ space: 5 }) {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .rotate({ angle: this.isShowThinking ? 0 : -90 })
              .fontSize(20)
            .onClick(() => {
              this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
                // 第三步：闭包内通过状态变量改变UI界面
                // 这里可以写任何能改变UI的逻辑比如数组添加，显隐控制，系统会检测改变后的UI界面与之前的UI界面的差异，对有差异的部分添加动画
                // 组件一的rotate属性发生变化，所以会给组件一添加rotate旋转动画
                this.isShowThinking = !this.isShowThinking;
                // let textbox:object=JSON.parse(getInspectorByKey('thinkText'))
                // this.heightAnimateVal = this.isShowThinking ? this.thinkHeight : 30;
              })
            })

            Text('深度思考')
              .fontSize(16)
              .fontColor(Color.Black)
          }

          if(this.isShowThinking){
            Text(this.chatData.thinking)
              .animation({ curve: curves.springMotion() })
              .fontColor(Color.Gray)
              .fontSize(16)
          }
            // .height(this.isShowThinking ? 100 : 0)
        }
        .backgroundColor('#f8f8f8')
        .padding(8)
        .borderRadius(4)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .clip(true)
        .height(this.heightAnimateVal)

      }
      lvMarkdownIn({ text: this.chatData.message })
      if (this.chatData.isLoading){
        LoadingProgress()
          .size({ width: 70, height: 30 })
          .transition(this.effect)
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}


