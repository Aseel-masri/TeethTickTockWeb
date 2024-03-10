importScripts('https://www.gstatic.com/firebasejs/8.2.5/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.2.5/firebase-messaging.js')

firebase.initializeApp({
/* apikey: "your-api-key",
authDomain: "PROJECT_NAME.firebaseapp.com",
databaseURL: "https: //PROJECT_NAME.firebaseio.com",
projectId: "PROJECT_NAME",
storageBucket: "PROJECT_NAME. appspot. com",
messagingSenderId: "MESSAGING_SENDER_ID",
appId: "APP_ID" */
apiKey: "AIzaSyAEoB1hAn7AB6HF5FDzuu41WyqmfaKZByA",
        authDomain: "messages-app-6cf66.firebaseapp.com",
        projectId: "messages-app-6cf66",
        storageBucket: "messages-app-6cf66.appspot.com",
        messagingSenderId: "614464979405",
        appId: "1:614464979405:web:fdd24c3595495ccf96c484"

});

// Retrieve an instance of Firebase Messaging so that it can handle background

const messaging = firebase.messaging();