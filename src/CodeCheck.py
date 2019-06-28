# -*- coding: UTF-8 -*-

import os
import filetype
import re
import IOSClass
scanDir = "/Users/liangjinfeng/dev/CodeAutoCheck/resources"


allClasses = []
allClassesDic = {}

#获取interfacecontent的类名
def classNameForOCInterFaceContent(content):
    pattern = re.compile("@interface(.+?)[:|\(]")
    result1 = pattern.findall(content)
    if len(result1) != 0:
        pattern2 = re.compile("[^ ]+")
        result = result1[0]
        result2 = pattern2.findall(result)
        if len(result2)>0:
            return  result2[0]

    return ""

def superClassNameForOCInterFaceContent(content):
    if content.find(":") >= 0:
        pattern = re.compile(":(.+?)[\n|<]")
        result1 =re.search(pattern, content, flags=0)
        if result1:
            name = result1.group(1)
            return name
        else:
            return ""


#寻找类定义
def dealFileContentForInterFace(fileContent,filepath):
    pattern = re.compile("@interface .+?@end", re.DOTALL)
    result1 = pattern.findall(fileContent)
    for result in result1:
        className = classNameForOCInterFaceContent(result)
        superName = superClassNameForOCInterFaceContent(content=result)
        supercls = None
        if superName != "":
            existClas = allClassesDic.get(superName)
            if not existClas:
                scls = IOSClass.IOSClass(filepath)
                scls.name = superName
                allClassesDic[superName] = scls
                supercls = scls
            else:
                supercls = existClas

        if className != "":
            existClas = allClassesDic.get(className)
            if existClas:
                existClas = allClassesDic[className]
                existClas.appendOCInterFace(result)
            else:
                cls = IOSClass.IOSClass(filepath)
                cls.name = className
                allClassesDic[className] = cls
                cls.appendOCInterFace(result)
                existClas = cls
            if supercls:
                existClas.superClass = supercls


        else:
            print "未找到类名 路径：", filepath


def classNameForOCImplementionContent(content):
    pattern = re.compile("@implementation(.+?)[\n| ]")
    result1 = pattern.findall(content)
    if len(result1) != 0:
        result = result1[0]
        result = result.strip()
        return result


    return ""

def dealFileContentForImplemention(fileContent,filepath):
    pattern = re.compile("@implementation .+?@end", re.DOTALL)
    result1 = pattern.findall(fileContent)
    for result in result1:
        className = classNameForOCImplementionContent(result)
        if className != "":
            existClas = allClassesDic.get(className)
            if existClas:
                existClas = allClassesDic[className]
                existClas.appendOCImplemention(result)
            else:
                cls = IOSClass.IOSClass(filepath)
                cls.name = className
                allClassesDic[className] = cls
                cls.appendOCImplemention(result)
        else:
            print "未找到类名 路径：", filepath

def parserOcFile(filepath):
    f = open(filepath, "r")
    fileContent = f.read()
    dealFileContentForInterFace(fileContent,filepath)
    dealFileContentForImplemention(fileContent,filepath)

    f.close()



def file_extension(path):
  return os.path.splitext(path)[1]

def loopFilesInPath(path):
    print "进入文件夹：", path
    for root, dirs, files in os.walk(scanDir,topdown=False):
            # 过滤文件夹
        for file in files:
            newpath = os.path.join(root, file)
            kind = file_extension(file)
            print "newpath is :", newpath
            if kind == '.m':
                parserOcFile(newpath)
        for dir in dirs:
            newpath = os.path.join(root, dir)





# try:
loopFilesInPath(scanDir)
for cls in allClassesDic.values():
    print cls.describe()
# except BaseException ,e:
#     print "error is ",e