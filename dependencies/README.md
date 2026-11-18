# SDK兼容副本：可手动准备，不要求Python

MED不使用PI那套第三方组件。使用Delphi 13自带的RTL/VCL，但为了保留XP加载兼容，需要将一个UIAutomation入口改为延迟导入。

## 方法一：手动准备

1. 找到本机Delphi安装目录，例如：

   ```text
   C:\Program Files (x86)\Embarcadero\Studio\37.0\
   ```

2. 将其中的`source/rtl/win/Winapi.UIAutomation.pas`复制到本仓库：

   ```text
   src/sdk-overlay/Winapi.UIAutomation.pas
   ```

3. 在**复制出来的文件**中找到`UiaReturnRawElementProvider`的external声明，将末尾：

   ```pascal
   external 'UIAutomationCore.dll' name 'UiaReturnRawElementProvider';
   ```

   改成：

   ```pascal
   external 'UIAutomationCore.dll' name 'UiaReturnRawElementProvider' delayed;
   ```

   已有`delayed`时不要重复追加。其余声明和内容保持不变。不要修改Delphi安装目录原文件。

4. 在IDE中Build All，保证工程优先编译这个显式指定的单元。

## 方法二：可选Python准备

```powershell
python scripts/prepare_dependencies.py --bds "C:\Program Files (x86)\Embarcadero\Studio\37.0"
```

脚本仅使用Python标准库，检查声明后写入同一个副本，不下载或安装软件。IDE编译和成品运行不调用它。

## 发布范围

该副本来源于商业SDK，不纳入MIT源码分发；`.gitignore`及源码导出工具都会排除它。接收源码的人必须用自己的Delphi安装准备。此步骤也是本项目不能声称“新克隆后零准备直接编译”的原因。
