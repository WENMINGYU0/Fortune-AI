// app/src/main/java/com/fortuneai/MainActivity.java
package com.fortuneai;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private WebView webView;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();
        
        // 启用 JavaScript
        webSettings.setJavaScriptEnabled(true);
        // 允许本地文件访问
        webSettings.setAllowFileAccess(true);
        webSettings.setAllowContentAccess(true);
        // 启用 DOM storage
        webSettings.setDomStorageEnabled(true);
        // 启用数据库
        webSettings.setDatabaseEnabled(true);
        // 设置缓存模式
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
        // 支持缩放
        webSettings.setSupportZoom(false);
        webSettings.setBuiltInZoomControls(false);
        // 自适应屏幕
        webSettings.setUseWideViewPort(true);
        webSettings.setLoadWithOverviewMode(true);
        
        // 设置 WebViewClient 确保链接在 WebView 内打开
        webView.setWebViewClient(new WebViewClient());
        
        // 加载本地 HTML 文件
        webView.loadUrl("file:///android_asset/index.html");
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
