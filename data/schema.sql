CREATE TABLE post (
  id bigserial PRIMARY KEY,
  title text NOT NULL,
  content text NOT NULL,
  status bigserial NOT NULL,
  date_created timestamp NOT NULL
);

CREATE TABLE comment (
  id bigserial PRIMARY KEY,
  post_id bigserial NOT NULL,
  content text NOT NULL,
  author varchar(128) NOT NULL,
  date_created timestamp NOT NULL
);
CREATE TABLE tag (
  id bigserial PRIMARY KEY,
  name VARCHAR(128)
);
CREATE TABLE post_tag (
  id bigserial PRIMARY KEY,
  post_id bigserial NOT NULL,
  tag_id bigserial NOT NULL
);
