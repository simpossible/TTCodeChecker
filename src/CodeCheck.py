# -*- coding: UTF-8 -*-

import os
import filetype
import re
import IOSClass
import CodeChecker
from string import Template
# scanDir = "/Users/liangjinfeng/dev/CodeAutoCheck/resources"
# scanDir = "/Users/liangjinfeng/dev/TT/ios"

class CodeCheck(object):
    def __init__(self):
        print ""
        self.allClasses = []
        self.allClassesDic = {}
        self.scanDir = "/Users/liangjinfeng/dev/TT/ios"

#获取interfacecontent的类名
    def classNameForOCInterFaceContent(self,content):
        pattern = re.compile("@interface(.+?)[:|\(]")
        result1 = pattern.findall(content)
        if len(result1) != 0:
            pattern2 = re.compile("[^ ]+")
            result = result1[0]
            result2 = pattern2.findall(result)
            if len(result2) > 0:
                name = result2[0]
                name = name.strip()
                return name

        return ""

    def superClassNameForOCInterFaceContent(self,content):
        pattern = re.compile("@interface.+\:(.+)( {0,}|<)")
        result1 = pattern.findall(content)
        if len(result1) != 0:
            result = result1[0][0]
            result = result.strip()
            return result



#寻找类定义
    def dealFileContentForInterFace(self,fileContent,filepath):
        pattern = re.compile("@interface .+?@end", re.DOTALL)
        result1 = pattern.findall(fileContent)
        for result in result1:
            className = self.classNameForOCInterFaceContent(result)
            superName = self.superClassNameForOCInterFaceContent(content=result)
            supercls = None
            if superName != "" and superName:
                existClas = self.allClassesDic.get(superName)
                if not existClas:
                    scls = IOSClass.IOSClass(filepath)
                    scls.name = superName
                    self.allClassesDic[superName] = scls
                    supercls = scls
                else:
                    supercls = existClas

            if className != "":
                existClas = self.allClassesDic.get(className)
                if existClas:
                    existClas = self.allClassesDic[className]
                    existClas.appendOCInterFace(result)
                else:
                    cls = IOSClass.IOSClass(filepath)
                    cls.name = className
                    self.allClassesDic[className] = cls
                    cls.appendOCInterFace(result)
                    existClas = cls
                if supercls:
                    existClas.superClass = supercls


            else:
                print "未找到类名 路径：", filepath


    def classNameForOCImplementionContent(self,content):
        pattern = re.compile("@implementation(.+?)[\n| ]")
        result1 = pattern.findall(content)
        if len(result1) != 0:
            result = result1[0]
            result = result.strip()
            return result

        return ""

    def dealFileContentForImplemention(self,fileContent,filepath):
        pattern = re.compile("@implementation .+?@end", re.DOTALL)
        result1 = pattern.findall(fileContent)
        for result in result1:
            className = self.classNameForOCImplementionContent(result)
            if className != "":
                existClas = self.allClassesDic.get(className)
                if existClas:
                    existClas = self.allClassesDic[className]
                    existClas.appendOCImplemention(result)
                else:
                    cls = IOSClass.IOSClass(filepath)
                    cls.name = className
                    self.allClassesDic[className] = cls
                    cls.appendOCImplemention(result)
            else:
                print "未找到类名 路径：", filepath

    def parserOcFile(self,filepath):
        f = open(filepath, "r")
        fileContent = f.read()
        self.dealFileContentForInterFace(fileContent, filepath)
        self.dealFileContentForImplemention(fileContent, filepath)

        f.close()



    def file_extension(self,path):
        return os.path.splitext(path)[1]

    def loopFilesInPath(self,path):
        print "进入文件夹：", path
        for root, dirs, files in os.walk(self.scanDir, topdown=False):
            # 过滤文件夹
            for file in files:
                newpath = os.path.join(root, file)
                kind = self.file_extension(file)
                if kind == '.m' or kind == ".h" or kind == ".mm":
                    self.parserOcFile(newpath)
            for dir in dirs:
                newpath = os.path.join(root, dir)


    def startCheck(self):

        codeChecker = CodeChecker.CodeChecker()

        # try:
        self.loopFilesInPath(self.scanDir)
        allIosClass = self.allClassesDic.values()

        ppCheck = []
        clasCheck = []
        for cls in allIosClass:
            pp = codeChecker.checkIosProperty(cls)
            ppCheck.extend(pp)
            cc = codeChecker.checkIosMethods(cls)
            clasCheck.extend(cc)


        ppstring=""
        for pps in ppCheck:
            ppstring = ppstring + '\n'+pps

        ccstring=""
        for ccs in clasCheck:
            ccstring = ccstring + '\n'+ccs

        s = Template("""
        检查类的个数为：$allClassCount
        
        -------------------属性合法性检查-----------------
        $ppc
        
        -------------------重载合法性检查-----------------
        $ccc
        
        """)
        allClassCount = len(allIosClass)

        result = s.substitute(allClassCount = allClassCount,ppc=ppstring,ccc=ccstring)
        print result
        return result





check= CodeCheck()
check.startCheck()
# except BaseException ,e:
#     print "error is ",e