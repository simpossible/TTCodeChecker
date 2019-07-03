# -*- coding: UTF-8 -*-

import re
from string import Template
import OCType
class OCProperty(object):

    def __init__(self):
        self.pps = []
        self.decorators = []

    def initialWithContent(self,content):
        self.content = content

        if self.content.find("IBOutlet")>=0:
            self.decorators.append("IBOutlet")
            content = content.replace("IBOutlet","")


        if content.find('^') >= 0:
            self.dealBlockType(content)
        else:
            self.getPropertyType(content)
            self.name = self.getPropertyName(content)
        self.getAllDecorate(content)

    #得到类名
    def getPropertyType(self, content):
        ppstr = "(@property {0,}(\([^\(]+\))?)"

        patternpp = re.compile(ppstr)
        result1 = patternpp.findall(content)

        ppcontetn = ""
        if len(result1) > 0:
            ppcontetn = result1[0][0]

        content = content.replace(ppcontetn,"")

        restr = "(.+?)[ |>]"
        if content.find('*')>=0:
            restr = ".+?\*"
        pattern = re.compile(restr)
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            name = name.strip()
            type = OCType.OCType(name)
            self.type = type
            return name
        else:
            print "获取属性失败:",content

    def dealBlockType(self,content):
        restr = "\)(.+);"
        pattern = re.compile(restr)
        result1 = pattern.findall(content)

        #名字
        nameReStr = "\^(.+?)\)"
        patternName = re.compile(nameReStr)
        nameResult = patternName.findall(content)

        name = ""
        if len(nameResult) > 0 :
            name = nameResult[0]
            self.name = name

        if len(result1) > 0:
            alltype = result1[0]
            alltype = alltype.strip()
            alltype = alltype.replace(name,"")
            #找到名字
            type = OCType.OCType(alltype)
            type.isBlockType = True
            self.type = type
            return name
        else:
            print "获取属性失败:",content

    def getPropertyName(self, content):
        s = Template("""$type(.+?);""")

        ahaha = s.substitute(type=self.type.type)
        pattern = re.compile(ahaha)
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            name = name.strip('*')
            name = name.strip()
            return name
    def getAllDecorate(self,content):
        pattern = re.compile("@property {0,}\((.+?)\)")
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            decorators = name.split(',')
            for de in decorators:
                d = de.strip()
                self.decorators.append(d)

    def appendProperty(self,pp):
        self.pps.append(pp)

    def haveAssignDecoretor(self):
        for des in self.decorators:
            if des == "assign":
                return True
        return False

    def describe(self):
        des = ""
        des = des + self.name
        for pp in self.pps:
            des = des + pp.describe()
        return des



