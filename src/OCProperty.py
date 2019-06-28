# -*- coding: UTF-8 -*-

import re
from string import Template
class OCProperty(object):

    def __init__(self):
        self.pps = []

    def initialWithContent(self,content):
        self.content = content

        self.type = self.getPropertyType(content)
        self.name = self.getPropertyName(content)
        print "属性name is:",self.name
        print "属性type is:",self.type

    #得到类名
    def getPropertyType(self, content):
        restr = "\)(.+?) "
        if content.find('*')>=0:
            restr = "\)(.+?\*)"
        pattern = re.compile(restr)
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            name = name.strip()
            return name

    def getPropertyName(self, content):
        s = Template("""$type(.+?);""")
        ahaha = s.substitute(type=self.type)
        pattern = re.compile(ahaha)
        result1 = pattern.findall(content)
        if len(result1) > 0:
            name = result1[0]
            name = name.strip('*')
            return name

    def appendProperty(self,pp):
        self.pps.append(pp)




