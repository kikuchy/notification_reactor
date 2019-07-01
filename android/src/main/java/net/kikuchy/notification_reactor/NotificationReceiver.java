package net.kikuchy.notification_reactor;

import android.content.Intent;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class NotificationReceiver extends FirebaseMessagingService {
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        final Intent intent = new Intent(NotificationReactorPlugin.ACTION_ON_RESUME);
        intent.putExtra(NotificationReactorPlugin.EXTRA_PUSH_MESSAGE, remoteMessage);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }
}
