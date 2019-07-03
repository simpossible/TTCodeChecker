# -*- coding: UTF-8 -*-
import IOSClass
import OCType

ocsupers = {"UIView":["removeFromSuperview","addSubview:"],
            "UIControl":["removeFromSuperview","addSubview:"],
            "UIViewController":["viewDidLayoutSubviews","viewWillAppear:","viewDidAppear:","viewWillDisappear:","viewDidDisappear:"]}

class CodeChecker(object):

    def checkIosClass(self,cls):
        result = ""
        ppCheck = self.checkIosProperty(cls)

        return result


    def checkIosProperty(self,cls):
        result =[]
        for pp in cls.ocPropertoes.values():
            if not pp.type.isBaseType():#如果不是基础类型
                if pp.type.isPointer and pp.haveAssignDecoretor():
                    result.append(cls.name +":"+pp.content)


        return result

    def checkIosMethods(self, cls):
        result=[]
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
                            result.append(cls.name+":"+aMethod)

        return result
