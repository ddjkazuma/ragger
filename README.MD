#### Ragger
基于Ruby的单词记忆程序

###### 部署步骤
1. 修改config.example.yml文件，补全数据库配置和有道api配置
2. 执行database/ragger.sql建立表结构
2. ```cp config.example.yml config.yml```
3. ```alias ragger ruby path/app.rb```(在当前shell脚本中使用alias配置ragger命令)

###### 使用
* ```ragger query <word>```查询需要查询的单词
* ```ragger review``` 开始复习