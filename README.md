Metatrader4 Trade Copy tool
===========================

Metatrader4 tool software to copy all trades from one MT4 terminal to one or more terminals - usually connected to other brokers. It uses pure MQL4 language for all the logic. The Windows core kernel32.dll library is used for reading from outside of `experts\files` directory on Windows. On Linux (running under Wine) it is not necessary, one could make a symbolic (or hard-) link to share one file under different directories.

Concept
-----
The tool consists of two main components (MQL4 EA scripts) - TradeCopy Master and TradeCopy Slave. Both terminals need to run on the same computer (or at least need to share one filesystem). The original idea came from user Николай published in [Automated Trading and Strategy Testing](http://www.mql5.com/en/articles/189) article on mql5.com.

* **TradeCopy Master** - runs on any chart on an MT4 terminal we want to copy trades from. It writes all necessar info into a file as soon as any change happens (new trade, SL or TP change, close trade, etc.)
* **TradeCopy Slave** - runs on any chart of MTterminals we want to copy trades to. It reads the status file regurarly and react accordingly as sson as any change occurs.

Features
--------

* Copies Market Orders as well as Limit Orders and Stop Orders
* StopLoss and/or TakeProfit are copied properly
* Slaves can adjust Lot sizes - koeficient or fixed lot

Status
------
Currently under development, first working copy released.

TODO
----

* Use kernel32.dll on slaves to read from outside of own `\experts\files` directory
* Handle properly partially closed trades

Other
-----

You might be interested in "auto pilot" trading at http://copytrade.zulutrade.com/ - just copy trades from the best performed traders into your trading platform and earn money


