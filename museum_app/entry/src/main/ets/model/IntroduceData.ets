
@Observed
export class IntroduceData{
  imageName:string
  chineseTitle:string
  englishTitle:string
  chatValue:string
  introduction:string
  deviceId:number

  constructor(deviceId:number,chineseTitle:string='',englishTitle:string='',chatValue:string='',imageName:string='',introduction:string=''){
    this.deviceId=deviceId
    this.chineseTitle=chineseTitle
    this.englishTitle=englishTitle
    this.chatValue=chatValue
    this.imageName=imageName
    this.introduction=introduction
  }

}

export const introduceInfoList=new Map<String,[string[],string[]]>([
  ['星月夜',[['作者', '类型', '创作时间', '规格', '现藏地'],['文森特·梵高', '油画', '1889年6月', '73.0x92.0cm', '纽约现代艺术博物馆']]],
  ['唐三彩',[['展品规格'],['16x6x23cm']]],
])

export const introduceDataMap=new Map<string, IntroduceData>([
  ['The Starry Night',new IntroduceData(2,'星月夜', 'The Starry Night', '《星月夜》 (作者：梵高)', 'starsky.jpg',
    '    《星月夜》是荷兰后印象派画家文森特·梵高于1889年在法国圣雷米的精神病院创作的一幅油画，现收藏于纽约现代艺术博物馆。\n' +
      '    这幅画描绘了一个充满运动和变化的星空。画面中，夜晚的天空高远而深邃，大星、小星在夜空中回旋，金黄的月亮形成巨大的漩涡，星云的短线条纠结、盘旋，仿佛让人看见时光的流逝。画面下方是宁静安详的村庄，与旋转的天空形成鲜明对比。画面中还有一棵暗绿褐色的柏树，像巨大的火焰，是星夜狂欢的响应者。\n' +
      '    在色彩上，《星月夜》以蓝和紫罗兰为主色调，星星和月亮则用明亮的白色和黄色来描绘，给人以温暖光明的感觉。梵高运用浓厚且短促的笔触，交织成弯曲的旋转线条，使画面呈现出炫目的奇幻景象。\n' +
      '    这幅画并非梵高对现实星空的简单描绘，而是他内心情感的强烈表达。他通过这幅画传达出一种不向命运低头的精神，同时也表现出人类的挣扎与奋斗。' +
      '\n\n')],
  ['Tang Sancai',new IntroduceData(1,'唐三彩', 'Tang Sancai', '唐三彩', 'tangsancai.png',
    '    唐三彩，全名唐代三彩釉陶器，是盛行于唐代的一种低温釉陶器。它以高岭土作为胎料，用含铅氧化物作助熔剂，再添加含铜、铁等元素的金属氧化物作着色剂，最后经过复杂的工艺烧制而成。唐三彩的色彩丰富，以黄、绿、白三色最为常见，这也是“唐三彩”名称的由来。\n' +
    '    唐三彩的烧制工艺极为考究。工匠们先将素胎在1000℃左右的高温中素烧，使胎体烧结成型。之后，均匀地施以彩釉，再入窑进行二次焙烧。在釉烧过程中，随着温度升高，各种釉色自行向四周扩散流淌、相互浸润，使得唐三彩作品在阳光下熠熠生辉，形成斑驳淋漓、绚丽多姿的色彩效果。烧制完成后，工匠还会对唐三彩进行装饰，如刻划、印花等，使得作品更加栩栩如生。\n' +
    '    盛唐时期，唐朝文化繁荣，唐三彩的烧制走向高峰。这一时期的作品种类齐全，涵盖生活器皿、人物形象、飞禽走兽等。釉色更加丰富多样，除了基本的黄、绿、白，还有蓝、黑等色釉。装饰手法也更为复杂，划花、印花、贴花加彩、印花填彩、留白装饰、流釉装饰等被广泛运用，装饰内容丰富，花朵、植物、禽鸟等在三彩器上尽情展现。\n' +
    '    唐三彩不但艺术价值极高，文化价值同样不可忽视。它不仅是唐代社会风貌的生动写照，也是中国古代陶瓷工艺的杰出代表。通过唐三彩，我们可以窥见唐代社会的日常生活、风俗习惯等。例如展出的唐三彩骆驼，它高大健壮，昂首挺立，身上还驮着精美的货物。这些细节的刻画生动地再现了当时丝绸之路上的贸易场景，反映了唐代对外交流和贸易的繁荣。经由丝绸之路，唐三彩传播到中亚、西亚甚至欧洲地区，成为中外文化交流的重要见证。也激发了其它地陶瓷艺术的发展，在日本和朝鲜分别出现了奈良三彩和新罗三彩。\n' +
    '    唐三彩以其独特的艺术魅力和深厚的文化底蕴，成为了中国古代文化宝库中的一颗璀璨明珠，它不仅见证了大唐盛世的辉煌，也为我们今天研究唐代历史、文化、艺术提供了珍贵的实物资料。\n\n')]
]);
