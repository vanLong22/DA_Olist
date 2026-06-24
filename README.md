# Phân tích Mức độ Tập trung Doanh thu và Năng lực Tăng trưởng của Nhà bán hàng trên Sàn Olist

## 1. Tổng quan Dự án
Dự án tập trung vào việc xử lý và phân tích dữ liệu vận hành của **2,970 nhà bán hàng** trên **Olist** – nền tảng thương mại điện tử hàng đầu tại Brazil, đóng vai trò cầu nối chiến lược giữa các doanh nghiệp nhỏ và các marketplace lớn. Olist giúp người bán mở rộng kênh phân phối quốc gia dựa trên việc tích hợp sâu dữ liệu từ hành vi mua sắm, tốc độ giao hàng đến mức độ hài lòng sau bán.

Tuy nhiên, sàn thương mại này đang đối mặt với một rủi ro chiến lược lớn: **doanh thu hiện tại tập trung chủ yếu vào một nhóm nhỏ các nhà bán hàng đứng đầu (Top Sellers)**. Nếu nhóm này rời bỏ nền tảng, doanh thu của Olist sẽ sụt giảm nghiêm trọng. Do đó, dự án này được thực hiện nhằm tìm ra giải pháp đa dạng hóa nguồn thu và phát triển năng lực cạnh tranh bền vững cho các nhà bán hàng vừa và nhỏ (Other Sellers).

## 2. Bài toán Kinh doanh (Business Problems)
Nghiên cứu tiến hành bóc tách sâu các chỉ số vận hành và phân phối địa lý để trả lời ba câu hỏi kinh doanh cốt lõi:
*   Tại sao chỉ một nhóm nhỏ nhà bán hàng lại tạo ra phần lớn doanh thu của toàn sàn Olist?
*   Nguyên nhân gốc rễ nào khiến cho phần lớn các nhà bán hàng còn lại không thể tăng trưởng?
*   Tại sao dòng tiền doanh thu lại tập trung cục bộ chủ yếu ở một bang duy nhất là São Paulo (SP)?

## 3. Dữ liệu & Quy trình xử lý
*   **Dữ liệu đầu vào:** Tập dữ liệu gồm 2,970 bản ghi tương ứng với 2,970 nhà bán hàng hoạt động trên 561 thành phố và 22 bang tại Brazil. Dữ liệu được tổng hợp trực tiếp ở cấp độ nhà bán hàng (Seller-level).
*   **Nguồn:** [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
*   **Quy trình Xử lý dữ liệu (`data_cleaning.ipynb`):**
    *   *Chuẩn hóa định dạng:* Định dạng lại tên thành phố (chuyển chữ thường, viết hoa chữ cái đầu và xử lý từ nối đặc thù của tiếng Brazil); đồng bộ hóa chữ in hoa cho tên bang và gộp các biến thể viết sai chính tả do lỗi nhập liệu của các thành phố lớn (như Sao Paulo, Santo Andre...).
    *   *Xử lý giá trị thiếu (Missing Values):* Phát hiện cột điểm đánh giá (`avg_review_score`) bị thiếu có điều kiện (MAR) tập trung hoàn toàn ở nhóm seller quy mô nhỏ chỉ có 1 đơn hàng. Xử lý bằng cách tạo cột cờ đánh dấu `has_review` để giữ nguyên bản ghi và điền giá trị `-1` để phục vụ phân tách logic.
    *   *Kiểm tra logic nghiệp vụ:* Rà soát các ràng buộc nghiêm ngặt như điểm đánh giá âm, tỷ lệ giao trễ ngoài khoảng 0-100%, thời gian giao hàng âm... Kết quả ghi nhận hệ thống dữ liệu không vi phạm logic.
    *   *Xử lý giá trị ngoại lai (Outlier):* Áp dụng phương pháp IQR trên 6 cột số chính. Xác định phân phối doanh thu và đơn hàng lệch phải mạnh (xác minh hiện tượng tập trung doanh thu). Toàn bộ outlier được giữ lại để phản ánh đúng thực tế và được gắn cờ (`_outlier_flag`) để theo dõi.

## 4. Khám phá Chính & Kiểm định Thống kê (Key Insights)
### Hiện tượng tập trung doanh thu & Năng lực danh mục
*   **Vấn đề 1 (Rủi ro tập trung):** Nhóm **10% Top Seller** đóng góp tới **66.29% tổng doanh thu** toàn sàn, trong khi nhóm 20% seller đáy chiếm chưa đầy 1%. 
    *   *Nguyên nhân:* Top Seller có lượng đơn vượt trội (trung bình 203.20 đơn so với 14.15 đơn) nhờ sở hữu danh mục sản phẩm đa dạng gấp 7.6 lần (trung bình **52.06 danh mục** so với **6.85 danh mục**). Năng lực vận hành (tốc độ giao, tỷ lệ trễ) không phải là yếu tố tạo ra sự khác biệt doanh thu giữa 2 nhóm.
*   **Vấn đề 2 (Điểm nghẽn tăng trưởng):** 90% nhà bán hàng còn lại không tăng trưởng được do **hoạt động không thường xuyên** (số ngày từ đơn hàng gần nhất `recency_days` trung bình lên tới **187.90 ngày** so với 91.58 ngày của Top Seller). Sự thiếu liên tục này triệt tiêu động lực và cơ hội mở rộng danh mục hàng hóa của họ.
*   **Vấn đề 3 (Yếu tố địa lý):** Bang **São Paulo (SP)** chiếm tới **66.94% tổng doanh thu** của sàn vì đây là nơi tập trung của 181 Top Seller (bang đứng thứ hai chỉ có 31). Nhà bán hàng tại SP hoạt động thường xuyên và đa dạng danh mục hơn nhờ có **hạ tầng vận hành vượt trội** với thời gian giao hàng ngắn hơn (11.34 ngày so với trung bình 15.01 ngày ở bang khác) và tỷ lệ trễ thấp hơn rõ rệt (9.43% so với 10.23%).

### Các kiểm định thống kê sử dụng (`EDA.ipynb`)
*   **Kiểm định Shapiro-Wilk & Mann-Whitney U một phía:** Xác nhận số đơn hàng của nhóm Top Seller và doanh thu của các seller tại bang São Paulo cao hơn nhóm còn lại một cách có ý nghĩa thống kê (p-value ≈ 0).
*   **Kiểm định tương quan hạng Spearman:** Chứng minh mối liên hệ thuận chiều rất mạnh (Hệ số tương quan = **0.80**, p-value ≈ 0) giữa số lượng danh mục kinh doanh và tổng doanh thu tích lũy.

## 5. Khuyến nghị Hành động & Tác động Kỳ vọng (Actionable Recommendations)
*   **Khuyến nghị 1 (Đa dạng hóa danh mục):** Đội ngũ quản lý đối tác chủ động đề xuất các danh mục sản phẩm có nhu cầu cao trên thị trường cho nhóm seller vừa và nhỏ, hướng dẫn họ từng bước mở rộng quy mô sản phẩm.
    *   *KPI & Tác động kỳ vọng:* Thúc đẩy tăng trưởng từ **15% đến 25%** số danh mục sản phẩm trung bình, kéo theo lượng đơn hàng tăng từ 10% đến 20% cho nhóm seller nhỏ trong 6 tháng.
*   **Khuyến nghị 2 (Kích hoạt tài khoản định kỳ):** Xây dựng hệ thống tự động gửi cảnh báo khi tài khoản không phát sinh đơn và gửi báo cáo phân tích thị trường hàng tuần để thúc đẩy họ duy trì tương tác định kỳ.
    *   *KPI & Tác động kỳ vọng:* Tối ưu hóa số ngày hoạt động trung bình (`recency_days`), giảm từ **10% đến 15%** tỷ lệ nhà bán hàng ngừng hoạt động (churn rate) sau 3 tháng.
*   **Khuyến nghị 3 (Nhân rộng mô hình logistics):** Chuyển giao và nhân rộng mô hình điều phối vận hành tối ưu từ bang São Paulo sang các bang vệ tinh, ưu tiên cải thiện thời gian giao hàng cho các nhóm người bán có tiềm năng.
    *   *KPI & Tác động kỳ vọng:* Thu hẹp từ **20% đến 30%** khoảng cách về thời gian giao hàng và tỷ lệ giao trễ giữa São Paulo với các bang còn lại, phân bổ lại bản đồ doanh thu bền vững hơn.

## 6. Dashboard
*    **[Xem Dashboard trực tuyến](https://app.powerbi.com/links/5UAXI156me?ctid=e94fbe89-41e0-4857-b292-cfd8b9e613f0&pbi_source=linkShare&bookmarkGuid=fe5b6cb0-6ae0-4103-a384-42832de47772)** 

## 7. Cấu trúc Thư mục Dự án (Project Structure)
```text

├── data/
│   ├── raw/
│   │   └── olist_seller.csv            # Dữ liệu gốc chưa làm sạch
│   │   └── KPI_Tracking_Mock.csv       # Dữ liệu giả lập để theo dõi KPI
│   ├── processed/
│   │   ├── olist_seller_cleaned.csv    # Dữ liệu sau xử lý chứa đầy đủ flag
│   │   └── olist_seller_for_eda.csv    # Dữ liệu loại bỏ bản ghi có gắn flag, để phục vụ EDA
│   ├── archive/
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_geolocation_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_order_payments_dataset.csv
│   │   ├── olist_order_reviews_dataset.csv
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   ├── olist_sellers_dataset.csv
│   │   └── product_category_name_translation.csv
├── notebooks/
│   ├── data_cleaning.ipynb          # Quy trình chuẩn hóa, xử lý dữ liệu thiếu và outlier
│   └── EDA.ipynb                    # Phân tích khám phá, tìm nguyên nhân, kiểm định thống kê 
├── BaoCao.pbix            
└── BaoCao.docx
└── Join.sql                         # Quy trình join các bảng để lấy dữ liệu cần thiết cho bài toán đang phân tích
