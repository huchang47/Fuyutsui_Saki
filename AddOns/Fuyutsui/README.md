# Fuyutsui（“冬月修补匠3型”）

Fuyutsui Tinkerer是由日本大众消费电子巨头 冬月电子（Fuyutsuki Electronics） 研发的一块网络接入仓（Cyberdeck），能显著提升你玩《魔兽世界》的快感。
---

## 它到底做了什么？

- **Lua（游戏内）**：在屏幕顶部生成一条“色块/色条”数据。
- **Python（桌面端）**：扫描这条色条，从每个像素值获取队伍成员、光环、技能冷却等。
- **策略决策（职业逻辑）**：根据当前职业专精加载对应的逻辑模块里判断“下一步该干谁”。

结果就是：它不是一个顶尖科技,研发初衷是“易用性低”与“稳定性差”。这让它看起来不像军用设备那样充满杀气，反而更像是一台经过久经风霜的废土工作站。

## 工作原理（像素通信协议 · Lua <-> Python）

1. **Lua 端创建色条**
   - `core/block.lua` 会创建一个位于屏幕顶端的 `colorBars`（255 个块，高度 1 像素），并通过 `fu.updateOrCreatTextureByIndex(i, b)` 更新每个块的颜色。
   - Lua 通过颜色通道编码数据：每个块用 **G 通道作为索引（i/255）**，用 **B 通道作为数值（b）**。

2. **Python 端扫描色条**
   - `GetPixels.py` 会先找到起始像素 `(R=0, G=1, B=0)`，然后从起点向右扫描像素。
   - 以 **G 通道作为索引（1~255）**、以 **B 通道作为数值**，还原出一行 `row_data`。

3. **按配置还原结构化状态**
   - `config.yml` 定义 `state:` 的字段“每个字段在哪个 step 上”，以及每个职业专精的 `spells` 与 `group` 结构。
   - `build_state_dict()` 把 `row_data[step]` 解析成：
     - 顶层字段（例如“生命值/能量值/战斗/移动/施法/引导”等）
     - `spells`（技能冷却/可用性等）
     - `group`（队伍成员：每个成员对应一组字段）

---

## 如何启动
下面按“游戏内 Lua 插件 + 桌面端 Python”两部分说明。该项目面向 Windows（会调用屏幕截图与 Windows API）。

### 1. 文件放在哪里
1. **Lua 插件（WoW AddOn）**：把仓库里的 `AddOns/Fuyutsui` 这个文件夹整体复制到魔兽世界安装目录的 `Interface/AddOns/` 下面。
2. **桌面端（Python）**：保持仓库里的 `Fuyutsui/` 文件夹原样。


### 2. 安装 VS Code
1. 安装 VS Code（任意版本即可）。
2. 打开 VS Code 后：`文件 -> 打开文件夹`，选择你的项目根目录（也就是包含 `README.md` 的那个目录）。

### 3. 安装 Python
1. 安装 Python 3.x（建议 3.10+）。
2. 安装时建议勾选 “Add Python to PATH”（把 `python` 加入环境变量），这样后续在终端里能直接用 `python`。
3. 在 VS Code 里打开终端，执行：
   - `python --version`

### 4. 安装 Python 依赖
在 `Fuyutsui/`（**内层**那个，包含 `requirements.txt` 的目录）里执行：
1. 创建虚拟环境：
   - `python -m venv .venv`
2. 激活虚拟环境（PowerShell）：
   - `.\.venv\Scripts\Activate.ps1`
3. 安装依赖：
   - `pip install -r requirements.txt`
   - 由于 `logic_gui.py` 会调用 `GetPixels.py`，其中使用了 `mss` 做屏幕截图，因此还需要额外安装：
     - `pip install mss`

### 5. 运行（从游戏开始）
1. 启动魔兽世界，进入游戏后在插件列表里启用 **`Fuyutsui`**。
2. 确保游戏窗口标题与脚本默认匹配：
   - 桌面端默认用的窗口标题是 `魔兽世界`（在 `GetPixels.py` 里也有同样的默认值）
3. 在 `Fuyutsui/` 目录运行 GUI：
   - `python logic_gui.py`
4. 使用说明：
   - 程序会在后台读取颜色条数据并决定要发什么热键。
   - 按 `XBUTTON2`（鼠标侧键，Back/前进键里的其中一个，具体以你设备为准）可切换“逻辑开启/关闭”。

### 6. 常见问题
1. **扫描失败/找不到游戏窗口**：如果看到类似 “未找到游戏窗口或扫描失败”，说明 Python 没有匹配到游戏窗口标题。你需要在 `Fuyutsui/GetPixels.py` 的 `get_info(window_title="...")` 默认值，或在 `logic_gui.py` 里传入正确的标题字符串。
2. **热键不生效**：检查 `Fuyutsui/config.yml` 里当前职业/专精对应的 `keymap` 字段是否指向 `Fuyutsui/keymap/` 下存在的文件；同时确认你的游戏动作条/宏与逻辑发送的热键一致。



## 免责声明

本项目偏“个人工具/实验性质”，通过读取游戏画面像素并触发热键来实现辅助决策。
请你自行判断是否符合你的需求，别让它被荒坂发现。
