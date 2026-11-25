# Long Tộc: Cổng Cassell — iOS WebView IPA (Cho ESign)

Project iOS gọn nhẹ bọc trang **https://dragonrajac.vusagaming.uk/play/** vào `WKWebView` toàn màn hình, tự động build ra file `.ipa` chưa ký (unsigned) bằng **GitHub Actions (macOS)** để bạn tải về và ký cài đặt qua **ESign**.

## Tính năng đã tối ưu cho việc chơi game
- **Toàn màn hình (Edge-to-edge):** Ẩn hoàn toàn thanh địa chỉ Safari, tự động xử lý tai thỏ / Dynamic Island theo CSS của game và tự làm mờ thanh Home ở đáy màn hình.
- **Không bị giật/lệch khung:** Tắt hiệu ứng kéo nảy (rubber-band bounce), tắt vuốt cạnh quay lại, tắt zoom nhầm khi thao tác nhanh.
- **Giữ màn hình luôn sáng** khi đang mở game (tránh khóa máy khi treo ải/chiến đấu) và **giữ đăng nhập** (`localStorage` + cookies).
- **Mở link ngoài / `/tool/` tiện lợi:** Tự mở bằng trình duyệt tích hợp trong app (có nút *Xong* để quay lại game ngay).
- **Menu nhanh ẩn:** Chạm **3 ngón tay cùng lúc** vào màn hình bất cứ lúc nào để mở menu: *Tải lại trang*, *Về trang chủ game*, *Mở Công cụ (/tool/)*, hoặc *Xóa cache web*.

---

## Cách build ra file `.ipa` (Không cần máy Mac)

1. Tạo một repository mới trên **GitHub** (có thể để Private hoặc Public).
2. Tải toàn bộ thư mục này lên repository đó (nhớ giữ nguyên thư mục `.github/workflows/build-ipa.yml` và nhánh `main`).
   - Nếu dùng Git trên Windows:
     ```bash
     git init
     git branch -M main
     git add .
     git commit -m "Initial iOS wrapper"
     git remote add origin https://github.com/<TEN_USER>/<TEN_REPO>.git
     git push -u origin main
     ```
3. Mở repo trên GitHub -> vào tab **Actions** -> chọn workflow **Build Unsigned IPA** (nó sẽ tự chạy khi bạn push lên `main`, hoặc bạn bấm nút **Run workflow**).
4. Chờ khoảng 2–4 phút cho build xanh (`✓`), bấm vào lần chạy đó -> kéo xuống mục **Artifacts** -> tải **`DragonRaja-Cassell-Web-IPA`** (bên trong là file `DragonRaja-Cassell-Web-unsigned.ipa`).

---

## Cách cài bằng ESign trên iPhone/iPad

1. Giải nén file `.zip` vừa tải từ GitHub Actions (nếu Safari tải về dưới dạng `.zip`) để lấy file `DragonRaja-Cassell-Web-unsigned.ipa`.
2. Mở **ESign** -> chọn **Nhập (Import)** file `.ipa` đó vào ESign.
3. Chọn file vừa nhập -> bấm **Chữ ký (Signature)** -> chọn chứng chỉ + mobileprovision bạn đang dùng trong ESign -> bấm **Chữ ký (Signature)** để ký -> chọn **Cài đặt (Install)**.
