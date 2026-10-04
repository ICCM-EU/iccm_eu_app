// Single source of truth for Firebase Configuration across Web (Service Worker & Flutter App)
const firebaseConfig = {
  apiKey: "AIzaSyDv63cLTJEOcGFz1sxvQj3BF_4KCbg4p-E",
  authDomain: "iccmeu-app.firebaseapp.com",
  projectId: "iccmeu-app",
  storageBucket: "iccmeu-app.firebasestorage.app",
  messagingSenderId: "458814741758",
  appId: "1:458814741758:web:b883d625127fde92cdd9af",
  vapidKey: "BGEz4g_2DgMpiDTsZo6i36iFJOM3nZvOKf_KR_EliLRzJWDmgc25hooKJBoGtlzj-0CaQbs9gVkeOuqEaoPsgTY"
};

if (typeof self !== 'undefined') {
  self.firebaseConfig = firebaseConfig;
}
if (typeof window !== 'undefined') {
  window.firebaseConfig = firebaseConfig;
}
