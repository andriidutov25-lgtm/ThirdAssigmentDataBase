
CREATE OR REPLACE FUNCTION online_store_schemaOne.calculate_order_total(p_order_id INT)
    RETURNS NUMERIC(10,2) AS $$
DECLARE
    total_sum NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(quantity * price), 0)
    INTO total_sum
    FROM online_store_schemaOne.order_items
    WHERE order_id = p_order_id;

    RETURN total_sum;
END;
$$ LANGUAGE plpgsql;

SELECT online_store_schemaone.calculate_order_total(1);




CREATE OR REPLACE PROCEDURE online_store_schemaone.create_order(p_customer_id INT)
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM online_store_schemaone.customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer with id% is not exist. Order didn`t create', p_customer_id;
    END IF;

    INSERT INTO online_store_schemaone.orders (customer_id, order_date, total_amount)
    VALUES (p_customer_id, CURRENT_TIMESTAMP, 0);
END;
$$;

CALL online_store_schemaone.create_order(3);


CREATE OR REPLACE PROCEDURE online_store_schemaone.add_product_to_order(
    p_order_id INT,
    p_product_id INT,
    p_quantity INT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_product_price NUMERIC(10,2);
    v_stock_quantity INT;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'quantity have to be more then 0.';
    END IF;

    SELECT price, stock_quantity
    INTO v_product_price, v_stock_quantity
    FROM online_store_schemaone.products
    WHERE product_id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with ID % is not exist.', p_product_id;
    END IF;

    IF v_stock_quantity < p_quantity THEN
        RAISE EXCEPTION 'Not enough product in warehouse. Available: %, Request: %', v_stock_quantity, p_quantity;
    END IF;

    INSERT INTO online_store_schemaone.order_items (order_id, product_id, quantity, price)
    VALUES (p_order_id, p_product_id, p_quantity, v_product_price);

    UPDATE online_store_schemaone.products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;

END;
$$;


CALL online_store_schemaone.add_product_to_order(8,2,3);


SELECT *
FROM online_store_schemaone.orders;






CREATE OR REPLACE FUNCTION online_store_schemaone.trg_func_update_order_total()
    RETURNS TRIGGER AS $$
DECLARE
    v_order_id INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_order_id = OLD.order_id;
    ELSE
        v_order_id = NEW.order_id;
    END IF;

    UPDATE online_store_schemaone.orders
    SET total_amount = online_store_schemaone.calculate_order_total(v_order_id)
    WHERE order_id = v_order_id;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_order_total_trigger
    AFTER INSERT OR UPDATE OR DELETE
    ON online_store_schemaone.order_items
    FOR EACH ROW
EXECUTE FUNCTION online_store_schemaone.trg_func_update_order_total();




CREATE OR REPLACE FUNCTION online_store_schemaone.trg_func_log_new_order()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO online_store_schemaone.order_log (order_id, customer_id, action)
    VALUES (NEW.order_id, NEW.customer_id, 'NEW_ORDER_CREATED');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_new_order_trigger
    AFTER INSERT
    ON online_store_schemaone.orders
    FOR EACH ROW
EXECUTE FUNCTION online_store_schemaone.trg_func_log_new_order();





CALL online_store_schemaone.create_order(1);

SELECT * FROM online_store_schemaone.orders
ORDER BY order_id DESC LIMIT 1;

SELECT * FROM online_store_schemaone.order_log
ORDER BY log_id DESC LIMIT 1;

SELECT product_id, product_name, stock_quantity
FROM online_store_schemaone.products
WHERE product_id = 1;

CALL online_store_schemaone.add_product_to_order(4, 1, 2);

SELECT order_id, total_amount
FROM online_store_schemaone.orders
WHERE order_id = 4;

SELECT product_id, product_name, stock_quantity
FROM online_store_schemaone.products
WHERE product_id = 1;


CALL online_store_schemaone.create_order(1);
SELECT * FROM online_store_schemaone.order_log;

