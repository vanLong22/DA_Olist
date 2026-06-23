use DB_ECommerce 
go

-- Xóa bảng nếu đã tồn tại
IF OBJECT_ID('dbo.olist_seller', 'U') IS NOT NULL
    DROP TABLE dbo.olist_seller;
GO

WITH order_seller_count AS (
    SELECT 
        order_id,
        COUNT(DISTINCT seller_id) AS total_sellers_in_order
    FROM olist_order_items_dataset
    GROUP BY order_id
),

clean_seller_reviews AS (
    SELECT 
        oi.seller_id,
        r.review_score
    FROM olist_order_items_dataset oi
    INNER JOIN olist_order_reviews_dataset r ON oi.order_id = r.order_id
    INNER JOIN order_seller_count osc ON oi.order_id = osc.order_id
    WHERE osc.total_sellers_in_order = 1 
       OR (osc.total_sellers_in_order > 1 AND r.review_score >= 4)
),

customer_orders AS (
    SELECT 
        oi.seller_id,
        o.customer_id,
        COUNT(DISTINCT oi.order_id) AS customer_order_count
    FROM olist_order_items_dataset oi
    INNER JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id, o.customer_id
),
repeat_customer_rate AS (
    SELECT 
        seller_id,
        SUM(CASE WHEN customer_order_count >= 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) * 100 AS repeat_customer_rate
    FROM customer_orders
    GROUP BY seller_id
),


seller_raw_metrics AS (
    SELECT 
        oi.seller_id,
        SUM(oi.price + oi.freight_value) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS order_count,
        AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days,
        COUNT(DISTINCT oi.product_id) AS num_categories,
        AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1.0 ELSE 0.0 END) * 100 AS late_shipping_rate,
        DATEDIFF(day, MAX(o.order_purchase_timestamp), (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)) AS recency_days,
        SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) * 1.0 / COUNT(DISTINCT oi.order_id) * 100 AS cancellation_rate
    FROM olist_order_items_dataset oi
    INNER JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    LEFT JOIN olist_products_dataset p ON oi.product_id = p.product_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_status = 'delivered'
    GROUP BY oi.seller_id
),


seller_metrics_with_review AS (
    SELECT 
        rm.*,
        avg_clean_review AS avg_review_score
    FROM seller_raw_metrics rm
    LEFT JOIN (
        SELECT seller_id, AVG(CAST(review_score AS FLOAT)) AS avg_clean_review
        FROM clean_seller_reviews
        GROUP BY seller_id
    ) cr ON rm.seller_id = cr.seller_id
)



-- Lưu kết quả vào bảng mới, đồng thời lấy thêm seller_city và seller_state từ bảng sellers
SELECT 
    rm.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(rm.total_revenue, 2) AS total_revenue,
    rm.order_count,
    rm.num_categories,
    avg_delivery_days,
    ROUND(rm.avg_review_score, 2) AS avg_review_score,
    ROUND(rm.late_shipping_rate, 2) AS late_shipping_percentage,
    ROUND(rm.cancellation_rate, 2) AS cancellation_percentage,
    ROUND(rc.repeat_customer_rate, 2) AS repeat_customer_percentage,
    rm.recency_days
    /*CASE 
        WHEN rm.avg_review_score < 3.0 OR rm.late_shipping_rate > 20 OR rm.recency_days > 90 THEN 'At-Risk'
        WHEN rm.total_revenue >= 50000 AND rm.avg_review_score >= 4.2 AND rm.late_shipping_rate <= 10 THEN 'Gold'
        WHEN rm.total_revenue BETWEEN 10000 AND 49999 AND rm.avg_review_score >= 4.0 THEN 'Silver'
        ELSE 'Bronze'
    END AS seller_tier
    */
INTO dbo.olist_seller
FROM seller_metrics_with_review rm
INNER JOIN olist_sellers_dataset s ON rm.seller_id = s.seller_id
LEFT JOIN repeat_customer_rate rc ON rm.seller_id = rc.seller_id
ORDER BY rm.total_revenue DESC;



------------------------------------
-------------------------------------
-- Xóa bảng nếu đã tồn tại
IF OBJECT_ID('dbo.olist_seller_timestamp', 'U') IS NOT NULL
    DROP TABLE dbo.olist_seller_timestamp;
GO

-- Tạo bảng mới lưu dữ liệu theo thời gian
SELECT 
    oi.seller_id,
    o.order_id,
    o.order_purchase_timestamp,
    SUM(oi.price + oi.freight_value) AS order_revenue 
INTO dbo.olist_seller_timestamp
FROM olist_order_items_dataset oi
INNER JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, o.order_id, o.order_purchase_timestamp;
GO



SELECT COUNT(*) AS num_customers_with_multiple_orders
FROM (
    SELECT customer_id
    FROM olist_orders_dataset
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS subquery;
