# Haxe + TIC-80 Template (Lua cart)

这个工程是一个 **Haxe 编写逻辑**、并输出为 **TIC-80 可运行的 `main.lua`** 的模板工程。

- **目标平台**：TIC-80（Lua 脚本）
- **工作流（Extract + Merge）**：
  - 用 Haxe 编写游戏逻辑（示例为 Snake）
  - 构建时 Haxe 输出到 `build/gen.lua`
  - 合并工具执行两件事：
    - **Extract**：如果存在 `cart/main.lua`，自动把其中的 TIC-80 数据段提取到 `assets/assets.lua`（建议提交 Git）
    - **Merge**：用 `assets/assets.lua` + `build/gen.lua` 生成 `cart/main.lua`（TIC-80 永远只需要打开它）

Snake 游戏作为本模板的 **Hello World**。

## 目录结构

- `src/`
  - `Main.hx`：游戏入口（当前为 Snake）
  - `tic/Tic.hx`：TIC-80 API extern（让 Haxe 侧可类型检查）
- `tools/`
-  - `Build.hx`：合并/注入工具（Extract + Merge）
- `assets/`
  - `assets.lua`：TIC-80 数据段（资源源文件，建议提交 Git）
- `cart/`
  - `main.lua`：TIC-80 运行文件（构建生成，默认不提交 Git）
- `build/`
  - `gen.lua`：Haxe Lua 输出（中间产物，构建生成，默认不提交 Git）

## 前置要求

- 安装 **Haxe**（建议 4.x）并确保命令行可用：
  - `haxe -version`
- 安装 **TIC-80**（本模板按 Lua cart 工作）

> 注意：TIC-80 的 Lua 是沙盒环境，很多标准库/第三方模块不可用（例如 `os`、外部 `require` 模块）。本模板在合并注入时会加入 shim，保证 Haxe runtime 在 TIC-80 下可运行。

## 构建（Windows / PowerShell）

在工程根目录执行：

1) **编译 Haxe -> Lua（生成中间产物）**
```powershell
haxe build.hxml
```
这会生成：
- `build/gen.lua`

2) **合并注入到 TIC-80 cart**
```powershell
haxe merge.hxml
```
这一步会：
- 从 `cart/main.lua` 提取数据段到 `assets/assets.lua`（如果 `cart/main.lua` 存在且包含数据段）
- 用 `assets/assets.lua` + `build/gen.lua` 生成新的 `cart/main.lua`

> 本模板默认 `.gitignore` 会忽略 `build/` 和 `cart/`，因此首次 clone 后需要先执行 `haxe build.hxml` + `haxe merge.hxml` 才能得到 `cart/main.lua`。

## 在 TIC-80 中运行

在 TIC-80 控制台中：

```lua
load cart/main.lua
run
```

## 工作流说明（推荐用法）

### Extract + Merge（当前工程采用）

- **资源源文件**：`assets/assets.lua`
  - Git 中建议以它作为“资源的权威来源”
- **TIC-80 直接运行**：`cart/main.lua`
  - 每次 `haxe merge.hxml` 会用 `assets/assets.lua` 重新生成它（默认不入库）

### 在 TIC-80 里改资源的推荐姿势

1. 先生成可运行 cart：
   - `haxe build.hxml`
   - `haxe merge.hxml`
2. 用 TIC-80 打开并编辑 `cart/main.lua` 的资源（数据段）并保存
3. 回到命令行运行一次：
   - `haxe merge.hxml`
4. 这会把你刚刚改的资源自动同步到 `assets/assets.lua`

### 为什么需要“注入/合并”

TIC-80 把资源存储在同一个 `main.lua` 文件的 **数据段** 中。
如果直接让 Haxe 把整个 `main.lua` 覆盖写掉，就会丢失你在 TIC-80 里编辑的资源。

因此本模板采用：
- Haxe 只生成代码：`build/gen.lua`
- 合并器负责：
  - 保留 header 注释
  - 保留所有数据段
  - 注入最新 Haxe 代码

## Snake（Hello World）玩法

- **方向键**：
  - 上：`btnp(0)`
  - 下：`btnp(1)`
  - 左：`btnp(2)`
  - 右：`btnp(3)`
- **规则**：
  - 吃到食物增长并加分
  - 撞墙/撞到自己会重开
- **渲染**：
  - 黑底（`cls(0)`）
  - 蛇身用 `spr(33, ...)` 绘制
  - 食物用 `spr(34, ...)` 绘制

## 一次典型的开发迭代（资源 + 代码）

目标：在 TIC-80 里改资源（例如新增/修改 sprite），并让 Haxe 逻辑引用新的贴图。

1) 在 TIC-80 中：
- `load cart/main.lua`
- 修改/新增资源并保存（例如新增 #34）

2) 回到命令行同步资源（Extract）：
```powershell
haxe merge.hxml
```
这会把 `cart/main.lua` 中的数据段同步到 `assets/assets.lua`。

3) 修改 Haxe 代码并构建（示例：把食物贴图换成 #34）：
```powershell
haxe build.hxml
haxe merge.hxml
```
最终仍然是 TIC-80 打开 `cart/main.lua` 运行。

## TIC-80 兼容性说明（重要）

### 1) 外部 Lua 模块不可用
TIC-80 里不能 `require` 你系统上的 Lua 模块（例如 `rex_pcre2`、`lua-utf8`）。

- 本模板通过合并注入时的 shim：
  - 为 `package.preload['lua-utf8']` 提供回退实现
  - 为 `package.preload['rex_pcre2']` 提供空实现

### 2) `os` 库不可用
Haxe runtime 可能会调用 `os.time()`。

- 本模板 shim 里提供了最小 `os.time()`，优先使用 TIC-80 的 `tstamp()`。

### 3) `tic.Tic.*` 桥接
当前 Haxe 输出会以 `tic.Tic.btnp/cls/spr/tstamp` 的形式调用 API。

- 本模板 shim 会创建 `_G.tic.Tic` 并把它映射到 TIC-80 的全局 `btnp/cls/spr/tstamp`。

## 常见操作

- **想换游戏逻辑**：改 `src/Main.hx`，再运行构建两步。
- **想编辑资源**：
  - 用 TIC-80 打开 `cart/main.lua`，修改数据段并保存
  - 跑 `haxe merge.hxml`，把数据段同步到 `assets/assets.lua`

## Git 提交建议

建议提交（模板必需）：
- `src/`
- `tools/`
- `build.hxml`、`merge.hxml`
- `assets/assets.lua`
- `README.md`

建议忽略（见 `.gitignore`）：
- `build/`（中间产物目录）
- `cart/`（运行产物目录）

## License

按你的项目需要自行添加。
