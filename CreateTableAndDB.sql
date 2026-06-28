create database online_store;
create schema online_store_schemaOne;


create table online_store_schemaOne.customers (
                           customer_id serial primary key,
                           full_name varchar(100) not null,
                           email varchar(100) unique not null,
                           balance numeric(10,2) default 0
);

create table online_store_schemaOne.products (
                          product_id serial primary key,
                          product_name varchar(100) not null,
                          price numeric(10,2) not null,
                          stock_quantity int not null
);

create table online_store_schemaOne.orders (
                        order_id serial primary key,
                        customer_id int references online_store_schemaOne.customers(customer_id),
                        order_date timestamp default current_timestamp,
                        total_amount numeric(10,2) default 0
);

create table online_store_schemaOne.order_items (
                             order_item_id serial primary key,
                             order_id int references online_store_schemaOne.orders(order_id),
                             product_id int references online_store_schemaOne.products(product_id),
                             quantity int not null,
                             price numeric(10,2) not null
);

create table online_store_schemaOne.order_log (
                           log_id serial primary key,
                           order_id int,
                           customer_id int,
                           action varchar(50),
                           log_date timestamp default current_timestamp
);