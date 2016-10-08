mt4-unittest
===============

Description
-------------

This is a unit testing library for MetaTrader 4.

Requiremnts
-------------

MetaTrader 4, which supports MQL 5.

Installation
--------------

1. Copy [MQL4/Include/UnitTest.mqh](https://github.com/undeadmouse/mt4-unittest/blob/master/MQL4/Include/UnitTest.mqh) to ``MQL4/Include``
1. See the following usage sample, or get it from [here](https://raw.github.com/micclly/mt4-unittest/master/MQL4/Samples/TestExpert.mq4).

Usage Sample
--------------

```cpp
   UnitTest *unitTest=new UnitTest();
   unitTest.testCase("simple_type");
   unitTest.assertEquals("one should be one", 1, 1);
   unitTest.assertEquals("str should be str", "str", "str");
   unitTest.assertEquals("true should be true", true, true);
   unitTest.assertEquals("char should be char", 'c', 'c');
   unitTest.assertEquals("1.0 should be 1.0", 1.0, 1.0);

   unitTest.testCase("array_type");
   int expected[2] = {1, 2};
   int actual[2]   = {1, 2};
   unitTest.assertEquals("array equal", expected, actual);
   
   unitTest.testCase("others");
   unitTest.assertEquals("color", clrRed, clrRed);
   unitTest.assertEquals("color", clrGray, C'128,128,128');
   unitTest.assertEquals("datatime", D'2016.01.01 00:00', D'2016.01.01 00:00:00');

   unitTest.printSummary();
   delete unitTest;
```
