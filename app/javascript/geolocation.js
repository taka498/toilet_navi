function errorMessageFromGeolocationError(error) {
  if (!error || typeof error.code !== "number") {
    return "位置情報の取得に失敗しました。";
  }

  if (error.code === 1) {
    return "位置情報の利用が許可されていません。ブラウザの設定で許可してください。";
  }
  if (error.code === 2) {
    return "位置情報を取得できませんでした（利用できない可能性があります）。";
  }
  if (error.code === 3) {
    return "位置情報の取得がタイムアウトしました。もう一度お試しください。";
  }

  return "位置情報の取得に失敗しました。";
}

function setupGeolocationButton() {
  const button = document.getElementById("get-location");
  const result = document.getElementById("location-result");

  if (!button || !result) return;

  button.addEventListener("click", () => {
    result.textContent = "";

    if (!("geolocation" in navigator)) {
      result.textContent = "このブラウザでは位置情報（Geolocation）が利用できません。";
      return;
    }

    result.textContent = "現在地を取得しています...";

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        const accuracy = position.coords.accuracy;

        result.textContent =
          `取得できました。緯度: ${lat.toFixed(6)}, 経度: ${lng.toFixed(6)}（精度: 約${Math.round(accuracy)}m）`;
      },
      (error) => {
        result.textContent = errorMessageFromGeolocationError(error);
      },
      {
        enableHighAccuracy: true,
        timeout: 8000,
        maximumAge: 0,
      }
    );
  });
}

document.addEventListener("turbo:load", setupGeolocationButton);
