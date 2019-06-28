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


#寻找类定义
def dealFileContentForInterFace(fileContent,filepath):
    pattern = re.compile("@interface .+?@end", re.DOTALL)
    result1 = pattern.findall(fileContent)
    for result in result1:
        className = classNameForOCInterFaceContent(result)
        if className != "":
            print "classNameis:", className
            existClas = allClassesDic.get(className)
            if existClas:
                existClas = allClassesDic[className]
                existClas.appendOCInterFace(result)
            else:
                cls = IOSClass.IOSClass(filepath)
                cls.name = className
                allClassesDic[className] = cls
                cls.appendOCInterFace(result)
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
            print "classNameis:", className
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

        for name in files:

            # 过滤文件夹
            for file in files:
                newpath = os.path.join(root, file)
                kind = file_extension(file)
                if kind == '.m' :
                    parserOcFile(newpath)
                print "文件类型是:", kind
            for dir in dirs:
                newpath = os.path.join(root, dir)





# try:
loopFilesInPath(scanDir)
allclass = allClassesDic.keys()
print "所有的类为:",allclass
# except BaseException ,e:
#     print "error is ",e