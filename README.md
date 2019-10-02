# Bare Metal: Coding from scratch
## Introduction
Imagine you are in a room with a standard x86 PC. The computer has
no drives except for a floppy drive, and no networking capabilities, and you
would like to program it. There is a floppy disk on the desk. Would it be 
possible to program it at all, without an operating system? What is the minimum 
software on that floppy needed to be able to program the computer? This
question was asked on Reddit in 2010, and the answer is quite simple.

The computer needs a minimal "monitor" program to allow the user to enter
machine code to run into the computer, which will be shown in the next
chapter.

Before we start, since I'm not going to lock myself in a room to do this
project, I'll set some guidelines for myself. I'll allow my self to use
some reference materials, namely:

* AMD64 Architechture Programmer's Manual Vol. 3 
* "Intel is an octal machine"

I however, will not use an assembler or anything that would require another
computer. I would highly recommend reading the essay "Intel is an octal
machine" as it explains the instruction set of the x86 very well.

With that in mind, let's start out with our initial monitor program.
The program will read octal bytes from the keyboard, store them in memory,
and execute them when a non-octal character is entered.

Here is the monitor program:
```

