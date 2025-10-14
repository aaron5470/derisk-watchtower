# Bilingual Output Style Guide（双语输出规范）

## 总规则
- 所有段落必须**中英一一对应**，中文在上/左，英文在下/右。
- 专有名词以英文为准，中文保留音译或常用译名，并在首次出现处括号标注英文。
- 任务/命令/代码块：先给中文解释，后给英文解释；命令仅写一次。

## 模式 A：分段对照（长文档优先）
### 章节标题（中文 / English）
- [中] 段落……
- [EN] Paragraph…

### 子条目（中文 / English）
- [中] 要点 1……
- [EN] Point 1…

## 模式 B：两列表格（简短说明或对照清单）
| 中文 | English |
| --- | --- |
| 简介…… | Summary… |
| 目标…… | Goals… |

## 代码与命令
```sh
# 中文说明（English explanation）
forge build
