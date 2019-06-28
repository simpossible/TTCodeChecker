# -*- coding: UTF-8 -*-

import OCProperty
import  re
import OCMethod

class IOSClass(object):


    def __init__(self,filePath):
        # 从文本路径初始化
        self.name = "default"
        self.filePath = filePath
        self.ocContents = []
        self.ocPropertoes = {}
        self.ocMethods = {}

    # 处理声明
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

    #处理方法
    def appendOCImplemention(self, content):

        pattern = re.compile("(- {0,}\(.+?)(@end|- {0,}\(|#pra)",re.DOTALL)
        result1 = pattern.findall(content)
        if len(result1) > 0:
            for cc in result1:
                methodContent = cc[0]
                method = OCMethod.OCMethod()
                method.initialWithContent(methodContent)
                existMethod = self.ocMethods.get(method.name)
                if existMethod:
                    existMethod.appendMethod(method)
                else:
                    self.ocMethods[method.name]=method