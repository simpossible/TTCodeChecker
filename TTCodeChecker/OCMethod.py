# -*- coding: UTF-8 -*-

import re
from string import Template
class OCMethod(object):
    def __init__(self):
        self.name = ""
        self.firstName = ""
        self.ocMethods = []

    def initialWithContent(self,content):
        self.parseMethodNameForConten(content)
        self.content = content

    def parseMethodNameForConten(self,content):
        pattern = re.compile("- {0,}\(.+?\)(.+?)\{")
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            name = name.strip('-')
            #解析方法名字
            patternP = re.compile(r"\:\(.+?\).+? ")
            if name.find(':')>=0:
                name = name + " "
                pname = re.sub(patternP, ":", name, count=0, flags=0)
                pname = pname.strip()
                self.name = pname
                array = pname.split(":")
                if len(array) > 0:
                    self.firstName = array[0]
            else:
                name = name.strip()
                self.name = name
                self.firstName = name
    def appendMethod(self,md):
        self.ocMethods.append(md)

    def haveOCSuperMethod(self):
        patternP = re.compile(r"\:.*? ")
        pname = re.sub(patternP, ":", self.content, count=0, flags=0)
        search = "[super "+self.name
        if pname.find(search)>=0:
            return True
        else:
            return False