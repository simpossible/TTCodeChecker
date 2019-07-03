# -*- coding: UTF-8 -*-

import re
from string import Template

OCBlockType = 1

OCBaseTypes = {"BOOL":"BOOL","float":"float","int":"int","double":"double","UInt32":"UInt32","NSInteger":"NSInteger","CFAbsoluteTime":"CFAbsoluteTime","void":"void"}

class OCType(object):
    def __init__(self,content):
        self.pureType = None
        self.type = content

        self.isPointer = False#是否是指针
        self.genpureType(content)
        self.isBlockType = False


    def genpureType(self,content):
        if content.find('*') >= 0:
            self.isPointer = True
            self.pureType = self.type.replace('*',"")
            self.pureType = self.pureType.strip()


    #是否是基础类型
    def isBaseType(self):
        if self.pureType:
            existType = OCBaseTypes.get(self.pureType)
            if existType:
                return True
        return False