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


async function setupGeolocationButton() {
  const button = document.getElementById("get-location");
  const result = document.getElementById("location-result");
  const mapElement = document.getElementById("map");

  if (!button || !result || !mapElement) return;

  // ✅ Turbo再訪で多重登録されないように
  if (button.dataset.geolocationBound === "true") return;
  button.dataset.geolocationBound = "true";

  const apiKey = mapElement.dataset.mapApiKeyValue;

  async function fetchToilets() {
    const res = await fetch("/toilets.json", { credentials: "same-origin" });
    if (!res.ok) throw new Error(`Failed to fetch toilets: ${res.status}`);
    return await res.json();
  }

  let toilets = [];
  try {
    toilets = await fetchToilets();
  } catch (e) {
    toilets = [];
    clearToiletList();
    showErrorStatus("データの読み込みに失敗しました。ページを再読み込みしてください。");
  }

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

  if (document.documentElement.dataset.toiletModalEscBound !== "true") {
    document.documentElement.dataset.toiletModalEscBound = "true";
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") closeToiletModal();
    });
  }

  function startGeolocation() {
    result.textContent = "";
    hideStatus();

    if (!("geolocation" in navigator)) {
      showErrorStatus("このブラウザでは位置情報（Geolocation）が利用できません。");
      return;
    }

    showLoadingStatus("現在地を取得しています...");

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        const accuracy = position.coords.accuracy;

        result.textContent =
          `lat=${lat.toFixed(6)}, lng=${lng.toFixed(6)}（精度: 約${Math.round(accuracy)}m）`;

        
        loadGoogleMap(apiKey, lat, lng, toilets);
      },
      (error) => {
        hideStatus();
        clearToiletList();
        showErrorStatus(errorMessageFromGeolocationError(error));
      },
      {
        enableHighAccuracy: true,
        timeout: 8000,
        maximumAge: 0,
      }
    );
  }

  button.addEventListener("click", () => {
    startGeolocation();
  });

  startGeolocation();
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

  script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=__initGoogleMap&loading=async`;

  script.async = true;
  document.head.appendChild(script);
}

function initMap(lat, lng, toilets) {
  map = new google.maps.Map(document.getElementById("map"), {
    center: { lat, lng },
    zoom: 12,
  });

  const currentMarker = new google.maps.Marker({
    position: { lat, lng },
    map: map,
    title: "現在地",
    icon: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png",
  });

  currentMarker.addListener("click", () => {
    map.panTo(currentMarker.getPosition());
  });

  renderToiletMarkers(toilets);
  renderToiletList(toilets);

  if (!Array.isArray(toilets) || toilets.length === 0) {
    showEmptyStatus("現在地周辺に登録されているトイレが見つかりませんでした。");
  } else {
    hideStatus();
  }
}

function renderToiletMarkers(toilets) {
  toiletMarkersById = {};

  if (!Array.isArray(toilets)) {
    console.warn("[ToiletNavi] toilets is not array:", toilets);
    toilets = [];
  }

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
    });
  });
}

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
        <div>
          <div class="toilet-card__name">${escapeHtml(toilet.name)}</div>
          <div class="toilet-card__icons">${buildFacilityIconsHtml(toilet)}</div>
        </div>

        <button type="button" class="toilet-card__detail" aria-label="詳細を開く">
          ›
        </button>
      </div>
   `;

    item.addEventListener("click", () => {
      handleToiletSelect(toilet, { lat: Number(toilet.latitude), lng: Number(toilet.longitude) });
    });

    const detailBtn = item.querySelector(".toilet-card__detail");
    if (detailBtn) {
      detailBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        selectToilet(toilet);
        map.panTo({ lat: Number(toilet.latitude), lng: Number(toilet.longitude) });
        openToiletModal(toilet);
      });
    }

    list.appendChild(item);
  });

  applySelectedStyle();
}

function selectToilet(toilet) {
  selectedToiletId = Number(toilet.id);
  applySelectedStyle();
  highlightSelectedMarker(selectedToiletId);
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

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (s) => {
    const map = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" };
    return map[s];
  });
}

function markOrUnknown(value) {
  if (value === true) return "〇";
  if (value === false) return "×";
  return "—";
}

function getSearchStatusEl() {
  return document.getElementById("search-status");
}

function showLoadingStatus(message = "検索中...") {
  const el = getSearchStatusEl();
  if (!el) return;

  el.className = "search-status is-show is-loading";
  el.innerHTML = `
    <span class="search-status__spinner" aria-hidden="true"></span>
    <span>${escapeHtml(message)}</span>
  `;
}

function showEmptyStatus(message = "近くにトイレが見つかりませんでした。") {
  const el = getSearchStatusEl();
  if (!el) return;

  el.className = "search-status is-show is-empty";
  el.textContent = message;
}

function showErrorStatus(message = "エラーが発生しました。もう一度お試しください。") {
  const el = getSearchStatusEl();
  if (!el) return;

  el.className = "search-status is-show is-error";
  el.textContent = message;
}

function hideStatus() {
  const el = getSearchStatusEl();
  if (!el) return;

  el.className = "search-status";
  el.textContent = "";
}

function clearToiletList() {
  const list = document.getElementById("toilet-list");
  if (!list) return;
  list.innerHTML = "";
}

function handleToiletSelect(toilet, panTargetLatLng) {
  selectToilet(toilet);

  if (panTargetLatLng) {
    map.panTo(panTargetLatLng);
  }
}

function closeToiletModal() {
  const modal = document.getElementById("toilet-modal");
  if (!modal) return;

  modal.classList.remove("is-open");
  modal.setAttribute("aria-hidden", "true");

  document.body.classList.remove("is-modal-open");
}

function setupToiletModalCloseEvents() {
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

  if (document.documentElement.dataset.toiletModalEscBound !== "true") {
    document.documentElement.dataset.toiletModalEscBound = "true";
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") closeToiletModal();
    });
  }
}

function openToiletModal(toilet) {
  const modal = document.getElementById("toilet-modal");
  const modalBody = document.getElementById("toilet-modal-body");
  if (!modal || !modalBody) return;

  const stationName = toilet.station?.name || "";
  const operatorName = toilet.station?.operator_name || "";
  const header = `${operatorName}${stationName ? " / " + stationName : ""}`;

  const styleText =
    toilet.style_type === "japanese" ? "和式" :
    toilet.style_type === "western" ? "洋式" :
    toilet.style_type === "both" ? "併設" :
    "不明";

  const loggedIn = isLoggedIn();
  const favorited = toilet.favorited === true;

  const wheelchair = toilet.is_wheelchair_accessible ? "〇" : "×";
  const ostomate   = toilet.is_ostomate_accessible ? "〇" : "×";
  const baby       = toilet.is_baby_friendly ? "〇" : "×";

  const lat = Number(toilet.latitude);
  const lng = Number(toilet.longitude);
  const canNavigate = Number.isFinite(lat) && Number.isFinite(lng);
  const navUrl = canNavigate
    ? `https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&travelmode=walking`
    : "";

  modalBody.innerHTML = `
    <div class="toilet-modal__header">
      <div>
        <div class="toilet-modal__sub">${escapeHtml(header)}</div>
        <div class="toilet-modal__titleRow">
          <div class="toilet-modal__title">${escapeHtml(toilet.name || "名称未登録")}</div>

          ${
            loggedIn
              ? `<button
                  type="button"
                  class="toilet-modal__fav"
                  data-favorite-button="true"
                  data-toilet-id="${toilet.id}"
                  aria-label="お気に入り"
                  aria-pressed="${favorited ? "true" : "false"}"
                >${favorited ? "★" : "☆"}</button>`
              : `<button type="button" class="toilet-modal__favHint" aria-label="ログイン案内">☆</button>`
          }

        </div>
      </div>
    </div>

    <div class="toilet-modal__photo">
      <div class="toilet-modal__photoPlaceholder">写真表示エリア（MVPは後でOK）</div>
    </div>

    <!--  issue仕様：設備情報 -->
    <div class="toilet-modal__section">
      <div class="toilet-modal__sectionTitle">設備情報</div>

      <div class="toilet-modal__grid">
        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">便器タイプ</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue toilet-modal__cellValue--text">
            ${escapeHtml(styleText)}
          </div>
        </div>

        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">ウォシュレット</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.has_washlet)}</div>
        </div>

        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">おむつ交換設備</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.is_baby_friendly)}</div>
        </div>

        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">多目的トイレ</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.is_multipurpose)}</div>
        </div>

        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">車いす対応</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.is_wheelchair_accessible)}</div>
        </div>

        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">オストメイト対応</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.is_ostomate_accessible)}</div>
        </div>
        <div class="toilet-modal__cell">
          <div class="toilet-modal__cellLabel">男女別</div>
          <div class="toilet-modal__cellDivider"></div>
          <div class="toilet-modal__cellValue">${markOrUnknown(toilet.is_gender_separated)}</div>
        </div>
      </div>
    </div>

    <div class="toilet-modal__section">
      <div class="toilet-modal__sectionTitle">場所メモ</div>
      <div class="toilet-modal__note">${escapeHtml(toilet.location_note || "（未登録）")}</div>
    </div>

    <div class="toilet-modal__section">
      <div class="toilet-modal__sectionTitle">評価（将来）</div>
      <div class="toilet-modal__placeholder">評価エリア（将来）</div>
    </div>

    <div class="toilet-modal__section">
      <div class="toilet-modal__sectionTitle">コメント（将来）</div>
      <div class="toilet-modal__placeholder">コメント表示（将来）</div>
    </div>

    <button
      type="button"
      class="btn btn--primary toilet-modal__route"
      ${canNavigate ? "" : "disabled"}
      data-nav-url="${escapeHtml(navUrl)}"
    >
      Google Mapで案内を開始する
    </button>
  `;
  bindToiletModalEvents(toilet);

  modal.classList.add("is-open");
  modal.setAttribute("aria-hidden", "false");

  document.body.classList.add("is-modal-open");
}

function setupToiletModalDelegationOnce() {
  if (document.documentElement.dataset.toiletModalDelegationBound === "true") return;
  document.documentElement.dataset.toiletModalDelegationBound = "true";

  document.addEventListener("click", async (e) => {
    const favBtn = e.target.closest('[data-favorite-button="true"]');
    if (!favBtn) return;

    const toiletId = favBtn.dataset.toiletId;
    if (!toiletId) return;

    // 連打対策（toggleFavorite側でもbusyを見ているが、委譲側でも早めに抑止）
    if (favBtn.dataset.busy === "true") return;

    try {
      const res = await fetch(`/toilets/${toiletId}.json`, {
        credentials: "same-origin",
        headers: { "Accept": "application/json" }
      });

      if (!res.ok) {
        alert("トイレ情報の取得に失敗しました");
        return;
      }

      const toilet = await res.json();
      await toggleFavorite(favBtn, toilet);
    } catch (err) {
      console.error(err);
      alert("通信エラーが発生しました");
    }
  });
}

async function openToiletModalById(toiletId) {
  const res = await fetch(`/toilets/${toiletId}.json`, {
    credentials: "same-origin",
    headers: { "Accept": "application/json" }
  });

  if (!res.ok) {
    alert("トイレ情報の取得に失敗しました");
    return;
  }

  const toilet = await res.json();
  openToiletModal(toilet);
}

document.addEventListener("turbo:load", () => {
  setupGeolocationButton();
  setupToiletModalCloseEvents();
  setupToiletModalDelegationOnce(); // ✅ 追加
  setupFavoritesIndexBindings();
});

function setupFavoritesIndexBindings() {
  // favoritesページにいないなら何もしない（他ページに影響させない）
  const root = document.querySelector('[data-favorites-root="true"]');
  if (!root) return;

  // Turbo再訪でも多重登録しない
  if (document.documentElement.dataset.favoritesIndexBound === "true") return;
  document.documentElement.dataset.favoritesIndexBound = "true";

  document.addEventListener("click", async (e) => {
    // 1) トイレ名クリック → モーダルを開く
    const openBtn = e.target.closest('[data-open-toilet-modal="true"]');
    if (openBtn) {
      const toiletId = openBtn.dataset.toiletId;
      if (!toiletId) return;
      e.preventDefault();
      await openToiletModalById(toiletId);
      return;
    }

    // 2) 解除クリック → DELETE → 行削除 → 同期イベント
    const unfavBtn = e.target.closest('[data-favorites-unfavorite="true"]');
    if (unfavBtn) {
      const toiletId = unfavBtn.dataset.toiletId;
      if (!toiletId) return;

      unfavBtn.disabled = true;

      try {
        const res = await fetch(`/toilets/${toiletId}/favorite`, {
          method: "DELETE",
          credentials: "same-origin",
          headers: {
            "Accept": "application/json",
            "X-CSRF-Token": csrfToken() || "",
          },
        });

        if (res.status === 401) {
          alert("ログインしてください");
          window.location.href = "/session/new";
          return;
        }

        if (!res.ok) {
          alert("お気に入りの更新に失敗しました");
          unfavBtn.disabled = false;
          return;
        }

        const data = await res.json(); // { favorited: false } 想定

        const nearestItem = unfavBtn.closest('[data-favorites-item="true"]');
        if (nearestItem) {
          nearestItem.remove();
        } else {
           // 2) 保険：rootの中からID一致で探して消す（空白なし・確実）
          const selector = `[data-favorites-item="true"][data-toilet-id="${CSS.escape(String(toiletId))}"]`;
          const item = root.querySelector(selector);
          if (item) item.remove(); 
        }

        if (root.querySelectorAll('[data-favorites-item="true"]').length === 0) {
          const container = root.parentElement; // ulの親（elseブロック内の領域）を想定
          if (container) {
            container.innerHTML = `
              <p>お気に入りはまだありません。</p>
              <a class="btn btn--primary" href="/search">トイレを探す</a>
            `;
          }
        }

        // モーダルや他UIへ同期通知
        window.dispatchEvent(new CustomEvent("toilet:favorited-changed", {
          detail: { toiletId: String(toiletId), favorited: Boolean(data.favorited) }
        }));
        } catch (err) {
        console.error(err);
        alert("通信エラーが発生しました");
        unfavBtn.disabled = false;
      }
    }
  });
}

function csrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta?.content;
}

async function toggleFavorite(button, toilet) {
  const toiletId = button.dataset.toiletId;
  const pressed = button.getAttribute("aria-pressed") === "true";

  const url = `/toilets/${toiletId}/favorite`;
  const method = pressed ? "DELETE" : "POST";

  // 二重送信防止（連打対策）
  if (button.dataset.busy === "true") return;
  button.dataset.busy = "true";
  button.disabled = true;

  try {
    const res = await fetch(url, {
      method: method,
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken() || ""
      }
    });

    if (res.status === 401) {
      alert("ログインしてください");
      window.location.href = "/session/new";
      return;
    }

    if (!res.ok) {
      alert("お気に入りの更新に失敗しました");
      return;
    }

    const data = await res.json();

    button.setAttribute("aria-pressed", data.favorited ? "true" : "false");
    button.textContent = data.favorited ? "★" : "☆";
    toilet.favorited = data.favorited;

    // ✅ 同期イベント（Favorites一覧・他UIがこれを受けて更新できる）
    window.dispatchEvent(new CustomEvent("toilet:favorited-changed", {
      detail: { toiletId: String(toiletId), favorited: Boolean(data.favorited) }
    }));

    // ✅ Favoritesページを見ている時だけ：解除なら行を消す（同期漏れ防止）
    if (!data.favorited) {
      const root = document.querySelector('[data-favorites-root="true"]');
      if (root) {
        const item = root.querySelector(`[data-favorites-item="true"][data-toilet-id="${toiletId}"]`);
        if (item) item.remove();
      }
    }
  } catch (e) {
    console.error(e);
    alert("通信エラーが発生しました");
  } finally {
    button.dataset.busy = "false";
    button.disabled = false;
  }
}

function bindToiletModalEvents(toilet) {
  const modalBody = document.getElementById("toilet-modal-body");
  if (!modalBody) return;

  // ✅ favBtn は openToiletModal() 側で toggleFavorite を付けているので、ここでは触らない

  const favHintBtn = modalBody.querySelector(".toilet-modal__favHint");
  if (favHintBtn) {
    favHintBtn.onclick = () => {
      alert("お気に入り機能を使うにはログインが必要です");
    };
  }

  const routeBtn = modalBody.querySelector(".toilet-modal__route");
  if (routeBtn) {
    routeBtn.onclick = () => {
      const url = routeBtn.dataset.navUrl;
      if (!url) return;
      window.open(url, "_blank", "noopener,noreferrer");
    };
  }
}

function openRouteInGoogleMaps(toilet) {
  const lat = Number(toilet.latitude);
  const lng = Number(toilet.longitude);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return;

  const url = `https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&travelmode=walking`;
  window.open(url, "_blank", "noopener,noreferrer");
}

function isLoggedIn() {
  return document.body?.dataset?.authenticated === "true";
}
