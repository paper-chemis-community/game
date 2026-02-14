# 纸片化学社区版：游戏本体

## 项目介绍

纸片化学社区版（Paper Chemis Community）是由 Tiger 开发的一款纸片化学游戏。该游戏使用纸片化学玩法，并带来了更高的自由度。

本项目为纸片化学社区版的游戏本体。除非你使用了自定义的数据格式，否则你不应该更改游戏本体。

## 项目结构

```text
game/

- project.godot
- icon.svg
- assets/
	- fonts/
		- AlibabaPuHuiTi-3-65-Medium.ttf    # 阿里巴巴普惠体
	- pics/
- scenes
	- main_menu.tscn
	- game.tscn
	- settings.tscn
- prefabs/
	- game/
		- card.tscn
- scripts/
	- autoload/
		- GameManager.gd        # 游戏管理
		- DownloadManager.gd    # 下载管理
		- MultiGame.gd          # 多人游戏功能
		- SceneManager.gd       # 场景管理
	- main_menu/
		- main_menu.gd
		- join_game_ui.gd
		- create_game_ui.gd
	- game/
		- game.gd
	- settings/
		- settings.gd
```

## 如何运行

请先运行数据后端，在游戏设置中输入后端 URL（包含端口号和 `http://` 或 `https://` 前缀，或者选择本地已有的数据源，然后创建游戏或加入游戏开始游玩。

## 最佳实践

本项目目前正在使用 Godot 4.6 进行开发。开发用语言为 GDScript。

你的开发应当遵循 Godot 引擎提供的[最佳实践](https://docs.godotengine.org/zh-cn/4.x/tutorials/best_practices/)及[GDScript 编写风格指南](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html)。但下面提到的除外：

除 `autoload` 目录下的单例脚本使用大驼峰式命名，其余脚本均应使用小蛇形式命令。所有节点均应使用大驼峰式命名。
