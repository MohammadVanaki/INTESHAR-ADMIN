import 'dart:typed_data';

import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
import 'package:admin/app/features/load_content/controllers/content_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'dart:io' show Platform;
import 'dart:convert';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late WebViewController controller;
  final AgentAuthController agentAuthController =
      Get.find<AgentAuthController>();

  String get baseUrl {
    final storedUrl = agentAuthController.getDashboardUrl();
    if (storedUrl != null && storedUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(storedUrl);
        return '${uri.scheme}://${uri.host}:${uri.port}';
      } catch (e) {
        return 'https://v2.inteshar.net';
      }
    }
    return 'https://v2.inteshar.net';
  }

  String get token {
    final token = agentAuthController.agentToken.value;
    if (token != null && token.isNotEmpty) {
      return token;
    }
    return '';
  }

  String get dashboardUrl {
    final storedUrl = agentAuthController.getDashboardUrl();
    if (storedUrl != null && storedUrl.isNotEmpty) {
      return storedUrl;
    }
    return '$baseUrl/Admin-AGINT/dashboard';
  }

  InAppWebViewController? webViewController;
  bool _isLoading = true;
  bool _isWebViewReady = false;
  bool _scriptInjected = false;
  final GlobalKey _webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.put(WebViewController());

    if (token.isNotEmpty) {
      controller.authToken1.value = token;
    }

    BackButtonInterceptor.add(myInterceptor);

    // تنظیم کوکی برای اندروید
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupAndroidCookies();
      });
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    webViewController = null;
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    _handleBackButton();
    return true;
  }

  Future<void> _handleBackButton() async {
    if (_isWebViewReady && webViewController != null) {
      try {
        bool canGoBack = await webViewController!.canGoBack();
        if (canGoBack) {
          await webViewController!.goBack();
        } else {
          Get.back();
        }
      } catch (e) {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  // ✅ تنظیم کوکی برای اندروید - نهایی
  Future<void> _setupAndroidCookies() async {
    if (token.isEmpty) {
      print('⚠️ No token available for cookie setup');
      return;
    }

    try {
      final cookieManager = CookieManager.instance();

      // پاک کردن کوکی‌های قدیمی
      await cookieManager.deleteAllCookies();

      final uri = Uri.parse(baseUrl);
      final webUri = WebUri(baseUrl);

      // کوکی اصلی - بدون نقطه برای دقت بیشتر
      await cookieManager.setCookie(
        url: webUri,
        name: 'auth_token',
        value: token,
        domain: uri.host,
        path: '/',
        isSecure: uri.scheme == 'https',
        isHttpOnly: false,
        maxAge: 86400 * 7,
      );

      // کوکی Authorization
      await cookieManager.setCookie(
        url: webUri,
        name: 'Authorization',
        value: 'Bearer $token',
        domain: uri.host,
        path: '/',
        isSecure: uri.scheme == 'https',
        isHttpOnly: false,
        maxAge: 86400 * 7,
      );

      // کوکی ساده token
      await cookieManager.setCookie(
        url: webUri,
        name: 'token',
        value: token,
        domain: uri.host,
        path: '/',
        isSecure: uri.scheme == 'https',
        isHttpOnly: false,
        maxAge: 86400 * 7,
      );

      // کوکی برای لاراول سانکتم
      await cookieManager.setCookie(
        url: webUri,
        name: 'XSRF-TOKEN',
        value: token,
        domain: uri.host,
        path: '/',
        isSecure: uri.scheme == 'https',
        isHttpOnly: false,
        maxAge: 86400 * 7,
      );

      print('✅ Android cookies set successfully for ${uri.host}');
    } catch (e) {
      print('❌ Android cookie error: $e');
    }
  }

  // ✅ اسکریپت مخصوص اندروید - فقط interceptors، بدون storage/cookie
  // ✅ اسکریپت مخصوص اندروید - با interceptors قوی‌تر
  Future<void> _injectAndroidScript(
    InAppWebViewController webController,
  ) async {
    if (_scriptInjected || token.isEmpty) return;

    try {
      String script =
          """
      (function() {
        // ذخیره توکن در حافظه
        window.authToken = '$token';
        window.__token = '$token';
        
        // 1. FETCH INTERCEPTOR - قوی‌تر
        if (!window.__fetchPatched) {
          window.__fetchPatched = true;
          const originalFetch = window.fetch;
          window.fetch = function(url, options = {}) {
            options.headers = options.headers || {};
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['X-Requested-With'] = 'XMLHttpRequest';
            options.credentials = 'include';
            
            // اضافه کردن توکن به URL اگر fetch باشه
            if (typeof url === 'string' && !url.includes('token=')) {
              const separator = url.includes('?') ? '&' : '?';
              url = url + separator + 'token=$token';
            }
            
            return originalFetch.call(this, url, options);
          };
          console.log('✅ Android: Fetch patched');
        }
        
        // 2. XHR INTERCEPTOR - قوی‌تر
        if (!window.__xhrPatched) {
          window.__xhrPatched = true;
          
          // Override open
          const originalOpen = XMLHttpRequest.prototype.open;
          XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
            this._url = url;
            this._method = method;
            
            // اضافه کردن توکن به URL
            if (typeof url === 'string' && !url.includes('token=')) {
              const separator = url.includes('?') ? '&' : '?';
              this._url = url + separator + 'token=$token';
            }
            
            return originalOpen.call(this, method, this._url, async, user, password);
          };
          
          // Override send
          const originalSend = XMLHttpRequest.prototype.send;
          XMLHttpRequest.prototype.send = function(data) {
            try {
              this.setRequestHeader('Authorization', 'Bearer $token');
              this.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
              this.withCredentials = true;
            } catch(e) {
              console.log('⚠️ XHR header error:', e);
            }
            return originalSend.apply(this, arguments);
          };
          
          // Override setRequestHeader برای اطمینان
          const originalSetHeader = XMLHttpRequest.prototype.setRequestHeader;
          XMLHttpRequest.prototype.setRequestHeader = function(header, value) {
            if (header.toLowerCase() === 'authorization') {
              return originalSetHeader.call(this, header, 'Bearer $token');
            }
            return originalSetHeader.apply(this, arguments);
          };
          
          console.log('✅ Android: XHR patched');
        }
        
        // 3. HISTORY PUSHSTATE INTERCEPTOR - برای SPA
        const originalPushState = history.pushState;
        history.pushState = function(state, title, url) {
          if (typeof url === 'string' && !url.includes('token=')) {
            const separator = url.includes('?') ? '&' : '?';
            url = url + separator + 'token=$token';
          }
          return originalPushState.call(this, state, title, url);
        };
        
        // 4. LINK CLICK INTERCEPTOR - برای لینک‌های معمولی
        document.addEventListener('click', function(e) {
          let target = e.target.closest('a');
          if (target && target.href && target.href.includes('${Uri.parse(baseUrl).host}')) {
            if (!target.href.includes('token=')) {
              e.preventDefault();
              const separator = target.href.includes('?') ? '&' : '?';
              window.location.href = target.href + separator + 'token=$token';
            }
          }
        }, true);
        
        // 5. FORM SUBMIT INTERCEPTOR
        document.addEventListener('submit', function(e) {
          let form = e.target;
          if (form.action && form.action.includes('${Uri.parse(baseUrl).host}')) {
            if (!form.action.includes('token=')) {
              e.preventDefault();
              const separator = form.action.includes('?') ? '&' : '?';
              form.action = form.action + separator + 'token=$token';
              form.submit();
            }
          }
        }, true);
        
        console.log('✅ Android script injected successfully');
        return true;
      })();
    """;

      await webController.evaluateJavascript(source: script);
      _scriptInjected = true;
      print('🔐 Android script injected with full interceptors');
    } catch (e) {
      print('❌ Android inject error: $e');
    }
  }

  // ✅ اسکریپت مخصوص ویندوز - با پشتیبانی بهتر از POST
  Future<void> _injectWindowsScript(
    InAppWebViewController webController,
  ) async {
    if (_scriptInjected || token.isEmpty) return;

    try {
      String script =
          """
    (function() {
      window.authToken = '$token';
      
      // ذخیره در storage
      try {
        localStorage.setItem('auth_token', '$token');
        localStorage.setToken = '$token';
        sessionStorage.setItem('auth_token', '$token');
        document.cookie = "auth_token=$token; path=/; max-age=86400";
        document.cookie = "Authorization=Bearer $token; path=/; max-age=86400";
        document.cookie = "token=$token; path=/; max-age=86400";
      } catch(e) {
        console.log('Storage error:', e);
      }
      
      // 1. FETCH INTERCEPTOR - با حفظ متد
      if (!window.__fetchPatched) {
        window.__fetchPatched = true;
        const originalFetch = window.fetch;
        window.fetch = function(url, options = {}) {
          options.headers = options.headers || {};
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['X-Requested-With'] = 'XMLHttpRequest';
          options.credentials = 'include';
          
          // فقط اگه توکن در URL نیست و GET هست، به URL اضافه کن
          if (options.method !== 'POST' && typeof url === 'string' && !url.includes('token=')) {
            const separator = url.includes('?') ? '&' : '?';
            url = url + separator + 'token=$token';
          }
          
          return originalFetch.call(this, url, options);
        };
        console.log('✅ Windows: Fetch patched (preserves POST)');
      }
      
      // 2. XHR INTERCEPTOR - با حفظ متد
      if (!window.__xhrPatched) {
        window.__xhrPatched = true;
        
        const originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
          this._method = method;
          this._originalUrl = url;
          
          // فقط برای GET توکن رو به URL اضافه کن
          if (method !== 'POST' && typeof url === 'string' && !url.includes('token=')) {
            const separator = url.includes('?') ? '&' : '?';
            url = url + separator + 'token=$token';
          }
          
          return originalOpen.call(this, method, url, async, user, password);
        };
        
        const originalSend = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function(data) {
          try {
            this.setRequestHeader('Authorization', 'Bearer $token');
            this.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            this.withCredentials = true;
          } catch(e) {
            console.log('XHR header error:', e);
          }
          return originalSend.apply(this, arguments);
        };
        
        console.log('✅ Windows: XHR patched (preserves POST)');
      }
      
      // 3. FORM SUBMIT INTERCEPTOR - برای POST فرم‌ها
      document.addEventListener('submit', function(e) {
        let form = e.target;
        if (form.action && form.action.includes('${Uri.parse(baseUrl).host}')) {
          const method = (form.method || 'GET').toUpperCase();
          
          // برای POST، فقط هدر رو اضافه کن، URL رو تغییر نده
          if (method === 'POST') {
            // اضافه کردن یک input مخفی برای توکن
            if (!form.querySelector('input[name="_token"]')) {
              const input = document.createElement('input');
              input.type = 'hidden';
              input.name = '_token';
              input.value = '$token';
              form.appendChild(input);
            }
          }
          // برای GET، توکن رو به URL اضافه کن
          else if (!form.action.includes('token=')) {
            e.preventDefault();
            const separator = form.action.includes('?') ? '&' : '?';
            form.action = form.action + separator + 'token=$token';
            form.submit();
          }
        }
      }, true);
      
      console.log('✅ Windows script injected with POST support');
      return true;
    })();
    """;

      await webController.evaluateJavascript(source: script);
      _scriptInjected = true;
      print('🔐 Windows script injected with POST support');
    } catch (e) {
      print('❌ Windows inject error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: _handleBackButton,
        ),
        title: Text(
          'لوحة التحكم',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontFamily: 'dijlah',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
            onSelected: (value) {
              if (value == 'logout_agent') {
                agentAuthController.logout();
              }
            },
            color: colorScheme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout_agent',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontFamily: 'dijlah',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: token.isEmpty
          ? _buildNoTokenError(colorScheme)
          : _buildWebView(colorScheme),
    );
  }

  Widget _buildNoTokenError(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'لم يتم تسجيل الدخول',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
                fontFamily: 'dijlah',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الرجاء تسجيل الدخول أولاً',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary.withOpacity(0.7),
                fontFamily: 'dijlah',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed('/agent/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontFamily: 'dijlah',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ متد تبدیل http به https
  // String get secureDashboardUrl {
  //   if (dashboardUrl.startsWith('http://')) {
  //     return dashboardUrl.replaceFirst('http://', 'https://');
  //   }
  //   return dashboardUrl;
  // }

  Widget _buildWebView(ColorScheme colorScheme) {
    if (token.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      children: [
        InAppWebView(
          key: _webViewKey,

          initialUrlRequest: URLRequest(
            url: WebUri('$dashboardUrl?token=$token'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
              'Cache-Control': 'no-cache',
            },
          ),
          onWebViewCreated: (webController) async {
            print('✅ WebView created on ${Platform.operatingSystem}');

            webViewController = webController;
            controller.webViewController = webController;
            controller.isWebViewControllerActive.value = true;
            _isWebViewReady = true;
            _scriptInjected = false;

            // اول کوکی‌ها رو ست کن
            if (Platform.isAndroid) {
              await _setupAndroidCookies();
            }

            // بعد اسکریپت رو تزریق کن
            if (Platform.isAndroid) {
              await _injectAndroidScript(webController);
            } else {
              await _injectWindowsScript(webController);
            }
          },
          onLoadStart: (webController, url) async {
            print('🌐 Loading: $url');
            setState(() => _isLoading = true);

            final host = Uri.parse(baseUrl).host;
            if (url?.toString().contains(host) ?? false) {
              // اسکریپت برای هندل کردن multipart/form-data
              String script =
                  """
    (function() {
      // ذخیره متد submit اصلی
      const originalSubmit = HTMLFormElement.prototype.submit;
      
      // override کردن متد submit
      HTMLFormElement.prototype.submit = function() {
        const form = this;
        const enctype = form.enctype;
        const method = (form.method || 'GET').toUpperCase();
        
        console.log('📋 فرم با enctype:', enctype, 'method:', method);
        
        // اگر multipart/form-data و POST هست
        if (enctype === 'multipart/form-data' && method === 'POST') {
          console.log('📋 تشخیص multipart/form-data در فرم');
          
          // اضافه کردن توکن به صورت field مخفی اگر وجود نداره
          if (!form.querySelector('input[name="_token"]')) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = '_token';
            input.value = '$token';
            form.appendChild(input);
          }
        }
        
        // فراخوانی متد اصلی
        return originalSubmit.apply(this, arguments);
      };
      
      console.log('✅ Multipart form handler injected');
    })();
    """;

              await webController.evaluateJavascript(source: script);
            }
          },
          onLoadStop: (webController, url) async {
            print('✅ Loaded: $url');

            setState(() => _isLoading = false);

            controller.finishLoading();
            controller.currentUrl.value = url.toString();

            // دوباره اسکریپت رو تزریق کن برای اطمینان
            if (Platform.isAndroid) {
              await _injectAndroidScript(webController);
            } else {
              await _injectWindowsScript(webController);
            }
          },
          onProgressChanged: (webController, progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onReceivedError: (webController, request, error) {
            print('❌ Error: ${error.description}');
            setState(() => _isLoading = false);
            if (request.isForMainFrame ?? false) {
              controller.setError('خطأ في الاتصال');
            }
          },
          onReceivedHttpError: (webController, request, errorResponse) {
            print('❌ HTTP Error ${errorResponse.statusCode}');
            setState(() => _isLoading = false);

            if (errorResponse.statusCode == 401) {
              controller.setError('غير مصرح بالدخول');
              if (Platform.isAndroid) {
                _setupAndroidCookies();
              }
            }
          },
          shouldOverrideUrlLoading: (webController, navigationAction) async {
            final request = navigationAction.request;
            var url = request.url.toString();
            final host = Uri.parse(baseUrl).host;
            final uri = Uri.parse(url);
            String lastProcessedUrl = '';
            DateTime lastProcessedTime = DateTime.now();

            // در shouldOverrideUrlLoading، قبل از پردازش:
            // بررسی درخواست تکراری
            String requestKey =
                '$url-${request.method}-${request.body?.length}';
            if (lastProcessedUrl == requestKey &&
                DateTime.now().difference(lastProcessedTime).inMilliseconds <
                    500) {
              print('⚠️ درخواست تکراری رد شد');
              return NavigationActionPolicy.CANCEL;
            }

            // بعد از پردازش درخواست:
            lastProcessedUrl = requestKey;
            lastProcessedTime = DateTime.now();
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('🌐 **درخواست جدید**');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('📌 مسیر: ${uri.path}');
            print('🔗 آدرس کامل: $url');
            print('📡 متد: ${request.method ?? "GET"}');
            print('🔑 دارای توکن: ${url.contains("token=") ? "✅" : "❌"}');
            print(
              '📦 دارای body: ${request.body != null ? "✅ (${request.body!.length} bytes)" : "❌"}',
            );

            if (request.headers != null &&
                request.headers!.containsKey('Content-Type')) {
              print('📋 Content-Type: ${request.headers!['Content-Type']}');
            }

            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

            if (url.contains(host)) {
              if (!url.contains('token=')) {
                final separator = url.contains('?') ? '&' : '?';
                url = url + separator + 'token=$token';

                print('🔄 Adding token to URL: $url');

                if (request.method == 'POST') {
                  bool isMultipart = false;
                  Map<String, String> headers = {};

                  if (request.headers != null) {
                    headers.addAll(request.headers!);
                    String? contentType = request.headers!['Content-Type'];
                    if (contentType != null &&
                        contentType.contains('multipart/form-data')) {
                      isMultipart = true;
                      print('📋 تشخیص multipart/form-data داده شد');
                    }
                  }

                  headers['Authorization'] = 'Bearer $token';
                  headers['X-Requested-With'] = 'XMLHttpRequest';

                  // یه تاخیر کوچیک برای اطمینان از کنسل شدن درخواست قبلی
                  await Future.delayed(Duration(milliseconds: 50));

                  if (isMultipart) {
                    print('📦 ارسال درخواست multipart/form-data');

                    // ارسال درخواست جدید
                    await webController.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(url),
                        method: 'POST',
                        headers: headers,
                        body: request.body,
                      ),
                    );
                  } else {
                    await webController.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(url),
                        method: 'POST',
                        headers: headers,
                        body: request.body,
                      ),
                    );
                  }
                } else {
                  await webController.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri(url),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'X-Requested-With': 'XMLHttpRequest',
                      },
                    ),
                  );
                }

                // برگردوندن CANCEL برای جلوگیری از ادامه درخواست اصلی
                return NavigationActionPolicy.CANCEL;
              }

              // اگه توکن داره ولی درخواست POST هست و ما قبلاً هندلش نکردیم
              if (request.method == 'POST' && url.contains('token=')) {
                print('🔄 درخواست POST با توکن - اجازه ادامه میدیم');
                return NavigationActionPolicy.ALLOW;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: false,
            cacheEnabled: false,
            transparentBackground: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            userAgent: Platform.isAndroid
                ? "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36"
                : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            allowFileAccess: true,
            allowContentAccess: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            incognito: true,
            allowUniversalAccessFromFileURLs: Platform.isAndroid,
            allowFileAccessFromFileURLs: Platform.isAndroid,
            mediaPlaybackRequiresUserGesture: !Platform.isAndroid,
            supportZoom: !Platform.isAndroid,
          ),
        ),
        if (_isLoading)
          Container(
            color: colorScheme.primary.withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.secondary,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  Gap(20),
                  Text(
                    'جارٍ التحميل...',
                    style: TextStyle(
                      fontFamily: 'dijlah',
                      color: colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // اضافه کردن این متغیرها به کلاس _ContentViewState
  bool _isProcessingRequest = false;
  Map<int, bool> _requestCompleted = {};
  int _requestCounter = 0;

  Future<void> _handlePostRequest(String url, Uint8List? body) async {
    if (webViewController == null) return;

    // اگه درخواست دیگه‌ای در حال پردازشه، صبر کن
    while (_isProcessingRequest) {
      print('⏳ Waiting for previous request to complete...');
      await Future.delayed(Duration(milliseconds: 100));
    }

    _isProcessingRequest = true;

    try {
      // افزایش شمارنده برای هر درخواست جدید
      _requestCounter++;
      final currentRequestId = _requestCounter;
      _requestCompleted[currentRequestId] = false;

      print('🎯 Processing request #$currentRequestId');

      // پاک کردن درخواست‌های قبلی که کامل شدن
      _requestCompleted.removeWhere(
        (id, completed) => completed && id < currentRequestId - 1,
      );

      // تبدیل body به رشته
      String bodyString = '';
      if (body != null) {
        bodyString = utf8.decode(body);
        print('📦 Body string #$currentRequestId: $bodyString');
      }

      // پارس کردن body به صورت key=value
      Map<String, String> formData = {};
      String action = 'unknown';

      if (bodyString.isNotEmpty) {
        List<String> pairs = bodyString.split('&');
        for (String pair in pairs) {
          var parts = pair.split('=');
          if (parts.length == 2) {
            try {
              String key = Uri.decodeComponent(parts[0]);
              String value = Uri.decodeComponent(parts[1]);
              if (!formData.containsKey(key)) {
                formData[key] = value;
                print('🔑 Form field #$currentRequestId: $key = $value');

                if (key == 'clicked_button') {
                  action = value;
                }
              }
            } catch (e) {
              print('⚠️ Error decoding pair: $pair');
            }
          }
        }
      }

      // ساخت URL-encoded string
      String urlEncodedBody = '';
      formData.forEach((key, value) {
        if (urlEncodedBody.isNotEmpty) urlEncodedBody += '&';
        urlEncodedBody +=
            '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}';
      });
      if (urlEncodedBody.isNotEmpty) urlEncodedBody += '&';
      urlEncodedBody += '_token=${Uri.encodeComponent(token)}';

      print('📦 URL-encoded body #$currentRequestId: $urlEncodedBody');
      print('🎯 Action type #$currentRequestId: $action');

      // ساخت جاوااسکریپت با شناسه درخواست و مکانیزم قفل
      String script =
          """
    (function() {
      return new Promise(function(resolve, reject) {
        const requestId = $currentRequestId;
        const url = '$url';
        const token = '$token';
        const bodyString = '$urlEncodedBody';
        const action = '$action';
        
        console.log('🚀 [Request #' + requestId + '] Starting...');
        console.log('📦 [Request #' + requestId + '] Body:', bodyString);
        console.log('🎯 [Request #' + requestId + '] Action:', action);
        
        // ذخیره در localStorage که این درخواست شروع شده
        try {
          localStorage.setItem('current_request_' + requestId, 'started');
        } catch(e) {}
        
        fetch(url, {
          method: 'POST',
          headers: {
            'Authorization': 'Bearer ' + token,
            'X-Requested-With': 'XMLHttpRequest',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': '*/*',
          },
          body: bodyString,
          credentials: 'include'
        })
        .then(async function(response) {
          console.log('📥 [Request #' + requestId + '] Response status:', response.status);
          
          if (!response.ok) {
            throw new Error('HTTP error ' + response.status);
          }
          
          const contentType = response.headers.get('content-type') || '';
          console.log('📄 [Request #' + requestId + '] Content-Type:', contentType);
          
          // بررسی کنیم که آیا این درخواست هنوز معتبر هست
          const currentRequest = localStorage.getItem('current_request_' + requestId);
          if (currentRequest !== 'started') {
            console.log('⚠️ [Request #' + requestId + '] Request cancelled or expired');
            return;
          }
          
          // اگه فایل هست (excel یا pdf)
          if (action === 'excel' || action === 'pdf' || 
              contentType.includes('spreadsheet') || 
              contentType.includes('pdf') || 
              contentType.includes('octet-stream')) {
            
            const blob = await response.blob();
            console.log('✅ [Request #' + requestId + '] Blob received:', blob.size, 'bytes');
            
            const downloadUrl = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = downloadUrl;
            
            const disposition = response.headers.get('content-disposition') || '';
            const filenameMatch = disposition.match(/filename[^;=\\n]*=((['"]).*?\\2|[^;\\n]*)/);
            let filename = action + '_' + Date.now() + 
                          (contentType.includes('pdf') ? '.pdf' : '.xlsx');
            
            if (filenameMatch && filenameMatch[1]) {
              filename = filenameMatch[1].replace(/['"]/g, '');
            }
            
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            
            setTimeout(function() {
              window.URL.revokeObjectURL(downloadUrl);
              document.body.removeChild(a);
              localStorage.removeItem('current_request_' + requestId);
              console.log('✅ [Request #' + requestId + '] Download completed');
              resolve('download_started');
            }, 1000);
          } 
          // اگه صفحه HTML هست (print)
          else if (action === 'print' || contentType.includes('text/html')) {
            const html = await response.text();
            console.log('✅ [Request #' + requestId + '] HTML received:', html.length, 'bytes');
            
            // ایجاد یک iframe برای پرینت
            const iframe = document.createElement('iframe');
            iframe.style.position = 'absolute';
            iframe.style.width = '0';
            iframe.style.height = '0';
            iframe.style.border = 'none';
            document.body.appendChild(iframe);
            
            const iframeDoc = iframe.contentWindow.document;
            iframeDoc.open();
            iframeDoc.write(html);
            iframeDoc.close();
            
            iframe.onload = function() {
              setTimeout(function() {
                try {
                  iframe.contentWindow.focus();
                  iframe.contentWindow.print();
                  
                  setTimeout(function() {
                    document.body.removeChild(iframe);
                    localStorage.removeItem('current_request_' + requestId);
                    console.log('✅ [Request #' + requestId + '] Print completed');
                    resolve('print_started');
                  }, 1000);
                } catch (e) {
                  console.error('❌ [Request #' + requestId + '] Print error:', e);
                  document.body.removeChild(iframe);
                  localStorage.removeItem('current_request_' + requestId);
                  reject(e.toString());
                }
              }, 500);
            };
          } else {
            console.log('⚠️ [Request #' + requestId + '] Unknown response type');
            localStorage.removeItem('current_request_' + requestId);
            resolve('unknown_response');
          }
        })
        .catch(function(error) {
          console.error('❌ [Request #' + requestId + '] Fetch error:', error);
          localStorage.removeItem('current_request_' + requestId);
          reject(error.toString());
        });
      })();
    })();
    """;

      print('🚀 Executing fetch script for request #$currentRequestId...');
      var result = await webViewController!.evaluateJavascript(source: script);
      print('✅ Request #$currentRequestId handled with fetch, result: $result');

      // Mark as completed
      _requestCompleted[currentRequestId] = true;
    } catch (e) {
      print('❌ Error handling request #$_requestCounter: $e');
    } finally {
      _isProcessingRequest = false;
    }
  }
}
