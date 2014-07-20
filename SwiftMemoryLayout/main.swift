//
//  main.swift
//  SwiftMemoryLayout
//
//  Created by Nico Schmidt on 20.07.14.
//  Copyright (c) 2014 Nico Schmidt. All rights reserved.
//

import Foundation

class TestClass
{
    @objc var a : UInt = 0xaaaaaaaaaaaaaaaa
}

println("\(objectLayoutDescription(TestClass()))")