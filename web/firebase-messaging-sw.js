importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCYV_4lTeFYDIcaGZqDM9CT6VDJ7L9ZYOk",
  authDomain: "forsa-204b9.firebaseapp.com",
  projectId: "forsa-204b9",
  storageBucket: "forsa-204b9.firebasestorage.app",
  messagingSenderId: "134152629656",
  appId: "1:134152629656:web:539b2b23784823d6bdcfed",
  measurementId: "G-PKL2RBSP54"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
