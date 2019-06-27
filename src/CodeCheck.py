# -*- coding: UTF-8 -*-

import os
import filetype
import re
scanDir = "/Users/liangjinfeng/dev/CodeAutoCheck/resources"


allClasses = []
allClassesDic = {}

#获取interfacecontent的类名
def classNameForOCInterFaceContent(content):
    pattern = re.compile("@interface(.+?)[:|\(]")
    result1 = pattern.findall(content)
    if len(result1) != 0:
        return  result1[0]

def parserOcFile(filepath):
    f = open(filepath, "r")
    fileContent = f.read()
    pattern = re.compile("@interface .+?@end",re.DOTALL)
    result1 = pattern.findall(fileContent)
    for result in result1:
        className = classNameForOCInterFaceContent(result)
        print "classNameis:",className
    f.close()
    os._exit(0)



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
                if kind == '.h' :
                    parserOcFile(newpath)
                print "文件类型是:", kind
            for dir in dirs:
                newpath = os.path.join(root, dir)





try:
    loopFilesInPath(scanDir)
except BaseException ,e:
    print "error is ",e