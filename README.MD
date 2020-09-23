#### Ragger
基于Ruby的单词记忆程序

###### 部署步骤
1. 修改config.example.yml文件，补全数据库配置和[有道智云api](https://ai.youdao.com/DOCSIRMA/html/%E8%87%AA%E7%84%B6%E8%AF%AD%E8%A8%80%E7%BF%BB%E8%AF%91/API%E6%96%87%E6%A1%A3/%E6%96%87%E6%9C%AC%E7%BF%BB%E8%AF%91%E6%9C%8D%E5%8A%A1/%E6%96%87%E6%9C%AC%E7%BF%BB%E8%AF%91%E6%9C%8D%E5%8A%A1-API%E6%96%87%E6%A1%A3.html)配置
2. 执行database/ragger.sql建立表结构
2. ```cp config.example.yml config.yml```
3. ```alias ragger ruby path/app.rb```(在当前shell脚本中使用alias配置ragger命令)

###### 使用
* ```ragger query <word>```查询需要查询的单词
* ```ragger review``` 开始复习