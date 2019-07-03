# -*- coding: UTF-8 -*-

import re


class OCMethodParser(object):
    def __init__(self):
        #代码块
        self.ocblocks = []
        self.curBlock = None
        self.newLine= ""
        self.blockFlag = -9


    def parseString(self,str):
        for char in str:
            self.inputStr(char)

        return self.ocblocks


    def inputStr(self,char):
        if self.curBlock:
            self.curBlock= self.curBlock + char
        else:
            self.newLine = self.newLine + char

        if char == '{':
            if self.curBlock:
                self.blockFlag = self.blockFlag - 1
            else:
                self.curBlock = self.newLine
                self.blockFlag = -1
                self.newLine = ""


        if char == '}':
            self.blockFlag = self.blockFlag + 1
            if self.blockFlag == 0:
                self.ocblocks.append(self.curBlock)
                self.curBlock = None
                self.blockFlag=-9


