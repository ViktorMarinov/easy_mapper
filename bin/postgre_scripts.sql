create table users (
	id int primary key,
	first_name varchar(30),
	last_name varchar(30),
	age int
);

create table address (
	id int primary key,
	city varchar(30),
	street varchar(30)
);

create table employee (
	id int primary key,
	name varchar(30),
	address_id int references address(id)	
);

create table phone_book (
	id int primary key,
	country varchar(30)
);

create table phone_entry (
	id int primary key,
	name varchar(30),
	phone varchar(15),
	phone_book_id int references phone_book(id)
);

