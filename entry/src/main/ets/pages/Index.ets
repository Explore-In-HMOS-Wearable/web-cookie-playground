import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CookiePlaygroundWatch {
  // WebView controller to control the Web component
  controller: webview.WebviewController = new webview.WebviewController();

  // State
  @State url: string = '';                             // Target URL
  @State cookieValue: string = 'demoKey=demoValue';    // Cookie key=value
  @State fetchedCookies: string = 'Tap \'Fetch\' to read cookies';
  @State incognito: boolean = false;                   // Normal vs incognito store
  @State showWebview: boolean = false;                 // Show / hide Web preview

  // Set cookie: configCookieSync(url, cookieString)
  private setCookie() {
    try {
      const fullCookie = `${this.cookieValue}; path=/`;
      webview.WebCookieManager.configCookieSync(this.url, fullCookie);
      console.info('configCookieSync: cookie set successfully.');
      this.fetchedCookies = '✓ Cookie set successfully';
    } catch (error) {
      const err = error as BusinessError;
      console.error(`configCookieSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Set failed: ${err.message}`;
    }
  }

  // Fetch cookie: fetchCookieSync(url, incognito)
  private fetchCookie() {
    try {
      const value = webview.WebCookieManager.fetchCookieSync(this.url, this.incognito);
      if (!value || value.trim() === '') {
        this.fetchedCookies = '(No cookies found)';
      } else {
        this.fetchedCookies = value;
      }
      console.info(`fetchCookieSync (incognito=${this.incognito}): ${value}`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`fetchCookieSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Fetch failed: ${err.message}`;
    }
  }

  // Clear all cookies: clearAllCookiesSync()
  private clearCookies() {
    try {
      webview.WebCookieManager.clearAllCookiesSync();
      this.fetchedCookies = '✓ All cookies cleared';
      console.info('All cookies cleared');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`clearAllCookiesSync failed, code=${err.code}, msg=${err.message}`);
      this.fetchedCookies = `✗ Clear failed: ${err.message}`;
    }
  }

  // Helper: set cookie + reload WebView so page can read it
  private applyCookieAndReload() {
    this.setCookie();
    try {
      this.controller.loadUrl(this.url);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`reload failed, code=${err.code}, msg=${err.message}`);
    }
  }

  build() {
    // Scrollable layout – good for circular/small screens
    Scroll() {
      Column({ space: 16 }) {
        // Header
        Text('🍪 Cookie Manager')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .margin({ top: 12 })

        // URL Input Card
        Column({ space: 10 }) {
          Text('Target URL')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start)

          TextInput({ text: this.url, placeholder: 'Enter URL' })
            .onChange((value: string) => { this.url = value; })
            .backgroundColor('#2a2a2a')
            .fontColor('#ffffff')
            .fontSize(12)
            .height(36)
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12)

        // Cookie Value Card
        Column({ space: 10 }) {
          Text('Cookie Value')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start)

          TextInput({ text: this.cookieValue, placeholder: 'key=value' })
            .onChange((value: string) => { this.cookieValue = value; })
            .backgroundColor('#2a2a2a')
            .fontColor('#ffffff')
            .fontSize(12)
            .height(36)
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12)

        // Incognito Toggle
        Row() {
          Text('Incognito Mode')
            .fontSize(14)
            .fontColor('#ffffff')
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.incognito })
            .onChange((isOn: boolean) => { this.incognito = isOn; })
            .selectedColor('#007AFF')
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12)

        // Action Buttons
        Column({ space: 8 }) {
          // Row 1: set + fetch
          Row({ space: 8 }) {
            Button('Set Cookie')
              .onClick(() => this.setCookie())
              .backgroundColor('#007AFF')
              .fontSize(12)
              .layoutWeight(1)
              .height(38)

            Button('Fetch')
              .onClick(() => this.fetchCookie())
              .backgroundColor('#34C759')
              .fontSize(12)
              .layoutWeight(1)
              .height(38)
          }
          .width('100%')

          // Row 2: clear + show/hide Web
          Row({ space: 8 }) {
            Button('Clear All')
              .onClick(() => this.clearCookies())
              .backgroundColor('#FF3B30')
              .fontSize(12)
              .layoutWeight(1)
              .height(38)

            Button(this.showWebview ? 'Hide Web' : 'Show Web')
              .onClick(() => { this.showWebview = !this.showWebview; })
              .backgroundColor('#FF9500')
              .fontSize(12)
              .layoutWeight(1)
              .height(38)
          }
          .width('100%')

          // Row 3: apply + reload (cookie effect on Web)
          Row({ space: 8 }) {
            Button('Apply & Reload')
              .onClick(() => this.applyCookieAndReload())
              .backgroundColor('#0A84FF')
              .fontSize(12)
              .layoutWeight(1)
              .height(38)
          }
          .width('100%')
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12)

        // Fetched Cookies Display
        Column({ space: 8 }) {
          Text('Fetched Cookies')
            .fontSize(14)
            .fontColor('#aaaaaa')
            .alignSelf(ItemAlign.Start)

          Text(this.fetchedCookies)
            .fontSize(11)
            .fontColor('#ffffff')
            .width('100%')
            .padding(10)
            .backgroundColor('#2a2a2a')
            .borderRadius(8)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('90%')
        .padding(12)
        .backgroundColor('#1e1e1e')
        .borderRadius(12)

        // Web Preview with JS banner injection
        if (this.showWebview) {
          Column({ space: 8 }) {
            Text('Web Preview')
              .fontSize(14)
              .fontColor('#aaaaaa')

            Web({ src: this.url, controller: this.controller })
              .javaScriptAccess(true)
              .width('100%')
              .height(200)
              .borderRadius(8)
              .onPageEnd((_event) => {
                console.info('Page loaded, injecting cookie banner.');

                const script = `
                  (function () {
                    try {
                      let banner = document.getElementById('hos-cookie-banner');
                      if (!banner) {
                        banner = document.createElement('div');
                        banner.id = 'hos-cookie-banner';
                        banner.style.position = 'fixed';
                        banner.style.left = '0';
                        banner.style.right = '0';
                        banner.style.top = '0';
                        banner.style.zIndex = '99999';
                        banner.style.padding = '8px 4px';
                        banner.style.fontSize = '12px';
                        banner.style.textAlign = 'center';
                        banner.style.fontFamily = 'sans-serif';
                        banner.style.background = '#007AFF';
                        banner.style.color = '#ffffff';
                        document.body.appendChild(banner);
                      }
                      const cookies = document.cookie || '(no cookies)';
                      banner.textContent = 'document.cookie = ' + cookies;

                      // Optional: theme demo
                      if (cookies.indexOf('theme=dark') !== -1) {
                        document.body.style.backgroundColor = '#111111';
                        document.body.style.color = '#ffffff';
                      }
                    } catch (e) {
                      console.error('Cookie banner injection error);
                    }
                  })();
                `;

                try {
                  this.controller.runJavaScript(script);
                } catch (e) {
                  console.error(`runJavaScript error: ${(e as Error).message}`);
                }
              })
              .onErrorReceive((event) => {
                console.error(`Web error: ${event?.error.getErrorInfo()}`);
              })
          }
          .width('90%')
          .padding(12)
          .backgroundColor('#1e1e1e')
          .borderRadius(12)
        }
      }
      .width('100%')
      .padding({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0a0a0a')
    .scrollBar(BarState.Auto)
  }
}