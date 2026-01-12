import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CookiePlaygroundWatch {
  controller: webview.WebviewController = new webview.WebviewController();

  @State url: string = '';
  @State cookieValue: string = 'demoKey=demoValue';
  @State fetchedCookies: string = 'Tap \'Fetch\' to read cookies';
  @State incognito: boolean = false;
  @State showWebview: boolean = false;

  private setCookie(): void {
    try {
      const fullCookie: string = `${this.cookieValue}; path=/`;
      webview.WebCookieManager.configCookieSync(this.url, fullCookie);
      console.info('configCookieSync: cookie set successfully.');
      this.fetchedCookies = '✓ Cookie set successfully';
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`configCookieSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Set failed: ${err.message}`;
    }
  }

  private fetchCookie(): void {
    try {
      const value: string = webview.WebCookieManager.fetchCookieSync(this.url, this.incognito);
      this.fetchedCookies = (!value || value.trim() === '') ? '(No cookies found)' : value;
      console.info(`fetchCookieSync (incognito=${this.incognito}): ${value}`);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`fetchCookieSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Fetch failed: ${err.message}`;
    }
  }

  private clearCookies(): void {
    try {
      webview.WebCookieManager.clearAllCookiesSync();
      this.fetchedCookies = '✓ All cookies cleared';
      console.info('All cookies cleared');
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`clearAllCookiesSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Clear failed: ${err.message}`;
    }
  }

  private applyCookieAndReload(): void {
    this.setCookie();
    try {
      this.controller.loadUrl(this.url);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`reload failed, code=${err.code}, msg=${err.message}`);
    }
  }

  private buildInjectScript(): string {
    // Build as one normal string; avoid ${} and avoid "+" concatenation in the JS code itself.
    // Use String.concat chains in ArkTS to avoid "es6_string_concatenation" warnings.
    return '(function () {'
      .concat('  try {')
      .concat('    var banner = document.getElementById("hos-cookie-banner");')
      .concat('    if (!banner) {')
      .concat('      banner = document.createElement("div");')
      .concat('      banner.id = "hos-cookie-banner";')
      .concat('      banner.style.position = "fixed";')
      .concat('      banner.style.left = "0";')
      .concat('      banner.style.right = "0";')
      .concat('      banner.style.top = "0";')
      .concat('      banner.style.zIndex = "99999";')
      .concat('      banner.style.padding = "8px 4px";')
      .concat('      banner.style.fontSize = "12px";')
      .concat('      banner.style.textAlign = "center";')
      .concat('      banner.style.fontFamily = "sans-serif";')
      .concat('      banner.style.background = "#007AFF";')
      .concat('      banner.style.color = "#ffffff";')
      .concat('      document.body.appendChild(banner);')
      .concat('    }')
      .concat('    var cookies = document.cookie || "(no cookies)";')
      .concat('    banner.textContent = "document.cookie = ".concat(cookies);')
      .concat('    if (cookies.indexOf("theme=dark") !== -1) {')
      .concat('      document.body.style.backgroundColor = "#111111";')
      .concat('      document.body.style.color = "#ffffff";')
      .concat('    }')
      .concat('  } catch (e) {')
      .concat('    console.error("Cookie banner injection error", e);')
      .concat('  }')
      .concat('})();');
  }

  build(): void {
    Scroll() {
      Column({ space: 16 }) {
        Text('🍪 Cookie Manager')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .margin({ top: 12 });

        Column({ space: 10 }) {
          Text('Target URL')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start);

          TextInput({ text: this.url, placeholder: 'Enter URL' })
            .onChange((value: string) => { this.url = value; })
            .backgroundColor('#2a2a2a')
            .fontColor('#ffffff')
            .fontSize(12)
            .height(36);
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12);

        Column({ space: 10 }) {
          Text('Cookie Value')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start);

          TextInput({ text: this.cookieValue, placeholder: 'key=value' })
            .onChange((value: string) => { this.cookieValue = value; })
            .backgroundColor('#2a2a2a')
            .fontColor('#ffffff')
            .fontSize(12)
            .height(36);
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12);

        Row() {
          Text('Incognito Mode')
            .fontSize(14)
            .fontColor('#ffffff')
            .layoutWeight(1);

          Toggle({ type: ToggleType.Switch, isOn: this.incognito })
            .onChange((isOn: boolean) => { this.incognito = isOn; })
            .selectedColor('#007AFF');
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12);

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Button('Set Cookie')
              .onClick(() => this.setCookie())
              .backgroundColor('#007AFF')
              .fontSize(12)
              .layoutWeight(1)
              .height(38);

            Button('Fetch')
              .onClick(() => this.fetchCookie())
              .backgroundColor('#34C759')
              .fontSize(12)
              .layoutWeight(1)
              .height(38);
          }
          .width('100%');

          Row({ space: 8 }) {
            Button('Clear All')
              .onClick(() => this.clearCookies())
              .backgroundColor('#FF3B30')
              .fontSize(12)
              .layoutWeight(1)
              .height(38);

            Button(this.showWebview ? 'Hide Web' : 'Show Web')
              .onClick(() => { this.showWebview = !this.showWebview; })
              .backgroundColor('#FF9500')
              .fontSize(12)
              .layoutWeight(1)
              .height(38);
          }
          .width('100%');

          Row({ space: 8 }) {
            Button('Apply & Reload')
              .onClick(() => this.applyCookieAndReload())
              .backgroundColor('#0A84FF')
              .fontSize(12)
              .layoutWeight(1)
              .height(38);
          }
          .width('100%');
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12);

        Column({ space: 8 }) {
          Text('Fetched Cookies')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start);

          Text(this.fetchedCookies)
            .fontSize(11)
            .fontColor('#ffffff')
            .width('100%')
            .padding(10)
            .backgroundColor('#2a2a2a')
            .borderRadius(8)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12);

        if (this.showWebview) {
          Column({ space: 8 }) {
            Text('Web Preview')
              .fontSize(14)
              .fontColor('#aaaaaa');

            Web({ src: this.url, controller: this.controller })
              .javaScriptAccess(true)
              .fileAccess(false)
              .geolocationAccess(false)
              .width('100%')
              .height(200)
              .borderRadius(8)
              .onPageEnd((_event) => {
                console.info('Page loaded, injecting cookie banner.');
                const script: string = this.buildInjectScript();

                try {
                  this.controller.runJavaScript(script);
                } catch (e) {
                  const errMsg: string = String((e as Error)?.message ?? e);
                  console.error(`runJavaScript error: ${errMsg}`);
                }
              })
              .onErrorReceive((event) => {
                console.error(`Web error: ${event?.error.getErrorInfo()}`);
              });
          }
          .width('90%')
          .padding(12)
          .backgroundColor('#1e1e1e')
          .borderRadius(12);
        }
      }
      .width('100%')
      .padding({ bottom: 16 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0a0a0a')
    .scrollBar(BarState.Auto);
  }
}