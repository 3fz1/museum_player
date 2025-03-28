import { AbilityConstant, ConfigurationConstant, UIAbility, Want,bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { tag } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IntroduceData, introduceDataMap } from '../model/IntroduceData';

const DOMAIN = 0x0000;
let nfcTagElementName: bundleManager.ElementName;
let foregroundRegister: boolean;
let pageStack: NavPathStack = new NavPathStack()

function parseTextRecord(payload: number[]): string {
  let languageCodeLength: number = payload[0] & 0x3F; // 取低6位
  let textBytes: number[] = payload.slice(languageCodeLength + 1);
  return String.fromCharCode(...textBytes);
}

async function readerModeCb(error : BusinessError, tagInfo : tag.TagInfo) {
  if (!error) {
    // 获取特定技术类型的NFC标签对象
    if (tagInfo == null || tagInfo == undefined) {
      hilog.error(0x0000, 'testTag', 'readerModeCb tagInfo is invalid');
      return;
    }
    if (tagInfo.uid == null || tagInfo.uid == undefined) {
      hilog.error(0x0000, 'testTag', 'readerModeCb uid is invalid');
      return;
    }
    if (tagInfo.technology == null || tagInfo.technology == undefined || tagInfo.technology.length == 0) {
      hilog.error(0x0000, 'testTag', 'readerModeCb technology is invalid');
      return;
    }

    let isNdefTag =  false;
      for (let i = 0; i < tagInfo.technology.length; i++) {
        if (tagInfo.technology[i] == tag.NDEF) {
          isNdefTag = true;
        }
      }
    if (isNdefTag) {
      let ndef : tag.NdefTag | null = null;
      try {
        ndef = tag.getNdef(tagInfo);
        if (ndef) {
          ndef.connect();
          let ndefRecords: tag.NdefRecord[] = ndef.getNdefMessage().getNdefRecords();
          hilog.info(0x0000,'nfc',"ndef ndefMessage onScan: " + JSON.stringify(ndefRecords));
          // 遍历所有记录
          for (let record of ndefRecords) {
            // 解析记录类型和数据
            let tnf: number = record.tnf;     // 类型名称格式（TNF）
            let type: number[] = record.rtdType; // 记录类型（如 "text" 或 "Uri"）
            let payload: number[] = record.payload; // 有效负载数据

            // 根据 TNF 和 Type 解析内容
            switch (tnf) {
              case tag.TnfType.TNF_WELL_KNOWN:
                let text: string = parseTextRecord(payload);
                hilog.info(0x0000,'nfc',"文本记录 onScan: " + text);

                if(introduceDataMap.has(text)){
                  let pageName=pageStack.getAllPathName()
                  hilog.debug(0x0000,'nfc',"当前页面栈:"+pageName.toString())
                  if(pageName.length==0){
                    // 首页
                    pageStack.pushPath({ name: 'pageInfo', param: introduceDataMap.get(text) })
                  }else if(pageName[pageName.length-1]=='pageInfo'){
                    let data=pageStack.getParamByIndex(pageName.length-1) as IntroduceData
                    if(data.englishTitle!=text)
                      pageStack.replacePath({ name: 'pageInfo', param: introduceDataMap.get(text) })
                  }
                }
                break;
            }
          }
        } else {
          console.log("ndef is null.");
        }
      } catch (error) {
        console.error("tag.getNdef catch error: " + error);
      }
      // other code to read or write this found tag.
    }
  } else {
    hilog.info(0x0000, 'testTag', 'readerModeCb readerModeCb error %{public}s', JSON.stringify(error));
  }
}

export default class EntryAbility extends UIAbility {
  private nfcPageText:string=''

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 判断设备是否支持NFC能力
    if (!canIUse("SystemCapability.Communication.NFC.Core")) {
      hilog.error(0x0000, 'testTag', 'nfc unavailable.');
      return;
    }

    nfcTagElementName = {
      bundleName: want.bundleName ?? '',
      abilityName: want.abilityName ?? '',
      moduleName: want.moduleName,
    }

    let tagInfo : tag.TagInfo | null = null;
    try {
      tagInfo = tag.getTagInfo(want);
    } catch (error) {
      console.error("tag.getTagInfo catch error: " + error);
    }
    if (tagInfo == null || tagInfo == undefined) {
      console.log("no TagInfo to be created, ignore it.");
      return;
    }

    // get the supported technologies for this found tag.
    let isNfcATag =  false;
    let isNdefTag =  false;
    if (tagInfo && tagInfo.technology) {
      for (let i = 0; i < tagInfo.technology.length; i++) {
        if (tagInfo.technology[i] == tag.NFC_A) {
          isNfcATag = true;
        }
        if (tagInfo.technology[i] == tag.NDEF) {
          isNdefTag = true;
        }
      }
    } else {
      console.log("tagInfo.technology is undefined or null.");
    }

    // use NfcA APIs to access the found tag.
    if (isNfcATag) {
      let nfcA : tag.NfcATag | null = null;
      try {
        nfcA = tag.getNfcA(tagInfo);
      } catch (error) {
        console.error("tag.getNfcA catch error: " + error);
      }
      // other code to read or write this found tag.
    }

    // use getIsoDep APIs to access the found tag.
    if (isNdefTag) {
      let ndef : tag.NdefTag | null = null;
      try {
        ndef = tag.getNdef(tagInfo);
        if (ndef) {
          ndef.connect();
          let ndefRecords: tag.NdefRecord[] = ndef.getNdefMessage().getNdefRecords();
          hilog.info(0x0000,'nfc',"ndef ndefMessage: " + JSON.stringify(ndefRecords));
          // 遍历所有记录
          for (let record of ndefRecords) {
            // 解析记录类型和数据
            let tnf: number = record.tnf;     // 类型名称格式（TNF）
            let type: number[] = record.rtdType; // 记录类型（如 "text" 或 "Uri"）
            let payload: number[] = record.payload; // 有效负载数据

            // 根据 TNF 和 Type 解析内容
            switch (tnf) {
              case tag.TnfType.TNF_WELL_KNOWN:
                let text: string = parseTextRecord(payload);
                this.nfcPageText = text;
                hilog.info(0x0000,'nfc',"文本记录: " + text);
                break;
            }
          }
        } else {
          console.log("ndef is null.");
        }
      } catch (error) {
        console.error("tag.getNdef catch error: " + error);
      }
      // other code to read or write this found tag.
    }
    // use the same code to handle for "NfcA/NfcB/NfcF/NfcV/Ndef/MifareClassic/MifareUL/NdefFormatable".
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    let localStorage: LocalStorage = new LocalStorage();
    localStorage.setOrCreate('nfcPageText', this.nfcPageText);
    localStorage.setOrCreate('pageStack', pageStack);
    console.log("localStorage.getOrCreate('nfcPageText'): " + localStorage.get('nfcPageText'));
    windowStage.loadContent('pages/Index',localStorage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
      AppStorage.setOrCreate('topRectHeight', topRectHeight);
      // 3. 注册监听函数，动态获取避让区域数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        }
      });
      // windowStage.getMainWindowSync().setWindowBackgroundColor('#F5DEB3');
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    if (nfcTagElementName != undefined) {
      // 调用tag模块中前台优先的接口，使能前台应用程序优先处理所发现的NFC标签功能
      let techList : number[] = [tag.NFC_A, tag.NFC_B, tag.NFC_F, tag.NFC_V];
      try {
        tag.on('readerMode', nfcTagElementName, techList, readerModeCb);
        foregroundRegister = true;
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'on readerMode error = %{public}s', JSON.stringify(error));
      }
    }
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    // 退出应用程序NFC标签页面时，调用tag模块退出前台优先功能
    if (foregroundRegister) {
      foregroundRegister = false;
      try {
        tag.off('readerMode', nfcTagElementName);
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'off readerMode error = %{public}s', JSON.stringify(error));
      }
    }
  }
}

