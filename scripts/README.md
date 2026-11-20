# 可选辅助脚本

**产品以Delphi 13 IDE工程为准，运行不需要本目录。**

| 文件 | 保留原因 |
|---|---|
| `prepare_dependencies.py` | 可选的一次性SDK兼容副本准备；可用手工复制/修改代替 |
| `build.py` | 可选构建/测试入口：`app`、`tests`、`all` |
| `build_ide.py` | `build.py`内部调用的IDE驱动，使用`MED.groupproj`和`tests/Tests.groupproj` |
| `package_runtime.py` | 校验本次构建后，将P3MED.exe和MED3.dll复制到`build/p3-med3/` |
| `export_source.py` | 按白名单导出干净源码，避免上传SDK和本机缓存 |

已删除图标提取脚本；资源文件已在工程中，不需要从旧EXE提取。
根目录与`src/`不再放Python脚本，也不再保留重复的总组工程。

构建和测试均可完全在IDE中完成，见[BUILDING.md](../BUILDING.md)；
首次SDK准备的手工步骤见[dependencies/README.md](../dependencies/README.md)。
