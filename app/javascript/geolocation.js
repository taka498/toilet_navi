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

let map; // グローバル保持
let selectedToiletId = null;
let toiletMarkersById = {};

const FACILITY_ICON_DEFS = [
  { key: "is_wheelchair_accessible", label: "車椅子", icon: "♿" },
  { key: "is_ostomate_accessible", label: "オストメイト", icon: "🧻" }, // 仮
  { key: "is_baby_friendly", label: "ベビー", icon: "👶" },
  { key: "is_gender_separated", label: "男女別", icon: "🚻" },
  { key: "is_multipurpose", label: "多目的", icon: "⭐" },
];

function buildFacilityIconsHtml(toilet) {
  return FACILITY_ICON_DEFS
    .filter((def) => toilet[def.key])
    .map((def) => {
      return `<span class="facility-icon" title="${escapeHtml(def.label)}">${def.icon}</span>`;
    })
    .join("");
}


function setupGeolocationButton() {
  const button = document.getElementById("get-location");
  const result = document.getElementById("location-result");
  const mapElement = document.getElementById("map");

  if (!button || !result || !mapElement) return;

  // ✅ Turbo再訪で多重登録されないように
  if (button.dataset.geolocationBound === "true") return;
  button.dataset.geolocationBound = "true";

  const apiKey = mapElement.dataset.mapApiKeyValue;
  const toiletsJson = mapElement.dataset.mapToiletsValue || "[]";
  const toilets = JSON.parse(toiletsJson);

  const modalClose = document.getElementById("toilet-modal-close");
  const modalBackdrop = document.getElementById("toilet-modal-backdrop");

  if (modalClose && modalClose.dataset.bound !== "true") {
    modalClose.dataset.bound = "true";
    modalClose.addEventListener("click", closeToiletModal);
  }
  if (modalBackdrop && modalBackdrop.dataset.bound !== "true") {
    modalBackdrop.dataset.bound = "true";
    modalBackdrop.addEventListener("click", closeToiletModal);
  }

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

        loadGoogleMap(apiKey, lat, lng, toilets);
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

function loadGoogleMap(apiKey, lat, lng, toilets) {
  if (window.google && window.google.maps && typeof window.google.maps.Map === "function") {
    initMap(lat, lng, toilets);
    return;
  }

  const existingScript = document.getElementById("google-maps-script");
  if (existingScript) {
    window.__initGoogleMap = () => initMap(lat, lng, toilets);
    return;
  }

  window.__initGoogleMap = () => initMap(lat, lng, toilets);

  const script = document.createElement("script");
  script.id = "google-maps-script";

  // 警告を減らす：loading=async を付与（callbackは維持）
  script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=__initGoogleMap&loading=async`;

  script.async = true;
  document.head.appendChild(script);
}

function initMap(lat, lng, toilets) {
  map = new google.maps.Map(document.getElementById("map"), {
    center: { lat, lng },
    zoom: 12, // トイレが散らばっているので少し広めに（必要なら16に戻してOK）
  });

  // 現在地ピン（見分けやすく青）
  const currentMarker = new google.maps.Marker({
    position: { lat, lng },
    map: map,
    title: "現在地",
    icon: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png",
  });

  // ✅ 現在地ピンもクリックで中心移動（あなたの意図どおり）
  currentMarker.addListener("click", () => {
    map.panTo(currentMarker.getPosition());
    // ついでにズームも寄せたいなら↓（MVPなら好み）
    // map.setZoom(16);
  });

  renderToiletMarkers(toilets);
  renderToiletList(toilets);
}

/* --------------------
   トイレのピン描画
-------------------- */
function renderToiletMarkers(toilets) {
  toiletMarkersById = {};

  toilets.forEach((toilet) => {
    const marker = new google.maps.Marker({
      position: {
        lat: Number(toilet.latitude),
        lng: Number(toilet.longitude),
      },
      map: map,
      title: toilet.name,
    });

    toiletMarkersById[toilet.id] = marker;

    marker.addListener("click", () => {
      handleToiletSelect(toilet, {
        lat: Number(toilet.latitude),
        lng: Number(toilet.longitude),
      });
      // map.setZoom(16); // 寄せたいなら
    });
  });
}

/* --------------------
   トイレ一覧描画（簡易）
   - 運営会社名 + 駅名
   - booleanはアイコン
   - 選択状態ハイライト
-------------------- */
function renderToiletList(toilets) {
  const list = document.getElementById("toilet-list");
  if (!list) return;

  list.innerHTML = "";

  toilets.forEach((toilet) => {
    const stationName = toilet.station?.name || "";
    const operatorName = toilet.station?.operator_name || "";
    const header = `${operatorName}${stationName ? " / " + stationName : ""}`;

    const item = document.createElement("div");
    item.className = "toilet-card";
    item.dataset.toiletId = String(toilet.id);

    item.innerHTML = `
      <div class="toilet-card__title">${escapeHtml(header)}</div>
      <div class="toilet-card__row">
        <div class="toilet-card__name">${escapeHtml(toilet.name)}</div>
        <div class="toilet-card__icons">${buildFacilityIconsHtml(toilet)}</div>
      </div>
    `;

    item.addEventListener("click", () => {
      handleToiletSelect(toilet, {
        lat: Number(toilet.latitude),
        lng: Number(toilet.longitude),
      });
    });


    list.appendChild(item);
  });

  applySelectedStyle();
}

function selectToilet(toilet) {
  selectedToiletId = toilet.id;
  applySelectedStyle();
  highlightSelectedMarker(toilet.id);
}

function applySelectedStyle() {
  const list = document.getElementById("toilet-list");
  if (!list) return;

  Array.from(list.children).forEach((el) => {
    const id = Number(el.dataset.toiletId);
    if (id === selectedToiletId) {
      el.classList.add("is-selected");
    } else {
      el.classList.remove("is-selected");
    }
  });
}

function highlightSelectedMarker(toiletId) {
  Object.entries(toiletMarkersById).forEach(([id, marker]) => {
    if (Number(id) === toiletId) {
      marker.setIcon("http://maps.google.com/mapfiles/ms/icons/green-dot.png");
    } else {
      marker.setIcon(null);
    }
  });
}

// XSS対策（最低限）
function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (s) => {
    const map = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" };
    return map[s];
  });
}

function handleToiletSelect(toilet, panTargetLatLng) {
  const isSameToilet = selectedToiletId === toilet.id;

  // まずは選択状態を更新
  selectToilet(toilet);

  // 地図を中心へ
  if (panTargetLatLng) {
    map.panTo(panTargetLatLng);
  }

  // 同じトイレを「もう一度」選択したら詳細（モーダル）を開く
  if (isSameToilet) {
    openToiletModal(toilet);
  }
}

function openToiletModal(toilet) {
  const modal = document.getElementById("toilet-modal");
  const modalBody = document.getElementById("toilet-modal-body");
  if (!modal || !modalBody) {
    // まだモーダルを作っていない場合に備えて落ちないように
    return;
  }

  const stationName = toilet.station?.name || "";
  const operatorName = toilet.station?.operator_name || "";
  const header = `${operatorName}${stationName ? " / " + stationName : ""}`;

  modalBody.innerHTML = `
    <div class="modal__sub">${escapeHtml(header)}</div>
    <div class="modal__title">${escapeHtml(toilet.name)}</div>
  `;

  modal.classList.add("is-open");
}

function closeToiletModal() {
  const modal = document.getElementById("toilet-modal");
  if (!modal) return;
  modal.classList.remove("is-open");
}

document.addEventListener("turbo:load", setupGeolocationButton);
