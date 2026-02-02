document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".js-auth-coming-soon").forEach((el) => {
    el.addEventListener("click", (e) => {
      e.preventDefault();
      alert("ログイン/新規登録は本リリースで対応予定です");
    });
  });
});
