create schema ragger collate utf8_general_ci;

create table dictionaries
(
	id int auto_increment
		primary key,
	name varchar(255) default '' not null comment '单词名称',
	exp_cn json not null comment '单词的中文释义,是一个json对象',
	status tinyint default 0 not null,
	exps json null
);


