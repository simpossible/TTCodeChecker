# -*- coding: UTF-8 -*-

import OCProperty
import  re

class IOSClass(object):


    def __init__(self,filePath):
        # 从文本路径初始化
        self.filePath = filePath
        self.ocContents = []
        self.ocPropertoes = {}


    def appendOCInterFace(self,content):
        self.ocContents.append(content)
        self.parseOcContent(content)

    def parseOcContent(self,content):
        pattern = re.compile("@property.+?;")
        result1 = pattern.findall(content)
        for content in result1:
            pp = OCProperty.OCProperty()
            pp.initialWithContent(content)
            if pp.name:
                exist = self.ocPropertoes.get(pp.name)
                if exist:
                    exist.appendProperty(pp)
                else:
                    self.ocPropertoes[pp.name]=pp



