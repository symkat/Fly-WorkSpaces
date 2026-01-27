CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE person (
    id                          uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
    name                        citext          not null unique,
    email                       citext          not null unique,
    is_enabled                  boolean         not null default true,
    is_admin                    boolean         not null default false,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE auth_password (
    person_id                   uuid            not null unique references person(id),
    password                    text            not null,
    salt                        text            not null,
    updated_at                  timestamptz     not null default current_timestamp,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE sprite (
    id                          uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id                   uuid            not null references person(id),
    name                        text            not null,
    display_name                text            not null,
    description                 text            ,
    password                    text            ,
    hostname                    text            ,
    created_at                  timestamptz     not null default current_timestamp
);
