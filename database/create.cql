/********************************************************************
CREATE TABLES
********************************************************************/

-- `User` table captures the name and e-mail address of
-- system users.
drop table if exists user;
create table user (
    id uuid,
    email text,
    name text,
    create_date timestamp,
    PRIMARY KEY(id)
);

-- `Login` table captures the user name and password 
-- (SHA256 of password) of all system users. Convention is
-- to store passwords in lower case.
drop table if exists login;
create table login (
    id uuid,
    email text,
    password text,
    name text,
    PRIMARY KEY((email), password)
);

-- `city` table captures the names of departure and 
-- destination locations.
drop table if exists city;
create table city(
    name text,
    PRIMARY KEY(name)
);

-- `ticket` table hosts tickets for passenger -- about to fly, 
-- in-flight and after flight.
drop table if exists ticket;
create table ticket(
    id uuid,
    passenger_id uuid,
    passenger_name text,
    flight_id text,
    origin_city text,
    destination_city text,
    departure_time text,
    departure_gate text,
    checkin_time text,
    carousel text,
    bags_checked int,
    miles_earned int,
    PRIMARY KEY(id)
);

-- Supports ticket query by passenger
CREATE CUSTOM INDEX ON ticket (
    passenger_id
) USING 'StorageAttachedIndex';

-- Supports ticket query by flight
CREATE CUSTOM INDEX ON ticket (
    flight_id
) USING 'StorageAttachedIndex';

drop table if exists baggage;
create table baggage(
    id uuid,
    ticket_id uuid,
    passenger_id uuid,
    passenger_name text,
    image text,
    flight_id text, 
    origin_city text, 
    destination_city text,
    carousel text,
    PRIMARY KEY((flight_id), id)
);

-- Supports baggage query by passenger
CREATE CUSTOM INDEX ON baggage (
    passenger_id
) USING 'StorageAttachedIndex';

/********************************************************************
DEFAULT USER CREATE
********************************************************************/

insert into user (
    id,
    email,
    name,
    create_date
) values (
    33330000-1111-1111-1111-000011110000,
    'demo@datastax.com',
    'Demo',
    '2021-01-01'
);

-- Password is SHA256 hash of "demo"
insert into login (
    id,
    email,
    password,
    name
) values (
    33330000-1111-1111-1111-000011110000,
    'demo@datastax.com',
    '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea',
    'Demo'
);
