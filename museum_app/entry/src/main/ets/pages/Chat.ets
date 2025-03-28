import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatBox, MdChatBox } from '../components/ChatBox';
import * as Dify from '../model/Dify';
import { ChatData, generateChat, ChatRole, NodeData, NodeDataList } from '../model/ChatData'

import OpeningChatBox from '../components/OpeningChatBox';
import { ChatEvent, OpeningInfo } from '../model/DifyInterface';
import { curves,KeyboardAvoidMode, window } from '@kit.ArkUI';
import { IntroduceData } from '../model/IntroduceData';

@Builder
export function PageChatBuilder(name: string, param: IntroduceData) {
  Chat({chatValue:param.chatValue})
}

@Entry
@Component
export struct Chat {
  @State message: string = '';
  @State messageList: ChatData[] = []
  @State introduction: string = ''
  @State openingQuestions: string[] = []
  @State isChatting: boolean = false;
  @State input: string = ''
  @State adviceQuestions: string[] = []
  @State triggerValueReplace: number = 0;
  @State nodeListArr:Array<NodeDataList> = []
  chatValue:string=''
  messageId = ''
  conversationId = ''
  task_id: string = ''
  mainScroll: Scroller = new Scroller()
  pageStack: NavPathStack = new NavPathStack();
  private effect: object =
    TransitionEffect.OPACITY
      .animation({ curve: curves.springMotion(), duration: 500 })

  aboutToAppear(): void {
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    Dify.getParameters((openingInfo: OpeningInfo) => {
      this.introduction = openingInfo.opening_statement;
      this.openingQuestions = openingInfo.suggested_questions;
    })
  }

  sendMessage() {
    let userChat = new ChatData(ChatRole.USER, this.input)
    this.messageList.push(userChat)
    let newChat = new ChatData(ChatRole.ASSISTANT, '', true)
    this.messageList.push(newChat)
    this.mainScroll.scrollEdge(Edge.Bottom)
    this.isChatting = true
    this.triggerValueReplace = this.triggerValueReplace + 1;
    let newNodeList= new NodeDataList()
    this.nodeListArr.push(newNodeList)
    this.nodeListArr.push(newNodeList)

    let currentNode :NodeData

    Dify.chat(this.input, this.conversationId, this.chatValue,
      (event: string, data: string, taskId: string) => {
        this.mainScroll.scrollEdge(Edge.Bottom)
        switch (event) {
          case ChatEvent.MESSAGE:
            this.message += data
            newChat.setThinkChain(this.message)
            break
          case ChatEvent.NODE_STARTED:
            currentNode = new NodeData(data)
            newNodeList.push(currentNode)
            hilog.info(0x0000,'Dify','newNodeList:',JSON.stringify( newNodeList))
            break
          case ChatEvent.NODE_FINISHED:
            currentNode.isFinished = true
            hilog.info(0x0000,'Dify','fin newNodeList:', JSON.stringify(newNodeList))
            break
        }
        this.task_id = taskId
      },
      (conversationId: string, messageId: string) => { //when send end
        this.conversationId = conversationId
        this.message = ''
        this.isChatting = false
        this.triggerValueReplace = this.triggerValueReplace + 1;
        this.messageId = messageId
        Dify.getAdvices(messageId, (questions: string[]) => {
          this.adviceQuestions = questions
          this.mainScroll.scrollEdge(Edge.Bottom)
        })
        newChat.isLoading = false
      });
    this.input = ''
  }

  build() {
    NavDestination() {
      List({ space: 10, scroller: this.mainScroll }) {
        ListItem() {
          OpeningChatBox({
            text: this.introduction,
            questions: this.openingQuestions,
            enableButton: !this.isChatting,
            onQuestionClicked: (item: string) => {
              this.input = item
              this.sendMessage()
            }
          })
        }

        ForEach(this.messageList, (item: ChatData, index: number) => {
          if (item.role == ChatRole.USER) {
            ListItem() {
              ChatBox({ chatData: item })
                .transition(this.effect)
            }
          } else {
            ListItem() {
              MdChatBox({ chatData: item, nodeList:this.nodeListArr[index] })
            }
          }
        })
      }
      // .expandSafeArea(this.messageList.length == 0 ? [SafeAreaType.KEYBOARD] : [SafeAreaType.CUTOUT])
      .width('100%')
      .padding(10)
      .layoutWeight(1)

      this.footBuilder()

    }
    .width('100%')
    .height('100%')
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      console.info("current page config info is " + JSON.stringify(context.getConfigInRouteMap()));
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.getUIContext()?.animateTo({ duration: 600, curve: curves.springMotion() }, () => {
        this.pageStack.pop(false)
      })
      return true;
    })
    .animation({curve: curves.springMotion()})
    .transition(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.BOTTOM), TransitionEffect.move(TransitionEdge.BOTTOM))
    .combine(TransitionEffect.OPACITY))
    // .justifyContent(FlexAlign.End)
    // .expandSafeArea([SafeAreaType.KEYBOARD,SafeAreaType.SYSTEM])
    // .transition(TransitionEffect.translate({ y: 1000 }).animation({ curve: curves.springMotion(0.6,0.8) }))

  }

  @Builder
  footBuilder() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.adviceQuestions, (item: string, index: number) => {
          Button(item)
            .backgroundColor(Color.Transparent)
            .borderWidth(4)
            .borderColor('#F5DEB3')
            .fontColor(Color.Gray)
            .transition(this.effect)
            .animation({ curve: curves.springMotion() })
            .enabled(!this.isChatting)
            .onClick(() => {
              this.input = item;
              this.sendMessage();
            });
        });
      }
      .padding(10);
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)

    Row() {
      TextArea({
        placeholder: '你有什么问题想问',
        text: $$this.input,
      }).layoutWeight(1)
        .margin({ right: 10 });

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph(this.isChatting ? $r('sys.symbol.xmark') : $r('sys.symbol.paperplane_right_fill'))
          .fontSize(25)
          .padding(5)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
      }
      .backgroundColor(0xA98645)
      .onClick(() => {
        if (this.isChatting) {
          this.isChatting = false;
          Dify.stopChatting(this.task_id);
          this.messageList[this.messageList.length - 1].isLoading = false;
        } else if (this.input != null && this.input != '') {
          // this.isChatting = true
          this.sendMessage();
          this.input = '';
          this.message = '';
        }
      });
    }
    .width('100%')
    .padding({ left: 10, right: 10 ,bottom:10})
  }
}

