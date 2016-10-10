//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2016, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/* -*- coding: utf-8 -*-
 *
 * This indicator is licensed under GNU GENERAL PUBLIC LICENSE Version 3.
 * See a LICENSE file for detail of the license.
 */
#property copyright "Copyright 2016, undeadmouse."
#property link "https://github.com/undeadmouse/mt4-unittest"
#property strict

#include <Object.mqh>
#include <Arrays/List.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class UnitTestData : public CObject
  {
public:
   string            m_name;
   bool              m_result;
   string            m_message;
   bool              m_asserted;

                     UnitTestData(string name);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTestData::UnitTestData(string name)
   : m_name(name),m_result(false),m_message(""),m_asserted(false)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class UnitTest
  {
public:
                     UnitTest();
                    ~UnitTest();

   void              printSummary();
   void              testCase(string name);

   void              fail(string name,string message);
   template<typename T>
   static bool       isEqualTo(string type,T a,T b);
   template<typename T>
   void              assertEquals(string message,T expected,T actual);
   template<typename T>
   void              assertEquals(string message,const T &expected[],const T &actual[]);
private:
   int               m_allTestCount;
   int               m_successTestCount;
   int               m_failureTestCount;
   string            m_testCase;
   CList             m_testList;

   void              addTest(string name);
   void              setSuccess(string name);
   void              setFailure(string name,string message);

   UnitTestData     *findTest(string name);
   void              clearTestList();

   bool              assertArraySize(string name,string message,const int expectedSize,const int actualSize);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTest::UnitTest()
   : m_testList(),m_testCase(""),m_allTestCount(0),m_successTestCount(0)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTest::~UnitTest(void)
  {
   clearTestList();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
static bool UnitTest::isEqualTo(string type,T a,T b)
  {
   if(type=="float" || type=="double")
     {
      return(CompareDoubles((double)a,(double)b));
     }
   else
     {
      return(a==b);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::addTest(string name)
  {
   UnitTestData *test=findTest(name);
   if(test!=NULL)
     {
      return;
     }

   m_testList.Add(new UnitTestData(name));
   m_allTestCount+=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::testCase(string name)
  {
   m_testCase=name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::clearTestList(void)
  {
   if(m_testList.GetLastNode()!=NULL)
     {
      while(m_testList.DeleteCurrent())
         ;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UnitTestData *UnitTest::findTest(string name)
  {
   UnitTestData *data;
   for(data=m_testList.GetFirstNode(); data!=NULL; data=m_testList.GetNextNode())
     {
      if(data.m_name==name)
        {
         return data;
        }
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::setSuccess(string name)
  {
   UnitTestData *test=findTest(name);

   if(test!=NULL)
     {
      if(test.m_asserted)
        {
         return;
        }

      test.m_result=true;
      test.m_asserted=true;

      m_successTestCount+= 1;
      m_failureTestCount = m_allTestCount - m_successTestCount;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::setFailure(string name,string message)
  {
   UnitTestData *test=findTest(name);

   if(test!=NULL)
     {
      test.m_result=false;
      test.m_message=message;
      test.m_asserted=true;

      m_failureTestCount+= 1;
      m_successTestCount = m_allTestCount - m_failureTestCount;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool UnitTest::assertArraySize(string name,string message,const int expectedSize,const int actualSize)
  {
   if(expectedSize==actualSize)
     {
      return true;
     }
   else
     {
      const string m=message+": expected array size is <"+IntegerToString(expectedSize)+
                     "> but <"+IntegerToString(actualSize)+">";
      setFailure(name,m);
      Alert("Test failed: "+name+": "+m);
      return false;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::printSummary(void)
  {
   UnitTestData *data;

   for(data=m_testList.GetFirstNode(); data!=NULL; data=m_testList.GetNextNode())
     {
      if(data.m_result)
        {
         PrintFormat("  %s: OK",data.m_name);
        }
      else
        {
         PrintFormat("  %s: NG: %s",data.m_name,data.m_message);
        }
     }

   double successPercent=0;
   double failurePrcent = 0;
   if(m_allTestCount!=0)
     {
      successPercent = 100.0*m_successTestCount/m_allTestCount;
      failurePrcent  = 100.0*m_failureTestCount/m_allTestCount;
     }
   Print("");
   PrintFormat("  Total: %d, Success: %d (%.2f%%), Failure: %d (%.2f%%)",
               m_allTestCount,m_successTestCount,successPercent,
               m_failureTestCount,failurePrcent);
   Print("UnitTest summary:");
  }
//+------------------------------------------------------------------+
//| Template assertEquals                                           |
//+------------------------------------------------------------------+
template<typename T>
void UnitTest::assertEquals(string message,T expected,T actual)
  {
   string name=m_testCase+"  "+(string) m_allTestCount;
   addTest(name);

   if(isEqualTo(typename(T),expected,actual))
     {
      setSuccess(name);
     }
   else
     {
      const string m=message+": expected is <"+(string)expected+
                     "> but <"+(string)actual+">";
      setFailure(name,m);
      Alert("Test failed: "+name+": "+m);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void UnitTest::assertEquals(string message,const T &expected[],const T &actual[])
  {
   string name=m_testCase+"  "+(string) m_allTestCount;
   addTest(name);
//assertEquals(name,message,expected,actual);
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(!assertArraySize(name,message,expectedSize,actualSize))
     {
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(!UnitTest::isEqualTo(typename(T),expected[i],actual[i]))
        {
         string m=message+": expected array["+(string)i+"] is <";
         m=m+(string)expected[i]+"> but <"+(string)actual[i]+">";
         setFailure(name,m);
         Alert("Test failed: "+name+": "+m);
         return;
        }
     }

   setSuccess(name);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UnitTest::fail(string name,string message)
  {
   setFailure(name,message);
   Alert("Test faied: "+name+": "+message);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Template assertEquals                                           |
//+------------------------------------------------------------------+
template<typename T>
void AssertEquals(string name,string message,T expected,T actual)
  {
   if(UnitTest::isEqualTo(typename(T),expected,actual))
     {
      PrintFormat("  %s: OK",name);
     }
   else
     {
      const string m=message+": expected is <"+(string)expected+
                     "> but <"+(string)actual+">";
      PrintFormat("  %s: NG: %s",name,m);
      Alert("Test failed: "+name+": "+m);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void AssertEquals(string name,string message,const T &expected[],const T &actual[])
  {
//assertEquals(name,message,expected,actual);
   const int expectedSize=ArraySize(expected);
   const int actualSize=ArraySize(actual);

   if(expectedSize!=actualSize)
     {
      PrintFormat("%s: NG: %s",name,"array size should be equal");
      Alert("Test Fail: ",name,"array size should be equal");
      return;
     }

   for(int i=0; i<actualSize; i++)
     {
      if(!UnitTest::isEqualTo(typename(T),expected[i],actual[i]))
        {
         string m=message+": expected array["+(string)i+"] is <";
         m=m+(string)expected[i]+"> but <"+(string)actual[i]+">";
         PrintFormat("%s: NG: %s",name,m);
         Alert("Test failed: "+name+": "+m);
         return;
        }
     }

   PrintFormat("  %s: OK",name);
  }
//+------------------------------------------------------------------+
//| Template assertEquals                                           |
//+------------------------------------------------------------------+
template<typename T>
void AssertEquals(string message,T expected,T actual)
  {
   AssertEquals("Test",message,expected,actual);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void AssertEquals(string message,const T &expected[],const T &actual[])
  {
   AssertEquals("Test",message,expected,actual);
  }
//+------------------------------------------------------------------+
