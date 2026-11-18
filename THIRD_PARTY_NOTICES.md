# 来源与第三方范围

## MED

本项目基于原P3MED源码维护。原有单元、窗体和资源中的署名保留，不把旧代码标记为本次原创。本次维护版本按维护者指定的MIT发布，见LICENSE；这不等于声明原始历史源码包已经附带MIT。

## Delphi / RAD Studio

编译器、SDK、RTL、VCL属于Embarcadero及其相关权利人。本仓库不包含其源码或安装包。

`src/sdk-overlay/Winapi.UIAutomation.pas`由使用者从本机安装复制并做延迟导入适配，Git忽略，源码导出工具也明确排除该目录。不要上传生成的SDK副本。

## 游戏与界面资源

Patrician III的商标、程序、文字和美术资源归原权利人。窗体DFM及RES/ICO中的历史内嵌图片、图标沿用工具原有资源来源，不主张将游戏素材重新授权为MIT。本项目不提供游戏EXE、资源归档、存档或整套游戏。

构建所需的DFM/RES/ICO保留在工程中；它们不是应该全部删除的临时文件。

## 运行和构建依赖

产品使用Windows系统API与静态链接的Delphi运行库；项目未启用运行时BPL包。启动器依赖同版本MED3.dll。没有PI的InjLib.dll或第三方VCL组件运行依赖。

可选维护脚本使用Python标准库；IDE自动化的检查脚本使用pywin32/Pillow等本机工具时，这些工具不被打入产品。实际导出脚本仅使用Python标准库。项目代码中保留的可选Excel导出需用户本机安装相应COM应用，该功能不是MED启动依赖。
