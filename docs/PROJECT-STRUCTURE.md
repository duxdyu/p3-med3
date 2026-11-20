# 目录与 Git 管理

Delphi 13 没有要求所有项目必须使用 `src/`。小项目可以将工程和单元放在根目录；本项目包含 DLL、启动器和多个测试工程，采用以下布局：

```text
p3-med3/
├── MED.groupproj            产品工程组入口
├── src/
│   ├── med/                MED3、P3MED 工程及产品单元、窗体、资源
│   ├── shared/             共享规则源码
│   └── sdk-overlay/        本机 SDK 兼容副本（忽略）
├── tests/
│   ├── Tests.groupproj      测试工程组入口
│   └── med/                三个测试工程、测试单元及资源
├── scripts/                依赖准备、构建与源码导出
├── dependencies/           依赖准备说明
├── docs/                   项目文档
├── build/                  编译输出、DCU、日志及导出包（忽略）
└── README.md 等             使用、构建、安装和许可说明
```

`p3-insight` 可参考其 `tests/`、`docs/`、`scripts/` 职责划分；其根目录包含历史工程，不作为本项目必须复制的布局。

产品 `.dpr/.dproj` 放在 `src/med/`，根目录通过 `.groupproj` 打开即可。窗体 `.pas` 与 `.dfm` 放在一起；当前资源与所属工程放在一起，不必额外拆出空的 `resources/` 或 `assets/`。

## 应纳入 Git

- 产品及测试源码：`.pas`、`.dpr`、`.dfm`，以及未来手写的 `.inc/.rc`。
- 工程配置：`.dproj`、`.groupproj`。
- 构建输入资源：当前 `.res/.ico`。不要一概忽略 `.res`，其中可能包含图标、版本或其他必要资源。
- `scripts/`、`docs/`、`dependencies/` 的脚本和说明。
- README、构建/安装说明、许可与第三方声明，以及 `.gitignore/.gitattributes`。

## 不纳入 Git，但保留本地文件

- `build/`、`dist/` 及编译产物 `.exe/.dll/.dcu/.dcp/.bpl` 等。
- `.dproj.local/.groupproj.local`、IDE 缓存、`__history/`、`__recovery/`。
- `.idea/`、`.xcodemap/`、`.vs/`。
- `src/sdk-overlay/`、`src/vendor/` 等本机依赖副本。
- 构建日志、`*-build-result.json`、个人 `MED.ini`。不提供预置INI，程序在配置缺失时使用默认值，保存设置时自动创建。

本次整理保留了原有日志和本地配置；历史 `src/build-history/` 等仍由忽略规则排除。新构建输出继续写入 `build/`。

若以后引入必须随源码提供的预编译 `.obj/.lib` 或手写 `.cfg`，需为具体文件调整忽略规则，不能直接套用“同扩展名都是产物”的判断。

## 发布前检查

```powershell
git status --short
git status --short --ignored
git add --dry-run .
```

确认清单后再暂存、审阅及提交。Git 忽略不等于删除文件，且不会自动停止跟踪已经提交的文件。本次目录整理未执行暂存、提交或推送。
