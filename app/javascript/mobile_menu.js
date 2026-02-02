function setupMobileMenu() {
  const btn = document.querySelector("[data-mobile-menu-button]");
  const menu = document.querySelector("[data-mobile-menu]");
  const icon = document.querySelector("[data-mobile-menu-icon]");
  const backdrop = document.querySelector("[data-mobile-menu-backdrop]");

  if (!btn || !menu || !icon || !backdrop) return;

  // Turbo再訪で多重登録防止
  if (btn.dataset.bound === "true") return;
  btn.dataset.bound = "true";

  function openMenu() {
    menu.hidden = false;
    backdrop.hidden = false;
    btn.setAttribute("aria-expanded", "true");
    icon.textContent = "×";
  }

  function closeMenu() {
    menu.hidden = true;
    backdrop.hidden = true;
    btn.setAttribute("aria-expanded", "false");
    icon.textContent = "☰";
  }

  function toggleMenu() {
    const isOpen = btn.getAttribute("aria-expanded") === "true";
    if (isOpen) closeMenu();
    else openMenu();
  }

  btn.addEventListener("click", toggleMenu);

  backdrop.addEventListener("click", closeMenu);

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeMenu();
  });

  menu.addEventListener("click", (e) => {
    const target = e.target;
    if (target && target.tagName === "A") closeMenu();
  });
}

document.addEventListener("turbo:load", setupMobileMenu);
