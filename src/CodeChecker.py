# -*- coding: UTF-8 -*-
import IOSClass
import OCType

ocsupers = {"UIView":["removeFromSuperview","addSubview:"],
            "UIControl":["removeFromSuperview","addSubview:"],
            "UIViewController":["viewDidLayoutSubviews","viewWillAppear:","viewDidAppear:","viewWillDisappear:","viewDidDisappear:"]}

class CodeChecker(object):

    def checkIosClass(self,cls):
        # ppCheck = self.checkIosProperty(cls)
        # if len(ppCheck) > 0:
        #     result = "类名: " + cls.name
        #     result = result + "\n" + "属性检查"
        #     for tip in ppCheck:
        #         result = result + "\n" + "    " + tip
        #     return result

        self.checkIosMethods(cls)
        return ""


    def checkIosProperty(self,cls):
        result =[]
        for pp in cls.ocPropertoes.values():
            if not pp.type.isBaseType():#如果不是基础类型
                if pp.type.isPointer and pp.haveAssignDecoretor():
                    result.append(pp.content)


        return result

    def checkIosMethods(self, cls):
        superName = cls.baseClass().name
        allSuperClasses = ocsupers.keys()
        for superClass in allSuperClasses:
            if superName == superClass:#如果这个类是这个的子类
                array = ocsupers[superClass]
                for aMethod in array:
                    exist = cls.getMethod(aMethod)
                    if exist:
                        haveSuper = exist.haveOCSuperMethod()
                        if not haveSuper:
                            print "没有啊：",superClass,"method:",aMethod

