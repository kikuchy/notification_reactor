package net.kikuchy.notification_reactor;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NotificationReactorPlugin
 */
public class NotificationReactorPlugin extends BroadcastReceiver implements MethodCallHandler, NewIntentListener {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "notification_reactor");
        final NotificationReactorPlugin plugin = new NotificationReactorPlugin(channel, registrar);
        channel.setMethodCallHandler(plugin);
        registrar.addNewIntentListener(plugin);
    }

    static final String TAG = NotificationReactorPlugin.class.getSimpleName();

    static final String ACTION_ON_RESUME = "ACTION_ON_RESUME";
    static final String EXTRA_PUSH_MESSAGE = "EXTRA_PUSH_MESSAGE";

    private MethodChannel channel;
    private Registrar registrar;
    private String triggerKey;

    private NotificationReactorPlugin(MethodChannel channel, Registrar registrar) {
        this.channel = channel;
        this.registrar = registrar;
        final IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_ON_RESUME);
        LocalBroadcastManager.getInstance(registrar.context()).registerReceiver(this, filter);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("setHandlers")) {
            if (registrar.activity() != null) {
                sendMessageFromIntent("onLaunch", registrar.activity().getIntent());
            }
            result.success(null);
        }   else if (call.method.equals("setTriggerToReact")) {
            triggerKey = (String) call.arguments;
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action == null) {
            return;
        }

        if (action.equals(ACTION_ON_RESUME)) {
            RemoteMessage message = intent.getParcelableExtra(EXTRA_PUSH_MESSAGE);
            channel.invokeMethod("onMessage", parseRemoteMessage(message));
        }
    }

    private Map<String, Object> parseRemoteMessage(RemoteMessage message) {
        Map<String, Object> ret = new HashMap<>();
        ret.put("data", message.getData());

        final RemoteMessage.Notification notification = message.getNotification();
        Map<String, String> notifMap = new HashMap<>();
        final @Nullable String title = notification != null ? notification.getTitle() : null;
        if (title != null) {
            notifMap.put("title", title);
        }
        final @Nullable String body = (notification != null) ? notification.getBody() : null;
        if (body != null) {
            notifMap.put("body", body);
        }

        ret.put("notification", notifMap);
        return ret;
    }

    private boolean sendMessageFromIntent(String method, Intent intent) {
        if (shouldTrigger(intent, triggerKey)) {
            final Bundle extras = intent.getExtras();
            if (extras == null) return false;

            Map<String, Object> messageMap;

            RemoteMessage message = extras.getParcelable(EXTRA_PUSH_MESSAGE);
            if (message != null) {
                messageMap = parseRemoteMessage(message);
            } else {
                messageMap = new HashMap<>();
                Map<String, Object> dataMap = mapFromBundle(extras);
                messageMap.put("data", dataMap);
                messageMap.put("notification", new HashMap<String, Object>());
            }

            channel.invokeMethod(method, messageMap);
            return true;
        }
        return false;
    }

    private boolean shouldTrigger(Intent intent, @Nullable String key) {
        final Bundle extras = intent.getExtras();
        if (extras == null) return false;
        if (key != null) {
            return extras.containsKey(key);
        }
        return true;
    }

    private Map<String, Object> mapFromBundle(@NonNull Bundle bundle) {
        Map<String, Object> ret = new HashMap<>();

        final Set<String> keys = bundle.keySet();
        for (String key : keys) {
            Object value = bundle.get(key);
            if (value instanceof Bundle) {
                value = mapFromBundle((Bundle) value);
            }
            if (value != null) {
                ret.put(key, value);
            }
        }
        return ret;
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        boolean res = sendMessageFromIntent("onResume", intent);
        if (res && registrar.activity() != null) {
            registrar.activity().setIntent(intent);
        }
        return res;
    }
}
