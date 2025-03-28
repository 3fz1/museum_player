export enum ChatRole{
  USER='user',
  ASSISTANT='assistant',
}

const nodeTypeMap = new Map<string, string>([
  ['question-classifier', '理解问题'],
  ['knowledge-retrieval', '检索知识'],
  ['code','执行代码']
]);
@Observed
export class NodeData{
  isFinished:boolean=false
  info:string

  constructor(node_type:string){
    this.info=nodeTypeMap.get(node_type)??''
  }

}
@Observed
export class NodeDataList extends Array<NodeData>{

}

@Observed
export class ChatData{
  role:ChatRole
  message:string=''
  isLoading:boolean
  thinking:string=''

  setThinkChain(message:string){
    const regex = /<details\s* +(style\s*=\s*["'])[^>]*?open\s*>\s*<summary>\s*Thinking...\s*<\/summary>/gi;
    let posSummary=message.search(regex)
    let posThink=message.indexOf('<think>')
    let thinkContentEnd=-1;
    let answerStart=0;
    let thinkContentStart =0;
    const hasThink=posSummary!==-1||posThink!=-1
    if(posSummary!=-1){
      thinkContentStart = message.indexOf('</summary>') + '</summary>'.length;
      thinkContentEnd = message.indexOf('</details>', thinkContentStart);
      answerStart=thinkContentEnd+'</details>'.length
    }else if (posThink!=-1){
      thinkContentStart = posThink + '<think>'.length;
      thinkContentEnd = message.indexOf('</think>');
      answerStart=thinkContentEnd+'</think>'.length
    }
    if(hasThink){
      if (thinkContentEnd === -1) {
        this.thinking = message.slice(thinkContentStart).trim();
        this.message = '';
      } else {
        this.thinking = message.slice(thinkContentStart, thinkContentEnd).trim();
        this.message = message.slice(answerStart).trim();
      }
    }else{
      this.message=message
    }


    // if(posSummary==-1&&posThink==-1){
    //   this.message=message
    // }else{
    //   if (posThink !== -1) {
    //     const detailsEnd = message.indexOf('</details>', posSummary);
    //   }else {
    //     const thinkHeadEnd = message.indexOf('</summary>')
    //     const thinkContentStart = thinkHeadEnd + '</summary>'.length;
    //     const detailsEnd = message.indexOf('</details>', thinkContentStart);
    //   }
    //   if (detailsEnd === -1) {
    //     this.thinking = message.slice(thinkContentStart).trim();
    //     this.message = '';
    //   } else {
    //     this.thinking = message.slice(thinkContentStart, detailsEnd).trim();
    //     this.message = message.slice(detailsEnd + '</details>'.length).trim();
    //   }
    // }
  }

  constructor(role:ChatRole, message:string, isLoading:boolean=false) {
    this.role=role
    this.isLoading=isLoading
    if(role==ChatRole.USER) {
      this.message = message
    }
    else {
      this.setThinkChain(message)
    }
  }
}
const randomString = (length: number = 10): string => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};
export function generateChat(num:number){
  let data=new Array<ChatData>()
  for(let i=0;i<num;i++){
    data.push(new ChatData(ChatRole.USER, randomString(Math.ceil(Math.random()*40))))
    data.push(new ChatData(ChatRole.ASSISTANT, randomString(Math.floor(Math.random()*100))))
  }
  return data
}

