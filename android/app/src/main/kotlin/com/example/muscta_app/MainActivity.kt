package muscta.com

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private var deepLinkChannel: MethodChannel? = null
	private var pendingDeepLink: String? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		// Create a MethodChannel to send deep link URLs to Dart
		deepLinkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "deep_link_handler")
		// Flush any pending deep link captured before channel was ready
		pendingDeepLink?.let { url ->
			deepLinkChannel?.invokeMethod("handleDeepLink", url)
			pendingDeepLink = null
		}
	}

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		// Handle the case where the app is launched via deep link
		handleDeepLinkIntent(intent)
	}

	override fun onNewIntent(intent: Intent) {
		super.onNewIntent(intent)
		setIntent(intent)
		// Handle deep link when app is already running
		handleDeepLinkIntent(intent)
	}

	private fun handleDeepLinkIntent(intent: Intent?) {
		val data = intent?.data
		if (data != null) {
			// Forward the URL to Dart side
			val url = data.toString()
			if (deepLinkChannel == null) {
				// Channel not ready yet (cold start). Queue it.
				pendingDeepLink = url
			} else {
				deepLinkChannel?.invokeMethod("handleDeepLink", url)
			}
		}
	}
}
