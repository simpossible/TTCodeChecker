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
        self.thirdPartDir = []

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
        isFrameWork = False
        if filepath.find("Pods/") >= 0 or filepath.find("/3rd/")>= 0:
            isFrameWork = True

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

                if isFrameWork:#判断是否是库类型
                    existClas.isFromFrameWork = True


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

    def file_name(self,path):
        return os.path.splitext(path)[0]

    def loopFilesInPath(self,path):
        print "进入文件夹：", path
        swfitcount = 0
        for root, dirs, files in os.walk(self.scanDir, topdown=False):
            # 过滤文件夹
            # if self.isInBlackDir(root):
            #     continue
            for file in files:
                newpath = os.path.join(root, file)
                kind = self.file_extension(file)
                if kind == '.m' or kind == ".h" or kind == ".mm":
                    self.parserOcFile(newpath)
                elif kind == ".swift":
                    swfitcount = swfitcount + 1
                    # self.parseSwift(newpath)

    #混淆
    def loopMixFilesInPath(self, path,projectFiles):
        print "进入文件夹：", path
        swfitcount = 0
        for root, dirs, files in os.walk(self.scanDir, topdown=False):
            # 过滤文件夹
            if self.isInBlackDir(root):
                continue
            print "---:", root
            for file in files:
                newpath = os.path.join(root, file)
                kind = self.file_extension(file)
                name = self.file_name(file)
                types = [".m",".h",".mm",".c",".cpp",".h",".swift"]
                if name == "CommonChannelServiceClient":
                    print "--"

                if newpath.find(".framework") > 0:
                    print "库目录 不解析",newpath
                if projectFiles.has_key(name) or kind == ".h":#如果这个文件在工程目录中存在
                    if kind in types:
                        if name != "STCDefination":
                            self.parseReplaceString(newpath)

                # elif kind == ".swift":
                #     swfitcount = swfitcount + 1
                #     self.parseReplaceString(newpath)

    #检查应该被移除的文件 xib 里面的
    def loopCheckExtendFilesInPath(self, path,keyworkdMap):
        print "进入文件夹：", path
        for root, dirs, files in os.walk(self.scanDir, topdown=False):
            # 过滤文件夹
            for file in files:
                newpath = os.path.join(root, file)
                kind = self.file_extension(file)
                name = self.file_name(file)
                if kind == '.xib' or kind == ".storyboard": #移除xib 相关的keyword
                    if keyworkdMap.has_key(name):#统一不替换文件名字
                        keyworkdMap.pop(name)




    def parseReplaceString(self,newPath):
        print "开始替换：",newPath

        isSwift = newPath.find(".swift") >= 0

        f = open(newPath, "r+")

        allWords = ""
        word = ""
        fileContent = f.readline()
        while len(fileContent) > 0:
            index = 0  # 遍历所有的字符
            isInwords = False
            word = ""
            lenc = len(fileContent)


            if fileContent.startswith("#import") or fileContent.startswith("//"):
                allWords = allWords + fileContent
                fileContent = f.readline()
                continue

            lastCharBeforWord = "" #要识别出来是否是小数点后面的单词

            while index < lenc:  # 当index小于p的长度
                curChar = fileContent[index]
                index = index + 1
                charindex = ord(curChar)
                if curChar.isalpha() or curChar == '_':
                    isInwords = True
                    word = word + curChar
                else:
                    if not isInwords:
                        lastCharBeforWord = curChar  # 记录单词前的符号是什么

                    if curChar.isdigit() and isInwords:
                        word = word + curChar
                    else:
                        isInwords = False
                        # if word == "dic":

                        if self.swiftKeyword.has_key(word) and word != "dic":
                            value = self.swiftKeyword[word]
                            if isSwift and lastCharBeforWord == '(': #如果是swift 并且 后面的单词
                                value = self.firstLower(value)
                            allWords = allWords + value  # 这里替换了字符
                            allWords = allWords + curChar
                        else:
                            allWords = allWords + word
                            allWords = allWords + curChar
                        word = ""


            fileContent = f.readline()

        allWords = allWords + word
        allWords = allWords + "//mix by ibl \n"
        # print fileContent
        # print allWords
        f.seek(0)
        f.truncate()
        f.write(allWords)
        f.close()
        print "结束替换",newPath

    def firstLower(self,string):
        ''' 字符转换
        :param string: 传入原始字符串
        :param lower_rest: bool, 控制参数--是否将剩余字母都变为小写
        :return: 改变后的字符
        '''
        return string[:1].lower() + string[1:]

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

    def startMix(self):

        #解析工程有哪些类在编译中
        projPath = "/Users/liangjinfeng/dev/TT/ios/TT-iOS/TT/TT.xcodeproj/project.pbxproj"
        projectFiles = self.parseXcodeProj(projPath)

        keyWordsMap = parseDefine("/Users/liangjinfeng/dev/TT/ios/TT-iOS/TT/STCDefination.h")

        excludePrefix = ["GPB"]

        for pre in excludePrefix:
            for k, v in keyWordsMap.items():
                if k.startswith(pre):  # 不要GBP开头的类
                    keyWordsMap.pop(k)

        excludeWords = ["pow","Type","test","cmd"] #过滤掉系统c 函数

        for exclude in excludeWords:
            for k, v in keyWordsMap.items():
                if k == exclude:  #
                    keyWordsMap.pop(k)

                if len(k) < 6:
                    print "可能是系统函数",k,"--",v


        print "orgLen is ", len(keyWordsMap)
        self.loopFilesInPath(self.scanDir)
        allIosClass = self.allClassesDic.values()
        for cls in allIosClass:
            cls.doForMixKeyWords(keyWordsMap)

        self.swiftKeyword = keyWordsMap
        self.loopCheckExtendFilesInPath(self.scanDir,keyWordsMap)

        self.writeFileMap("backUp.json",keyWordsMap)

        #正式替换
        self.loopMixFilesInPath(self.scanDir,projectFiles)

    def writeFileMap(self,path,map):
        f = open(path, "r+")
        f.seek(0)
        jsonstr = json.dumps(map)
        f.write(jsonstr)
        f.close

    def parseXcodeProj(self,filepath):
        f = open(filepath, "r")
        fileContent = f.read()

        map = {}
        pattern = re.compile("/\*(.+?)\*/", re.DOTALL)
        result1 = pattern.findall(fileContent)
        if len(result1) > 0:
            for content in result1:
                if content.find("in Sources") >= 0:
                    org = content
                    content = content.strip("in Sources")
                    content = content.strip(" ")
                    array = content.split('.')
                    if len(array) > 1:
                        fileName = array[0]
                        fileType = array[1]
                        # if fileType == "m" or fileType == "mm" or fileType == "swift":
                        map[fileName]=content

                print content

        f.close()
        return map

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



    # keyWordsMap = loadFromJson("/Users/liangjinfeng/dev/TT/ios/TT-iOS/TT/confuse.json")
    # newkeymap = {}
    # for k,v in keyWordsMap.items():
    #     newkeymap[v]=k
    # check.swiftKeyword = keyWordsMap


    #
    # print newkeymap

    check.scanDir = "/Users/liangjinfeng/dev/TT/ios/TT-iOS"
    check.addBlackDir(["Pods"])
    # check.thirdPartDir = ["",""]

    # aa = check.startCheck()
    check.startMix()
    # print  aa
    # print(__name__)



# except BaseException ,e:
#     print "error is ",e