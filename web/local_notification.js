// local_notification.js
function showNotification(title, body) {
  if (!("Notification" in window)) {
    alert("This browser does not support desktop notifications");
    return;
  }

  if (Notification.permission === "granted") {
    var notification = new Notification(title, {
      body: body,
      icon: "icon.png"
    });

    notification.onclick = function () {
      console.log("Notification clicked");
    };
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission().then(function (permission) {
      if (permission === "granted") {
        var notification = new Notification(title, {
          body: body,
          icon: "icon.png"
        });

        notification.onclick = function () {
          console.log("Notification clicked");
        };
      }
    });
  }
}
