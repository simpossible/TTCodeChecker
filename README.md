# TTCodeChecker

	使用python 对 iOS 工程的代码进行遍历检查代码的规范性。

	目前支持的检查有：
		1.属性中对 对象属性使用 ``` assign ``` 关键字
		2.UIView,UIViewController 中 对部分方法重载后没有调用super



使用方法：
```
    check = CodeCheck()
    check.scanDir = "projectdir"
    check.addBlackDir(["Pods"])
    aa = check.startCheck()

```