import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AAID } from '@kit.PushKit';
import { util, buffer, JSON } from '@kit.ArkTS';
import {
  BaseChatFlow,
  MessageChatFlow,
  FileChatFlow,
  MessageEndFlow,
  TTSChatFlow,
  ErrorFlow,
  ResponseMode,
  ChatInputs,
  ChatBody,
  OpeningInfo,
  SuggestedResponse,
  ChatEvent,
  NodeFlow
} from './DifyInterface'
import { BusinessError } from '@kit.BasicServicesKit';

let basicUrl = 'https://app.yitoto.cn/v1'
// let appKey='app-QnWULZ89AthhBbUEUF27N6pq' //useless answer, for test only


export async function getAdvices(messageId: string, setAdvices: Function) {
  let aaid = await AAID.getAAID()
  let httpRequest = http.createHttp();
  let stopRequest: http.HttpRequestOptions = {
    method: http.RequestMethod.GET,
    header: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + appKey,
    }
  }
  let stopUrl = basicUrl + `/messages/${messageId}/suggested?user=${aaid}`
  hilog.info(0x0000, 'Dify', `suggestUrl:${stopUrl}`)
  hilog.info(0x0000, 'Dify', `suggestRequest:${JSON.stringify(stopRequest)}`)
  httpRequest.request(
    stopUrl,
    stopRequest, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      // data.result为HTTP响应内容，可根据业务需要进行解析
      hilog.info(0x0000, 'Dify', 'suggest Result:' + JSON.stringify(data.result));
      let advices = JSON.parse(data.result.toString()) as SuggestedResponse;
      setAdvices(advices.data)
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    } else {
      hilog.info(0x0000, 'Dify', 'stop error:' + JSON.stringify(err));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    }
  })
}

export async function chat(query: string, conversationId: string, visitItem: string,
  onChatUpdated: (event: ChatEvent, data: string, task_id: string) => void, onChatEnd: Function = () => {
  }) {
  try {
    let httpRequest = http.createHttp();
    let aaid = await AAID.getAAID()
    let requestUrl = basicUrl + '/chat-messages'
    let chatBody: ChatBody = {
      query: query,
      inputs: { visit_item: visitItem },
      response_mode: ResponseMode.STREAMING,
      user: aaid,
      conversation_id: conversationId,
      auto_generate_name: false,
    }

    let streamInfo: http.HttpRequestOptions = {
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + appKey,
      },
      // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
      extraData: chatBody,
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
      // usingCache: true, // 可选，默认为true
      // priority: 1, // 可选，默认为1
      connectTimeout: 60000, // 可选，默认为60000ms
      readTimeout: 300000, // 可选，默认为60000ms。若传输的数据较大，需要较长的时间，建议增大该参数以保证数据传输正常终止
      // usingProtocol: http.HttpProtocol.HTTP1_1 // 可选，协议类型默认值由系统自动指定
    }
    hilog.info(0, 'Dify', `Request Body:${JSON.stringify(chatBody)}`)

    httpRequest.on('headersReceive', (header: Object) => {
      hilog.info(0x0000, 'Dify', 'header: ' + JSON.stringify(header));
    });
    let resBuffer = '';
    httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      try {
        if (data.byteLength == 0) {
          return;
        }
        let strReceive = buffer.from(data).toString('utf8');
        if (strReceive.startsWith('event: ping')) {
          return;
        }
        resBuffer += strReceive;
        hilog.debug(0x0000, 'Dify', 'buffer: ' + strReceive);

        if (resBuffer.startsWith('data: ') && resBuffer.endsWith('\n\n')) {
          // 解析数据块
          let payload = resBuffer.trim().replace('data: ', '');
          resBuffer = ''
          hilog.debug(0x0000, 'Dify', 'payload:' + payload);
          let eventObj = JSON.parse(payload) as BaseChatFlow;
          // hilog.debug(0x0000,'Dify', 'eventObj:' + JSON.stringify(eventObj))

          // 根据event类型处理不同事件
          switch (eventObj.event) {
            case 'message':
              let message = eventObj as MessageChatFlow;
              // hilog.info(0x0000, 'Dify', 'message:' + JSON.stringify(message))
              // 更新UI
              hilog.info(0x0000, 'Dify', 'message.answer:' + message.answer)
              onChatUpdated(ChatEvent.MESSAGE, message.answer, message.task_id)
              break;
            case 'node_started':
              let nodeStart = eventObj as NodeFlow;
              hilog.info(0x0000, 'Dify', 'nodeStart:' + JSON.stringify(nodeStart.data.node_type))
              onChatUpdated(ChatEvent.NODE_STARTED, nodeStart.data.node_type, nodeStart.task_id)
              break;
            case 'node_finished':
              let nodeEnd = eventObj as NodeFlow;
              hilog.info(0x0000, 'Dify', 'nodeEnd:' + JSON.stringify(nodeEnd.data.node_type))
              onChatUpdated(ChatEvent.NODE_FINISHED, nodeEnd.data.node_type, nodeEnd.task_id)
              break;
            case 'message_file':
              // 处理文件事件（如显示图片）

              break;
            case 'message_end':
              // 结束流式接收
              let messageEnd = eventObj as MessageEndFlow;
              hilog.info(0x0000, 'Dify', 'messageEnd:' + JSON.stringify(messageEnd))
              onChatEnd(messageEnd.conversation_id, messageEnd.message_id)
              httpRequest.destroy();
              break;
            case 'tts_message':
              let audio = eventObj as TTSChatFlow
              // 处理音频数据（解码Base64）
              // let audioData = atob(eventObj.audio);
              // 播放音频
              break;
            case 'error':
              // 处理错误
              let error = eventObj as ErrorFlow
              console.error(`Error: ${error.message}`);
              onChatEnd('', error.message_id)
              httpRequest.destroy();
              break;
            case 'ping':
              // 忽略心跳包
              break;
            default:
              console.log(`Unhandled event: ${eventObj.event}`);
          }
        }

        if (strReceive.length == 0) {
          return;
        }
      } catch (e) {
        hilog.error(0x0000, 'Dify', `Error: ${e}`);
        return;
      }
    });
    // 用于订阅HTTP流式响应数据接收完毕事件
    httpRequest.on('dataEnd', () => {
      hilog.info(0x0000, 'Dify', 'No more data in response, data receive end');
      //
      // if(funcChatEnd){
      //   funcChatEnd();
      // }
    });

    // 用于订阅HTTP流式响应数据接收进度事件
    class Data {
      receiveSize: number = 0;
      totalSize: number = 0;
    }

    httpRequest.on('dataReceiveProgress', (data: Data) => {
      hilog.info(0x0000, 'Dify',
        "dataReceiveProgress receiveSize:" + data.receiveSize + ", totalSize:" + data.totalSize);
    });

    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
    httpRequest.requestInStream(requestUrl, streamInfo).then((data: number) => {
      // Logger.info(TAG, "requestInStream OK!");
      // Logger.info(TAG, 'ResponseCode :' + JSON.stringify(data));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 取消订阅HTTP流式响应数据接收事件
      httpRequest.off('dataReceive');
      // 取消订阅HTTP流式响应数据接收进度事件
      httpRequest.off('dataReceiveProgress');
      // 取消订阅HTTP流式响应数据接收完毕事件
      httpRequest.off('dataEnd');
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    }).catch((err: Error) => {
      hilog.error(0x0000, 'Dify Error', "requestInStream ERROR : err = " + JSON.stringify(err));
    });

  } catch (error) {
    hilog.error(0x0000, 'Dify Error', error.message)
  }
}

export async function stopChatting(task_id: string) {
  let aaid = await AAID.getAAID()
  let httpRequest = http.createHttp();
  let stopRequest: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + appKey,
    },
    extraData: { "user": aaid }
  }
  let stopUrl = basicUrl + `/chat-messages/${task_id}/stop`
  hilog.info(0x0000, 'Dify', `stopUrl:${stopUrl}`)
  hilog.info(0x0000, 'Dify', `stopRequest:${JSON.stringify(stopRequest)}`)
  httpRequest.request(
    stopUrl,
    stopRequest, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      // data.result为HTTP响应内容，可根据业务需要进行解析
      hilog.info(0x0000, 'Dify', 'stop Result:' + JSON.stringify(data.result));
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    } else {
      hilog.info(0x0000, 'Dify', 'stop error:' + JSON.stringify(err));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    }
  })
}

export function getParameters(openingCallback: Function) {
  let httpRequest = http.createHttp();
  httpRequest.request(
    basicUrl + '/parameters',
    {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + appKey,
      }
    }, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      // data.result为HTTP响应内容，可根据业务需要进行解析
      // console.info('Result:' + JSON.stringify(data.result));
      let openingInfo = JSON.parse(data.result.toString()) as OpeningInfo;
      console.info('code:' + JSON.stringify(data.responseCode));
      openingCallback(openingInfo)
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    } else {
      console.error('error:' + JSON.stringify(err));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    }
  }
  )
}
