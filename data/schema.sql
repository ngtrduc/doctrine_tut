CREATE TABLE `post` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `title` text NOT NULL,
  `content` text NOT NULL,
  `status` int(11) NOT NULL,
  `date_created` datetime NOT NULL
);
CREATE TABLE `comment` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `author` varchar(128) NOT NULL,
  `date_created` datetime NOT NULL
);
CREATE TABLE `tag` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(128)
);
CREATE TABLE `post_tag` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
);
INSERT INTO tag(`name`) VALUES('ZF3');
INSERT INTO tag(`name`) VALUES('book');
INSERT INTO tag(`name`) VALUES('magento');
INSERT INTO tag(`name`) VALUES('bootstrap');

INSERT INTO post(`title`, `content`, `status`, `date_created`) VALUES(
   'A Free Book about Zend Framework',
   'I''m pleased to announce that now you can read my new book "Using Zend Framework 3" absolutely for free! Moreover, the book is an open-source project hosted on GitHub, so you are encouraged to contribute.',
   2, '2016-08-09 18:49');

INSERT INTO post(`title`, `content`, `status`, `date_created`) VALUES(
   'Getting Started with Magento Extension Development - Book Review',
   'Recently, I needed some good resource to start learning Magento e-Commerce system for one of my current web projects. For this project, I was required to write an extension module that would implement a customer-specific payment method.',
   2, '2016-08-10 18:51');

INSERT INTO post(`title`, `content`, `status`, `date_created`) VALUES(
   'Twitter Bootstrap - Making a Professionaly Looking Site',
   'Twitter Bootstrap (shortly, Bootstrap) is a popular CSS framework allowing to make your website professionally looking and visually appealing, even if you don''t have advanced designer skills.',
   2, '2016-08-11 13:01');

INSERT INTO post_tag(`post_id`, `tag_id`) VALUES(1, 1);
INSERT INTO post_tag(`post_id`, `tag_id`) VALUES(1, 2);
INSERT INTO post_tag(`post_id`, `tag_id`) VALUES(2, 2);
INSERT INTO post_tag(`post_id`, `tag_id`) VALUES(2, 3);
INSERT INTO post_tag(`post_id`, `tag_id`) VALUES(3, 4);

INSERT INTO comment(`post_id`, `content`, `author`, `date_created`) VALUES(
    1, 'Excellent post!', 'Oleg Krivtsov', '2016-08-09 19:20');
