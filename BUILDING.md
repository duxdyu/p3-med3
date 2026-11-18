# Delphi 13 构建

## 工具链与依赖

- Windows，已安装并可正常使用的Delphi 13 / RAD Studio 37.0，Win32目标。
- 产品全部由Delphi编译：Pascal、内联x86汇编、DFM和工程资源。
- 不需要CMake、MSVC、MASM、旧DLL、PI工程或外部转换脚本。
- 不启用运行时BPL；源码本身不需要额外安装第三方VCL设计器组件。
- 唯一需要准备的非仓库源码是本机SDK的UIAutomation兼容副本，见[依赖准备](dependencies/README.md)。

## 无Python构建步骤

1. 按依赖说明手动复制并修改**本地副本**`src/sdk-overlay/Winapi.UIAutomation.pas`。
2. 打开根目录`MED.groupproj`。项目组应只有`MED3`和`P3MED`两个产品工程。
3. 平台选择Win32。保留工程当前默认编译选项，选择Build All。
4. 获取`build/P3Med3/MED3.dll`和`build/P3Med3/P3MED.exe`。
5. 按[安装说明](INSTALL.md)部署。无需修改产物或运行Python后处理。

当前dproj沿用已验证的诊断友好配置：默认Debug、保留栈帧、未启用优化，使用SDK release库。不要把默认配置名称写成已经验证过的Release优化构建。普通运行不需要IDE，也不需要调试器。

如只编译单个产品，可打开`src/med/MED3.dproj`或`src/med/P3MED.dproj`。不要对DLL工程按F9；构建不需要启动游戏。

## 离线测试

打开`tests/Tests.groupproj`，Build All后依次执行：

```text
build/tests/MedProductionTests.exe
build/tests/MedMemoryTextTests.exe
build/tests/ProcessAccessTests.exe
```

均为离线检查，不需要游戏。贷款规则回归包含在MedMemoryTextTests中。离线通过不能代替F2、点击命中、事件清除等游戏交互验收。

## 可选维护脚本

```powershell
python scripts/prepare_dependencies.py --bds "C:\Program Files (x86)\Embarcadero\Studio\37.0"
python scripts/build.py app --bds "C:\Program Files (x86)\Embarcadero\Studio\37.0"
python scripts/build.py tests --bds "C:\Program Files (x86)\Embarcadero\Studio\37.0"
```

`scripts/prepare_dependencies.py`只准备忽略目录里的SDK副本；`scripts/build.py`通过同目录`build_ide.py`调用Delphi IDE。`app`打开根目录MED.groupproj，`tests`打开tests/Tests.groupproj，`all`依次构建并测试（默认）。日志在`build/logs/`。它们不是运行依赖，也不是Pascal替代编译器。

当前ICO/RES构建资源已提供，不需要图标提取工具，也不依赖旧版EXE。

## 输出与干净重建

所有EXE/DLL/DCU位于`build/`。关闭IDE后可移走`build/`再Build All；不要删除`src/med/`中的DFM、RES或ICO，它们是明确构建输入。

源码导出不包含生成的SDK文件。新机器第一次编译时必须先完成本机SDK准备；“源码包完整”不等于能在没有Delphi SDK的机器上编译。
