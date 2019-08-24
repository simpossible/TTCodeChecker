# -*- coding: UTF-8 -*-

import OCProperty
import  re
import OCMethod
import OCMethodParser


class IOSClass(object):


    def __init__(self,filePath):
        # 从文本路径初始化
        self.name = "default"
        self.filePath = filePath
        self.ocContents = []
        self.ocPropertoes = {}
        self.ocMethods = {}
        self.superClass = None
        self.isFromFrameWork = False


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

        zhushi = re.compile("//[^\r\n]*|/\*.*?\*/|@\".*?\"|@implementation.*?\n|@end", re.DOTALL)
        content = re.sub(zhushi, "", content, count=0, flags=0)

        parser = OCMethodParser.OCMethodParser()
        blocks = parser.parseString(content)

        for block in blocks:
            method = OCMethod.OCMethod()
            method.initialWithContent(block)
            existMethod = self.ocMethods.get(method.name)
            if existMethod:
                existMethod.appendMethod(method)
            else:
                self.ocMethods[method.name] = method



    def baseClass(self):
        if self.superClass:
            return self.superClass.baseClass()
        else:
            return self


    def describe(self):
        if self.name:
            des = ""
            des = des + "\n 类名："
            des = des + self.name
            des = des + "\n 属性:\n"
            for pp in self.ocPropertoes.values():
                des = des + "\n"
                des = des + pp.describe()
            des = "\n" + des + "\n 方法：\n"
            for me in self.ocMethods.values():
                des = des + "\n"
                des = des + me.name
            return des
        else:
            return "None"

    def getMethod(self,name):
        return self.ocMethods.get(name)

    def doForAppendProperties(self,map):
        for ppname, pp in self.ocPropertoes.items():
            if len(pp.name) > 0:
                map[pp.name] = True
                print  "oc 属性:",pp.name

    def doForMixKeyWords(self,map):

        if self.isFromFrameWork:# 库文件里面用到的关键字都不要替换
            if map.has_key(self.name):
                map.pop(self.name)

            #去掉所用到的属性
            for ppname, pp in self.ocPropertoes.items():
                if map.has_key(ppname):  # 如果是storyboard的东西
                    map.pop(pp.name)  # 移除这个属性的关键字
                    print "移除关键字:", pp.name, "\n"
                    _ppname = "_" + pp.name
                    if map.has_key(_ppname):
                        map.pop(_ppname)

                    orgPPname = pp.name
                    orgPPname = self.firstUp(orgPPname)

                    setname = "set" + orgPPname
                    if map.has_key(setname):
                        map.pop(setname)

            for method,ocmehod in self.ocMethods.items(): #移除所用到的方法
                first = ocmehod.firstName
                if map.has_key(first):
                    map.pop(first)


        else:
            for ppname, pp in self.ocPropertoes.items():
                print "检查属性", ppname
                if pp.haveDecoretor("IBOutlet") and map.has_key(ppname):  # 如果是storyboard的东西
                    map.pop(pp.name)  # 移除这个属性的关键字
                    print "移除关键字:", pp.name, "\n"
                    _ppname = "_" + pp.name
                    if map.has_key(_ppname):
                        map.pop(_ppname)

                    orgPPname = pp.name
                    orgPPname = self.firstUp(orgPPname)

                    setname = "set" + orgPPname
                    if map.has_key(setname):
                        map.pop(setname)

                    if map.has_key(self.name):
                        map.pop(self.name)  # 移除这个类的类名



    def firstUp(self,string, lower_rest=False):
        ''' 字符转换
        :param string: 传入原始字符串
        :param lower_rest: bool, 控制参数--是否将剩余字母都变为小写
        :return: 改变后的字符
        '''
        return string[:1].upper() + (string[1:].lower() if lower_rest else string[1:])