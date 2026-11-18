# 发布到独立GitHub仓库

当前`p3-med3`目录是独立Git仓库根目录。按`.gitignore`检查并暂存公开文件即可，不需要复制`p3-insight`或整个游戏目录。文件范围见[目录说明](PROJECT-STRUCTURE.md)。

## 可选：白名单导出

在MED根目录：

```powershell
python scripts/export_source.py --output build/github-source
```

输出：
- `build/github-source/`：适合初始化独立仓库的干净目录；
- `build/github-source.zip`：同内容源码包；
- `build/github-source.manifest.json`：逐文件SHA256。

输出位置必须尚不存在。脚本不会执行`git init`、提交、推送或覆盖任何已有发布包；不包含SDK、编译产物、本机配置、个人MED.ini、游戏或存档。

若不使用Python，按以下文件范围复制：

- 根目录的Markdown、LICENSE、`.gitignore`、`.gitattributes`、`MED.groupproj`；
- `src/med/`的`.pas/.dfm/.dpr/.dproj/.res/.ico`；
- `src/shared/`的`.pas`；
- `tests/`的测试源码、工程、组工程、资源及Markdown说明；
- `scripts/`中的四个可选辅助Python脚本；
- `docs/`、`dependencies/`。

不要把整个本机目录压缩后直接上传：其中可能有被Git忽略的SDK副本及编译缓存。`.res/.ico`是构建输入，需保留；`.dcu/.dll/.exe`是生成产物，不属于源码仓库。

## 在GitHub上发布

1. 建立空仓库，将干净导出的内容作为根目录。
2. 检查暂存文件清单，确认没有`build/`、`src/sdk-overlay/`、个人配置或本机绝对路径日志。
3. 确认README和LICENSE，然后由维护者提交、推送。
4. 如需提供成品，在自己验证后新建GitHub Release，附件单独放`P3Med3/P3MED.exe`与`MED3.dll`及安装说明；不要把生成SDK放入附件。

当前本地整理没有进行任何Git提交/推送，也不改写游戏工作区`releases/`内的历史ZIP。
