# -*- coding: UTF-8 -*-

import os
import re
import IOSClass
import CodeChecker
from string import Template
import json
# scanDir = "/Users/liangjinfeng/dev/CodeAutoCheck/resources"
# scanDir = "/Users/liangjinfeng/dev/TT/ios"

class CodeCheck(object):
    def __init__(self):
        print ""
        self.allClasses = []
        self.allClassesDic = {}
        self.scanDir = "/Users/liangjinfeng/dev/TT/ios"
        #黑名单 子目录
        self.unScanDir = []

        self.swiftKeyword = {}

    #是否在黑名单
    def isInBlackDir(self,dir):
        for dd in self.unScanDir:
            rdd = self.scanDir+"/"+dd
            if dir.find(rdd)==0:
                return True
        return False

    def addBlackDir(self,black):
        self.unScanDir.extend(black)


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
        swfitcount = 0
        for root, dirs, files in os.walk(self.scanDir, topdown=False):
            # 过滤文件夹
            if self.isInBlackDir(root):
                continue
            print "---:",root
            for file in files:
                newpath = os.path.join(root, file)
                kind = self.file_extension(file)
                if kind == '.m' or kind == ".h" or kind == ".mm":
                    # self.parserOcFile(newpath)
                    continue
                elif kind == ".swift":
                    swfitcount = swfitcount + 1
                    self.parseSwift(newpath)
        print "hahaha" , swfitcount
        print "as"

    def parseSwift(self,newPath):
        f = open(newPath, "r+")
        fileContent = f.read()
        words = []
        index = 0  # 遍历所有的字符

        allWords = ""
        isInwords = False
        word = ""
        lenc = len(fileContent)
        while index < lenc:  # 当index小于p的长度
            curChar = fileContent[index]
            index = index + 1
            charindex = ord(curChar)
            if curChar.isalpha() or curChar =='_' :
                isInwords = True
                word=word+curChar
            else:
                if curChar.isdigit() and isInwords:
                    word = word + curChar
                else:
                    isInwords = False
                    # if word == "dic":

                    if self.swiftKeyword.has_key(word) and word != "dic":
                        value = self.swiftKeyword[word]
                        allWords = allWords + value  # 这里替换了字符
                        allWords = allWords + curChar
                    else:
                        allWords = allWords + word
                        allWords = allWords + curChar
                    word = ""

        print fileContent
        print allWords
        f.seek(0)
        f.write(allWords)
        f.close()


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
        return result

def parseDefine(filepath):
    f = open(filepath, "r")
    fileContent = f.read()

    map = {}
    pattern = re.compile("ifndef.+?endif",re.DOTALL)
    result1 = pattern.findall(fileContent)
    if len(result1) > 0 :
        for content in result1:
            pattern = re.compile("define(.+?)\n", re.DOTALL)
            result2 = pattern.findall(content)
            if len(result2) > 0:
                keyvalue = result2[0]
                array = keyvalue.split(' ')
                if len(array) > 2:
                    key = array[1]
                    value = array[2]
                    map[key]=value
                    print "key is ",key,"value",value
            print content

    f.close()
    return map

def loadFromJson(filepath):
    f = open(filepath, "r")
    fileContent = f.read()
    dic = json.loads(fileContent)
    f.close()
    return  dic

if __name__ == '__main__':
    check = CodeCheck()

    keyWordsMap = parseDefine("/Users/liangjinfeng/dev/TT/ios/TT-iOS/TT/STCDefination.h")

    # keyWordsMap = loadFromJson("/Users/liangjinfeng/dev/TT/ios/TT-iOS/TT/confuse.json")
    # newkeymap = {}
    # for k,v in keyWordsMap.items():
    #     newkeymap[v]=k
    check.swiftKeyword = keyWordsMap
    #
    # print newkeymap

    check.scanDir = "/Users/liangjinfeng/dev/TT/ios/TT-iOS"
    check.addBlackDir(["Pods"])
    aa = check.startCheck()
    print  aa
    # print(__name__)



# except BaseException ,e:
#     print "error is ",e